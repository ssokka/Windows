Add-Type @'
using System;
using System.Runtime.InteropServices;
public class Window {
	[DllImport("user32.dll")]
	public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
	[DllImport("user32.dll")]
	public static extern bool SetForegroundWindow(IntPtr hWnd);   
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

$code = @'
[DllImport("user32.dll")]
public static extern bool BlockInput(bool fBlockIt);
'@
$userInput = Add-Type -MemberDefinition $code -Name UserInput -Namespace UserInput -PassThru

$global:temp = "$Env:Temp\Download"

function current-cursor-position {
	[Alias("ccp")]
	param(
		[Int]$x,
		[Int]$y
	)
	if ($Env:WT_SESSION -or $Env:OS -ne "Windows_NT") {
		if (!$Global:LastConsoleLine -and [Console]::CursorTop -eq [Console]::WindowHeight - 1) { $Global:LastConsoleLine = 1; --$y }
	}
	[Console]::SetCursorPosition($x, $y)
	[Console]::Write("{0,-$([Console]::WindowWidth)}" -f ' ')
	[Console]::SetCursorPosition($x, $y)
}

function disable-defender-realtime {
	[Alias("ddr")]
	param(
		[bool]$status = $true
	)
	Add-MpPreference -ExclusionPath "$global:temp" -Force
	Set-MpPreference -MAPSReporting Disable
	Set-MpPreference -SubmitSamplesConsent NeverSend
	if ((Get-MpComputerStatus).RealTimeProtectionEnabled -ne $status) {
		do {
			explorer windowsdefender://ThreatSettings
			do {
				Start-Sleep -Milliseconds 1500
				$wid = (Get-Process | Where-Object {$_.MainWindowTitle -like "Windows *" -and $_.ProcessName -eq "ApplicationFrameHost"}).Id
			} until ($wid)
			Start-Sleep -Milliseconds 1500
			$shell = New-Object -ComObject WScript.Shell
			$null = $userInput::BlockInput($true)
			$null = $shell.AppActivate($wid)
			$shell.SendKeys(' ')
			$null = $userInput::BlockInput($false)
			Start-Sleep -Milliseconds 1500
		} until ((Get-MpComputerStatus).RealTimeProtectionEnabled -eq $status)
		Stop-Process -Id $wid -ErrorAction Ignore
	}
}

function disable-uac {
	Start-Process -Verb RunAs -Wait -WindowStyle Hidden -FilePath reg.exe -ArgumentList 'add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" /t REG_DWORD /d "0" /f'
	Start-Process -Verb RunAs -Wait -WindowStyle Hidden -FilePath reg.exe -ArgumentList 'add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "PromptOnSecureDesktop" /t REG_DWORD /d "0" /f'
	Start-Process -Verb RunAs -Wait -WindowStyle Hidden -FilePath reg.exe -ArgumentList 'add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" /t REG_DWORD /d "0" /f'
	Start-Process -Verb RunAs -Wait -WindowStyle Hidden -FilePath reg.exe -ArgumentList 'add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Policies\System" /v "PromptOnSecureDesktop" /t REG_DWORD /d "0" /f'
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

function pin-to {
	[Alias('pt')]
	param(
		[string]$type,
		[string]$name,
		[string]$path,
		[string]$argu = $null,
		[string]$icon = $null,
		[bool]$kill = $false
	)
	$ErrorActionPreference = 'Stop'
	switch ($type) {
		task { $type, $pdir = '5386', "$Env:AppData\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar" }
		start { $type, $pdir = '51201', "$Env:AppData\Microsoft\Windows\Start Menu\Programs" }
	}
	if (!$icon) { $icon = $path }
	$exec = 'syspin.exe'
	$guid = ([System.Guid]::NewGuid()).ToString()
	$temp = "$Env:Temp\$guid.exe"
	$glnk = "$pdir\$guid.lnk"
	$nlnk = "$pdir\$name.lnk"
	Write-Host $name
	if (!(Test-Path -Path "$Env:Temp\$exec")) { Start-BitsTransfer -Source "https://github.com/ssokka/Windows/raw/master/Tool/$exec" -Destination "$Env:Temp\$exec" }
	$null = New-Item -Path $temp -ItemType File -Force
	Start-Process -FilePath "$Env:Temp\$exec" -ArgumentList "`"$temp`" $type" -Wait -WindowStyle Hidden
	do { Start-Sleep -Milliseconds 250 } until (Test-Path -Path $glnk)
	Start-Sleep -Seconds 5
	$shell = (New-Object -ComObject WScript.Shell).CreateShortcut($glnk)
	$shell.TargetPath = $path
	$shell.Arguments = $argu
	$shell.IconLocation = $icon
	$shell.Save()
	Remove-Item -Path $nlnk -Force -ErrorAction Ignore
	Remove-Item -Path $temp -Force
	Rename-Item -Path $glnk -NewName $nlnk -Force
	if ($kill) { Start-Sleep -Seconds 3; Stop-Process -Name explorer -Force }
}

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
	$area = ([Windows.Forms.Screen]::PrimaryScreen).WorkingArea
	$x = ($area.Width - $w) / 2
	$y = ($area.Height - $h) / 2
	$null = [Window]::MoveWindow($hwnd, $x, $y, $w, $h, $true)
	$null = [Window]::SetForegroundWindow($hwnd)
	$show | % { $null = [Window]::ShowWindow($hwnd, $_) }
}

disable-uac
set-window
