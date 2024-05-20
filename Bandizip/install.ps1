param([bool]$wait = $true)

if (!(Get-Command -Name set-window -CommandType Function 2>$null)) { Invoke-Expression -Command ([Net.WebClient]::new()).DownloadString("https://raw.githubusercontent.com/ssokka/Windows/master/header.ps1") }

try {
	$title = "반디집"
	$host.ui.RawUI.WindowTitle = $title
	Write-Host "`n### $title" -ForegroundColor Green
	
	$name = "Bandizip"
	$path = "$Env:ProgramFiles\$name"
	$exec = "$path\$name.exe"

	$site = "https://kr.bandisoft.com/bandizip"

	Write-Host "`n# 버전" -ForegroundColor Blue
	$cver = get-version $exec '(.*)\.0.*'
	$sver = get-version "$site/history" '(?is).*?<h2><.*?>v*(.*?)<.*'
	Write-Host "현재: $cver"
	Write-Host "최신: $sver"
	
	if ($cver -ne $sver) {
		$down = dw "$site/dl.php?web"
		Write-Host "`n# 설치" -ForegroundColor Blue
		Stop-Process -Name $name -Force -ErrorAction Ignore
		& $down /S | Out-Host
		Remove-Item -Path $down -Force -ErrorAction Ignore
	}
	
	Write-Host "`n# 설정" -ForegroundColor Blue
	$down = dw "$Git/$name/setting.reg" -wri $false
	Stop-Process -Name $name -Force -ErrorAction Ignore
	& regedit.exe /s $down | Out-Null | Out-Host
	Remove-Item -Path $down -Force -ErrorAction Ignore
	$edit = "$Env:ProgramFiles\Notepad++\notepad++.exe"
	if (Test-Path -Path $edit) { & reg.exe add "HKCU\SOFTWARE\$name" /v "editorPathName" /t REG_SZ /d $edit /f | Out-Null | Out-Host }
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
