param([bool]$wait = $true)

if (!(Get-Command -Name set-window -CommandType Function 2>$null)) { Invoke-Expression -Command ([Net.WebClient]::new()).DownloadString("https://github.com/ssokka/Windows/raw/master/header.ps1") }

$title = "반디집"
$name = "Bandizip"
$path = "$Env:ProgramFiles\$name"
$exec = "$path\$name.exe"

$site = "https://kr.bandisoft.com/bandizip"
$down = "$site/dl.php?web"
$file = "BANDIZIP-SETUP-STD-X64.EXE"
$spat = '(?is).*?<h2><.*?>v*(.*?)<.*'

try {
	$host.ui.RawUI.WindowTitle = $title
	Write-Host "`n### $title" -ForegroundColor Green
	
	Write-Host "`n# 버전" -ForegroundColor Blue
	$cver = "$((Get-Item -Path $exec -ErrorAction Ignore).VersionInfo.FileVersion -replace '(.*)\.0.*', '$1')".Trim()
	$wc = New-Object System.Net.WebClient
	$wc.Headers["User-Agent"] = $UserAgent
	$sver = "$($wc.DownloadString("$site/history") -replace $spat, '$1')".Trim()
	Write-Host "현재: $cver"
	Write-Host "최신: $sver"
	
	if ($cver -ne $sver) {
		Write-Host "`n# 다운로드" -ForegroundColor Blue
		Start-BitsTransfer -Source $down -Destination "$Temp\$file"
		Write-Host "`n# 설치" -ForegroundColor Blue
		Stop-Process -Name $name -Force -ErrorAction Ignore
		& "$Temp\$file" /S | Out-Host
		Remove-Item -Path "$Temp\$file" -Force -ErrorAction Ignore
	}
	
	Write-Host "`n# 설정" -ForegroundColor Blue
	Start-BitsTransfer -Source "$Git/$name/$name.reg" -Destination "$Temp\$name.reg"
    Stop-Process -Name $name -Force -ErrorAction Ignore
    & regedit.exe /s "$Temp\$name.reg" | Out-Null | Out-Host
    Remove-Item -Path "$Temp\$name.reg" -Force -ErrorAction Ignore
    $edit = "$Env:ProgramFiles\Notepad++\notepad++.exe"
    if (Test-Path -Path $edit) { & reg.exe add "HKCU\SOFTWARE\$name" /v "editorPathName" /t REG_SZ /d "$edit" /f | Out-Null | Out-Host }
    ([Net.WebClient]::new()).DownloadString("$Git/$name/readme.md") -replace '(?is).*?### 설정.*?```(?:\r\n|\n)(.*?)(?:\r\n|\n)```.*', '$1'
	
	if ($wait) {
		set-window
		Write-Host "`n### 완료" -ForegroundColor Green
		Write-Host "`n아무 키나 누르십시오..." -NoNewline; Read-Host
	}
}
catch {
	Write-Error ($_.Exception | Format-List -Force | Out-String) -ErrorAction Continue
	Write-Error ($_.InvocationInfo | Format-List -Force | Out-String) -ErrorAction Continue
	throw
}
