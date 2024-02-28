Add-Type @'
using System;
using System.Runtime.InteropServices;
public class Window {
	[DllImport("user32.dll")]
	public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
	[DllImport("user32.dll")]
	public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);    
	[DllImport("user32.dll")]
	public extern static bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
}
public struct RECT {
	public int Left;
	public int Top;
	public int Right;
	public int Bottom;
}
'@
Add-Type -AssemblyName System.Windows.Forms
$area = ([Windows.Forms.Screen]::PrimaryScreen).WorkingArea

function set-window {
	param(
		[int[]]$show = (1, 9)
	)
	$ErrorActionPreference = 'SilentlyContinue'
	$ppid = (Get-WmiObject Win32_Process -Filter "processid='$PID'").ParentProcessId
	$hwnd = (Get-Process -Id $ppid).MainWindowHandle
	if (!$hwnd) { $hwnd = (Get-Process -Id $pid).MainWindowHandle }
	$rect = New-Object RECT
	$null = [Window]::GetWindowRect($hwnd, [ref]$rect)
	$w = $rect.Right - $rect.Left
	$h = $rect.Bottom - $rect.Top
	$x = ($Global:area.Width - $w) / 2
	$y = ($Global:area.Height - $h) / 2
	$null = [Window]::MoveWindow($hwnd, $x, $y, $w, $h, $true)
	$show | % { $null = [Window]::ShowWindow($hwnd, $_) }
}

$name = 'OpenVPN'
$svnm = 'OpenVPNService'

function ovpn-on {
	$host.ui.RawUI.WindowTitle = $(Get-PSCallStack)[0].FunctionName
	set-window
	
	Write-Host -ForegroundColor Green "`n### $Global:name 서비스 시작"
	Start-Process -Verb RunAs -Wait -WindowStyle Hidden powershell "Start-Service $Global:svnm"
	((Get-Service $Global:svnm | Out-String) -replace '(?im)^\r\n', '').Trim()
	
	$file = "$PSScriptRoot\ovpn-drive.cmd"
	if (Test-Path $file) {
		Write-Host -ForegroundColor Green "`n### $Global:name 네트워크 드라이브 연결"
		Start-Process -Wait -WindowStyle Hidden $file
		((Get-SmbMapping | Sort-Object | Format-Table -Force | Out-String) -replace '(?im)^\r\n','').Trim()
	}
	
	Write-Host
	foreach ($i in 5..1) { Write-Host -NoNewline "`r${i}초 후 자동 닫힘"; Start-Sleep 1 }
}

function ovpn-off {
	$ErrorActionPreference = 'SilentlyContinue'
	$host.ui.RawUI.WindowTitle = $(Get-PSCallStack)[0].FunctionName
	set-window
	
	Write-Host -ForegroundColor Green "`n### $Global:name 네트워크 드라이브 연결 끊기"
	Get-Item "$Env:ProgramFiles\OpenVPN\config-auto\*.ovpn" | `
	% { (Get-Content -raw $_) -replace '(?is).*dev-node (.*?)(?:\r\n|\n).*', '$1' } | `
	% { (Get-NetIPAddress -InterfaceAlias $_.Trim() -AddressFamily IPv4).IPAddress } | `
	% { $_ -replace '(.*\.).*', '$1' } | `
	% { (Get-SmbMapping | ? RemotePath -Like "\\$_*").LocalPath } | `
	% { Remove-SmbMapping $_ -Force }
	((Get-SmbMapping | Sort-Object | Format-Table -Force | Out-String) -replace '(?im)^\r\n', '').Trim()
	
	Write-Host -ForegroundColor Green "### $Global:name 서비스 중지"
	Start-Process -Verb RunAs -Wait -WindowStyle Hidden powershell "Stop-Service $Global:svnm -Force"
	((Get-Service $Global:svnm | Out-String) -replace '(?im)^\r\n', '').Trim()
	
	Write-Host
	foreach ($i in 5..1) { Write-Host -NoNewline "`r${i}초 후 자동 닫힘"; Start-Sleep 1 }
}

function ovpn-drive {
	Param(
		[String]$ndrv,
		[String]$ipad,
		[String]$path,
		[String]$user,
		[String]$pass,
		[String]$name
	)
	$ErrorActionPreference = 'SilentlyContinue'
	$host.ui.RawUI.WindowTitle = $(Get-PSCallStack)[0].FunctionName
	
	Write-Host -ForegroundColor Green "`n### $name 네트워크 드라이브 연결"
	do {
		Start-Sleep -Milliseconds 250
		$temp = [Net.Dns]::GetHostAddresses($ipad)
	} until ($temp)
	$ipad = ($temp | ? { $_.AddressFamily -eq 'InterNetwork' }).IPAddressToString
	
	do {
		Start-Sleep -Milliseconds 250
	} until (Test-Connection $ipad -Count 1)
	
	Remove-SmbMapping $ndrv -Force -ErrorAction Ignore
	
	$null = net use $ndrv "\\$ipad\$path" /persistent:yes /user:$user $pass 2>$null
	if (!$?) { net use $ndrv "\\$ipad\$path" /persistent:yes }
	if ($?) {
		(New-Object -ComObject Shell.Application).NameSpace($ndrv).Self.Name = "$name"
	} else {
		powershell -WindowStyle Normal -Command { exit }
		set-window
		Write-Host -NoNewline "`n아무 키나 누르십시오..."; Read-Host
	}
	
	exit
}
