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

function current-cursor-position {
	[Alias('ccp')]
	param(
		[Int]$x,
		[Int]$y
	)
	# if (!$lline) { $lline = 0 }
	if ($Env:WT_SESSION -or $Env:OS -ne 'Windows_NT') {
		if (!$lline -and [Console]::CursorTop -eq [Console]::WindowHeight - 1) { $lline = 1; --$y }
	}
	[Console]::SetCursorPosition($x, $y)
	[Console]::Write("{0,-$([Console]::WindowWidth)}" -f ' ')
	[Console]::SetCursorPosition($x, $y)
}

function pin-to {
	[Alias('pt')]
	param(
		[string]$type,
		[string]$path,
		[string]$icon,
		[bool]$kill = $false
	)
	$ErrorActionPreference = 'Stop'
	switch ($type) {
		task { $type = '5386'; $pdir = "$Env:AppData\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar" }
		start { $type = '51201'; $pdir = "$Env:AppData\Microsoft\Windows\Start Menu\Programs" }
	}
	$name = (Get-Item $path).BaseName
	if (!$icon) { $icon = $path }
	Write-Host "- $name"
	$exec = 'syspin.exe'
	$guid = ([System.Guid]::NewGuid()).ToString()
	$temp = "$Env:Temp\$guid.exe"
	$glnk = "$pdir\$guid.lnk"
	$nlnk = "$pdir\$name.lnk"
	if (!(Test-Path "$Env:Temp\$exec")) { Start-BitsTransfer "https://github.com/ssokka/Windows/raw/master/Tool/$exec" "$Env:Temp\$exec" }
	$null = New-Item $temp -ItemType File -Force
	Start-Process -Wait -WindowStyle Hidden "$Env:Temp\$exec" "`"$temp`" $type"
	do { Start-Sleep 1 } until (Test-Path $glnk)
	Start-Sleep 5
	$owsc = (New-Object -ComObject WScript.Shell).CreateShortcut($glnk)
	$owsc.TargetPath = $path
	$owsc.IconLocation = $icon
	$owsc.Save()
	Remove-Item $nlnk -Force -ErrorAction Ignore
	Rename-Item $glnk $nlnk -Force
	Remove-Item $temp -Force
	if ($kill) { Start-Sleep 3; Stop-Process -Name explorer -Force }
}

function install-7zip {
	if (!(Get-Module 7Zip4Powershell -ListAvailable)) {
		Set-ExecutionPolicy Bypass -Force
		$null = Install-PackageProvider NuGet -MinimumVersion 2.8.5.201 -Force
		Register-PSRepository -Default -ErrorAction Ignore
		Set-PSRepository PSGallery -InstallationPolicy Trusted
		$null = Install-Module 7Zip4PowerShell -Force
	}
}

set-window
