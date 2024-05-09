$name = "WireGuard"
$path = "$Env:ProgramFiles\$name"
$exec = "$path\$name.exe"
$data = Get-ChildItem "$path\Data\Configurations\*.dpapi"

$ErrorActionPreference = 'SilentlyContinue'

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

function set-window {
	param(
		[int[]]$show = (1, 4, 9)
	)
	$ppid = (Get-WmiObject Win32_Process -Filter "processid='$PID'").ParentProcessId
	$hwnd = (Get-Process -Id $ppid).MainWindowHandle
	if (!$hwnd) { $hwnd = (Get-Process -Id $pid).MainWindowHandle }
	$rect = New-Object RECT
	$null = [Window]::GetWindowRect($hwnd, [ref]$rect)
	$w = $rect.Right - $rect.Left
	$h = $rect.Bottom - $rect.Top
	$area = ([Windows.Forms.Screen]::PrimaryScreen).WorkingArea
	$x = ($area.Width - $w) / 2
	$y = ($area.Height - $h) / 2
	$null = [Window]::MoveWindow($hwnd, $x, $y, $w, $h, $true)
	$show | % { $null = [Window]::ShowWindow($hwnd, $_) }
}

function wg-service {
	if (!(Test-Path $exec)) { exit }
	set-window
	#$host.ui.RawUI.WindowTitle = $(Get-PSCallStack)[0].FunctionName.ToUpper()
	$host.ui.RawUI.WindowTitle = "$name"
	Write-Host -ForegroundColor Green "`n### $name"
	Write-Host -ForegroundColor Blue "`n# 서비스 확인"
	
	$sname = 'WireGuardManager'
	if (!(Get-Service $sname -ErrorAction Ignore)) {
		Start-Process -Verb RunAs -Wait -WindowStyle Hidden $exec "/installmanagerservice"
		do {
			Start-Sleep -Milliseconds 250
		} until (Get-Service $sname)
		(Get-Process | Where-Object { $_.ProcessName -eq "wireguard" -and $_.MainWindowTitle -eq "WireGuard" }).Kill()
	}
	Start-Process -Verb RunAs -Wait -WindowStyle Hidden sc.exe "failure $sname reset= 0 actions= restart/0/restart/0/restart/0"
	Start-Process -Verb RunAs -Wait -WindowStyle Hidden sc.exe "start $sname"
	do {
		Start-Sleep -Milliseconds 250
	} until ((Get-Service $sname).Status -eq 'Running')
	
	$data | ForEach-Object {
		if($_) {
			$sname = "WireGuardTunnel`$$($_ -replace '.*\\(.*)\.conf.*', '$1')"
			if (!(Get-Service $sname -ErrorAction Ignore)) {
				Start-Process -Verb RunAs -Wait -WindowStyle Hidden $exec "/installtunnelservice `"$_`""
				do {
					Start-Sleep -Milliseconds 250
				} until (Get-Service $sname)
			}
			Start-Process -Verb RunAs -Wait -WindowStyle Hidden sc.exe "failure $sname reset= 0 actions= restart/0/restart/0/restart/0"
		}
	}
}

function wg-smb {
	$reg = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2'
	$smb = foreach($row in Get-SmbMapping){
		$key = Join-Path -Path $reg -ChildPath ($row.RemotePath -replace '\\', '#')
		[pscustomobject]@{
			RemotePath = $row.RemotePath
			LocalPath = $row.LocalPath
			Status = $row.Status
			Label = Get-ItemPropertyValue -Path $key -Name '_LabelFromReg' -ErrorAction SilentlyContinue
		}
	}
if ($smb) { ($smb | Sort-Object -Property LocalPath | Out-String).Trim("`r","`n") }
}

function on {
	if (!(Test-Path $exec)) { exit }
	wg-service
	#$host.ui.RawUI.WindowTitle = $(Get-PSCallStack)[0].FunctionName.ToUpper()
	$host.ui.RawUI.WindowTitle = "$name On"
	Write-Host -ForegroundColor Green "`n### $name On"
	Write-Host -ForegroundColor Blue "`n# 서비스 시작"
	(Get-Service -Name "WireGuardTunnel`$*" -ErrorAction Ignore).Name | ForEach-Object {
		if($_) {
			$_
			Start-Process -Verb RunAs -Wait -WindowStyle Hidden sc.exe "start `"$_`""
			do {
				Start-Sleep -Milliseconds 250
			} until ((Get-Service "$_").Status -eq 'Running')
		}
	}
	$file = "$PSScriptRoot\drive.cmd"
	if (Test-Path $file) {
		Write-Host -ForegroundColor Blue "`n# 네트워크 드라이브 연결"
		Start-Process -Wait -NoNewWindow $file
		#(Get-SmbMapping | Sort-Object | Format-Table -Force | Out-String).Trim("`r","`n")
		wg-smb
	}
	Write-Host
	foreach ($i in 5..1) { Write-Host -NoNewline "`r${i}초 후 자동 닫힘"; Start-Sleep 1 }
}

function off {
	if (!(Test-Path $exec)) { exit }
	set-window
	#$host.ui.RawUI.WindowTitle = $(Get-PSCallStack)[0].FunctionName.ToUpper()
	$host.ui.RawUI.WindowTitle = "$name Off"
	Write-Host -ForegroundColor Green "`n### $name Off"
	Write-Host -ForegroundColor Blue "`n# 네트워크 드라이브 연결 끊기"
	(Get-NetIPAddress -InterfaceAlias "wg*").IPAddress -replace '(.*\.).*', '$1' | ForEach-Object { (Get-SmbMapping -RemotePath "*$_*").LocalPath } | Sort-Object | ForEach-Object { if ($_) { $null = net use $_ /delete /y 2>$null } }
	wg-smb
	Write-Host -ForegroundColor Blue "`n# 서비스 중지"
	(Get-Service -Name "WireGuardTunnel`$*" -ErrorAction Ignore).Name | ForEach-Object {
		if($_) {
			$_
			Start-Process -Verb RunAs -Wait -WindowStyle Hidden sc.exe "stop `"$_`""
			do {
				Start-Sleep -Milliseconds 250
			} until ((Get-Service "$_").Status -eq 'Stopped')
		}
	}
	$sname = 'WireGuardManager'
	Start-Process -Verb RunAs -Wait -WindowStyle Hidden sc.exe "stop `"$sname`""
	do {
		Start-Sleep -Milliseconds 250
	} until ((Get-Service "$sname").Status -eq 'Stopped')
	
	Write-Host
	foreach ($i in 5..1) { Write-Host -NoNewline "`r${i}초 후 자동 닫힘"; Start-Sleep 1 }
}

function drive {
	Param(
		[String]$ndrv,
		[String]$ipad,
		[String]$path,
		[String]$user,
		[String]$pass,
		[String]$name
	)
	if (!(Test-Path $exec)) { exit }
	set-window
	Write-Host -ForegroundColor Green "`n### $name 네트워크 드라이브 연결"
	do {
		Start-Sleep -Milliseconds 250
		$temp = [Net.Dns]::GetHostAddresses($ipad)
	} until ($temp)
	$ipad = ($temp | ? { $_.AddressFamily -eq 'InterNetwork' }).IPAddressToString
	do {
		Start-Sleep -Milliseconds 250
	} until (Test-Connection $ipad -Count 1)
	$null = net use $ndrv /delete /y 2>$null
	$null = net use $ndrv "\\$ipad\$path" /persistent:yes /user:$user $pass 2>$null
	if (!$?) { net use $ndrv "\\$ipad\$path" /persistent:yes }
	if ($?) {
		(New-Object -ComObject Shell.Application).NameSpace($ndrv).Self.Name = "$name"
	} else {
		powershell -WindowStyle Normal -Command { exit }
		set-window
		Write-Host -NoNewline "`n아무 키나 누르십시오..."; Read-Host
	}
}
