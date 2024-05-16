$ErrorActionPreference = "Stop"

$x, $y = [Console]::CursorLeft, [Console]::CursorTop
Write-Host "`n### 준비중" -ForegroundColor Green -NoNewline

$UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"

$Git = "https://raw.githubusercontent.com/ssokka/Windows/master"

$Temp = "$Env:Temp\Download"
New-Item -Path $Temp -ItemType Directory -Force | Out-Null

$UserInput = Add-Type -MemberDefinition '[DllImport("user32.dll")] public static extern bool BlockInput(bool fBlockIt);' -Name UserInput -Namespace UserInput -PassThru

$Global:LastConsoleLine = 0

$sb = { 'ConsentPromptBehaviorAdmin', 'PromptOnSecureDesktop' | ForEach-Object { reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' /v $_ /t REG_DWORD /d '0' /f } }
Start-Process -Verb RunAs -Wait -WindowStyle Hidden -FilePath powershell.exe -ArgumentList "-command", "(Invoke-Command -ScriptBlock {$sb})"

Start-Process -Verb RunAs -Wait -WindowStyle Hidden -FilePath powershell.exe -ArgumentList "-command", "
Add-MpPreference -ExclusionPath `"$Temp`" -Force
Set-MpPreference -MAPSReporting 0 -Force
Set-MpPreference -SubmitSamplesConsent 2 -Force
"

function install-7zip {
	$name = "7Zip4Powershell"
	if (Get-Module -Name $name -ListAvailable) { return }
	Write-Host "`n# Powershell 7Zip 모듈 설치" -ForegroundColor Blue
	Start-Process -Verb RunAs -Wait -WindowStyle Hidden -FilePath powershell.exe -ArgumentList "-command", "
	Set-ExecutionPolicy -ExecutionPolicy Bypass -Force
	Install-PackageProvider NuGet -MinimumVersion 2.8.5.201 -Force
	Register-PSRepository -Default -ErrorAction Ignore
	Set-PSRepository PSGallery -InstallationPolicy Trusted
	Install-Module $name -Force
	"
}

function current-cursor-position {
	[Alias("ccp")]
	param([Int]$x, [Int]$y)
	if (($Env:WT_SESSION -or $Env:OS -ne "Windows_NT") -and (!$Global:LastConsoleLine -and [Console]::CursorTop -eq [Console]::WindowHeight - 1)) { $Global:LastConsoleLine = 1; --$y }
	[Console]::SetCursorPosition($x, $y)
	[Console]::Write("{0,-$([Console]::WindowWidth)}" -f " ")
	[Console]::SetCursorPosition($x, $y)
}

function disable-defender-realtime {
	[Alias("ddr")]
	param([bool]$status = $true)
	if ((Get-MpComputerStatus).RealTimeProtectionEnabled -eq $status) { return }
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

function download {
	[Alias("dw")]
	param(
		[string]$url,
		[string]$dst = $Temp,
		[string]$tmp = $Temp,
		[string]$ren = '',
		[string]$pat = '*x64.zip',
		[bool]$wri = $true
	)
	if ($wri) { Write-Host "`n# 다운로드" -ForegroundColor Blue }
	if ($url -match '^https://api.github.com/repos/.*/releases/latest$') {
		$src = (Invoke-RestMethod -Uri $url | ForEach-Object assets | Where-Object name -like $pat).browser_download_url
		$file = $src -replace '.*/(.*)', '$1'
	} else {
		$wr = [Net.WebRequest]::Create($url)
		$wr.AllowAutoRedirect = $true
		$wr.Method = "HEAD"
		$wr.UserAgent = $UserAgent
		$re = $wr.GetResponse()
		$src = $re.ResponseUri
		$file = [IO.Path]::GetFileName($src.AbsolutePath)
		$re.Close()
	}
	if ($ren) { $file = $ren }
	if ($dst.EndsWith('\')) {
		$dst += $file
	} else {
		$dst += '\' + $file
	}
	Start-BitsTransfer -Source $src -Destination $dst
	if (!(".zip", ".7z", ".rar" -contains (Get-ChildItem $dst).Extension )) { return $dst }
	install-7zip
	try { $test = Get-7Zip -ArchiveFileName $dst } catch {}
	if ($test) {
		Expand-7Zip -ArchiveFileName $dst -TargetPath $tmp -ErrorAction Ignore
	} else {
		Write-Host "암호: " -NoNewline
		$Global:LastConsoleLine = 0
		while ($true) {
			$x, $y = [Console]::CursorLeft, [Console]::CursorTop
			Expand-7Zip -ArchiveFileName $dst -TargetPath $tmp -SecurePassword (Read-Host -AsSecureString) -ErrorAction Ignore
			if ($?) { break } else { ccp $x $y }
		}
	}
	Remove-Item -Path $dst -Force -ErrorAction Ignore
}

function get-version {
	[Alias("gov")]
	param(
		[string]$src,
		[string]$pat = '',
		[string]$ret = '$1'
	)
	switch -Regex ($src) {
		'^https://api.github.com/repos/.*/releases/latest$' {
			$ver = (Invoke-RestMethod -Uri $_).tag_name
			Break
		}
		'^(http[s]?)\://.*$' {
			$wc = New-Object System.Net.WebClient
			$wc.Headers["User-Agent"] = $UserAgent
			$ver = $wc.DownloadString($_)
			Break
		}
		'^.*$' {
			$ver = (Get-Item -Path $_ -ErrorAction Ignore).VersionInfo.FileVersion
			Break
		}
	}
	if ($pat) { $ver = $ver -replace $pat, $ret }
	if ($ver) { return $ver.Trim() }
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
	$exec = "$Temp\syspin.exe"
	$guid = ([System.Guid]::NewGuid()).ToString()
	$gexe = "$Temp\$guid.exe"
	$glnk = "$pdir\$guid.lnk"
	$nlnk = "$pdir\$name.lnk"
	Write-Host $name
	if (!(Test-Path -Path $exec)) { dw "https://www.technosys.net/download.aspx?file=syspin.exe" -ren "syspin.exe" | Out-Null }
	New-Item -Path $gexe -ItemType File -Force | Out-Null
	& $exec "$gexe" $type | Out-Null | Out-Host
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
	$exec = "$Temp\nircmd.exe"
	if (!(Test-Path -Path $exec)) { dw "https://www.nirsoft.net/utils/nircmd.zip" | Out-Null }
	$ppid = (Get-WmiObject Win32_Process -Filter "processid='$cpid'").ParentProcessId
	$hwnd = (Get-Process -Id $ppid).MainWindowHandle
	if (!$hwnd) { $hwnd = (Get-Process -Id $cpid).MainWindowHandle }
	if (!(Test-Path -Path $exec)) { return }
	$sb = { param($exec, $hwnd); 'normal', 'activate', 'center' | ForEach-Object { & $exec win $_ handle $hwnd } }
	Start-Process -Verb RunAs -Wait -WindowStyle Hidden -FilePath powershell.exe -ArgumentList "-command (Invoke-Command -ScriptBlock {$sb} -ArgumentList `"$exec`", $hwnd)"
}

set-window
ccp $x $y
