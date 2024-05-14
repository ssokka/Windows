param([bool]$wait = $true)

Write-Host "`n### 준비중" -ForegroundColor Green -NoNewline

$UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"

$Global:Temp = "$Env:Temp\Download"
$null = New-Item -Path $Global:Temp -ItemType Directory -Force
Start-Process -Verb RunAs -Wait -WindowStyle Hidden -FilePath powershell.exe -ArgumentList "-command", "
Add-MpPreference -ExclusionPath `"$Global:Temp`" -Force
Set-MpPreference -MAPSReporting 0 -Force
Set-MpPreference -SubmitSamplesConsent 2 -Force
"

$userInput = Add-Type -MemberDefinition '[DllImport("user32.dll")] public static extern bool BlockInput(bool fBlockIt);' -Name UserInput -Namespace UserInput -PassThru

function current-cursor-position {
	[Alias("ccp")]
	param(
		[Int]$x,
		[Int]$y
	)
	if ($Env:WT_SESSION -or $Env:OS -ne "Windows_NT") {
		if (!$LastConsoleLine -and [Console]::CursorTop -eq [Console]::WindowHeight - 1) { $LastConsoleLine = 1; --$y }
	}
	[Console]::SetCursorPosition($x, $y)
	[Console]::Write("{0,-$([Console]::WindowWidth)}" -f " ")
	[Console]::SetCursorPosition($x, $y)
}

function disable-defender-realtime {
	[Alias("ddr")]
	param(
		[bool]$status = $true
	)
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
	Start-Process -Verb RunAs -Wait -WindowStyle Hidden -FilePath powershell.exe -ArgumentList "-command", "
	reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' /v 'ConsentPromptBehaviorAdmin' /t REG_DWORD /d '0' /f
	reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' /v 'PromptOnSecureDesktop' /t REG_DWORD /d '0' /f
	reg.exe add 'HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Policies\System' /v 'ConsentPromptBehaviorAdmin' /t REG_DWORD /d '0' /f
	reg.exe add 'HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Policies\System' /v 'PromptOnSecureDesktop' /t REG_DWORD /d '0' /f
	"
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
	$ErrorActionPreference = "Stop"
	switch ($type) {
		task { $type, $pdir = "5386", "$Env:AppData\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar" }
		start { $type, $pdir = "51201", "$Env:AppData\Microsoft\Windows\Start Menu\Programs" }
	}
	if (!$icon) { $icon = $path }
	$exec = "syspin.exe"
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
	Start-Sleep -Seconds 1
	if ($kill) { Start-Sleep -Seconds 3; Stop-Process -Name explorer -Force }
}

function set-window {
	param(
		[int]$cpid = $PID
	)
	$ErrorActionPreference = "SilentlyContinue"
	$ncmd = "nircmd.exe"
	if (!(Test-Path -Path "$Env:Temp\$ncmd")) { Start-BitsTransfer -Source "https://github.com/ssokka/Windows/raw/master/Tool/$ncmd" -Destination "$Env:Temp\$ncmd" }
	$ppid = (Get-WmiObject Win32_Process -Filter "processid='$cpid'").ParentProcessId
	$hwnd = (Get-Process -Id $ppid).MainWindowHandle
	if (!$hwnd) { $hwnd = (Get-Process -Id $cpid).MainWindowHandle }
	if (Test-Path -Path "$Env:Temp\$ncmd") { ("normal", "activate", "center") | ForEach-Object { & "$Env:Temp\$ncmd" win $_ handle $hwnd } }
}

set-window
disable-uac
ccp 0 0
$ErrorActionPreference = "Stop"
