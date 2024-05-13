Invoke-Expression -Command ([Net.WebClient]::new()).DownloadString("https://raw.githubusercontent.com/ssokka/Windows/master/Script/ps/header.ps1")

try {
	$name = "Bandizip"
	$path = "$Env:ProgramFiles\$name"
	$exec = "$path\$name.exe"
	$gurl = "https://raw.githubusercontent.com/ssokka/Windows/master/$name"
	
	$site = "https://kr.bandisoft.com/bandizip"
	$surl = "$site/dl.php?web"
    $sexe = "BANDIZIP-SETUP-STD-X64.EXE"
    $spat = '(?is).*?<h2><.*?>v*(.*?)<.*'
	
	$host.ui.RawUI.WindowTitle = $name
	Write-Host "`n### $name" -ForegroundColor Green
	
	Write-Host "`n# 버전" -ForegroundColor Blue
	$cver = "$((Get-Item -Path $exec -ErrorAction Ignore).VersionInfo.FileVersion -replace '(.*)\.0.*', '$1')".Trim()
	$wc = New-Object System.Net.WebClient
	$wc.Headers["User-Agent"] = $UserAgent
	$sver = "$($wc.DownloadString("$site/history") -replace $spat, '$1')".Trim()
	Write-Host "현재: $cver"
	Write-Host "최신: $sver"
	
	if ($cver -ne $sver) {
		Write-Host "`n# 다운로드" -ForegroundColor Blue
		$file = "$Env:Temp\$sexe"
		Start-BitsTransfer -Source $surl -Destination $file
		Write-Host "`n# 설치" -ForegroundColor Blue
		Stop-Process -Name $name -Force -ErrorAction Ignore
		Start-Process -NoNewWindow -Wait -FilePath $file -ArgumentList "/S"
		Remove-Item -Path $file -Force -ErrorAction Ignore
	}
	
	Write-Host "`n# 설정" -ForegroundColor Blue
	Start-BitsTransfer -Source "$gurl/$name.reg" -Destination "$Env:Temp\$name.reg"
    Start-Process -NoNewWindow -Wait -FilePath regedit.exe -ArgumentList "/s `"$Env:Temp\$name.reg`""
    Remove-Item -Path "$Env:Temp\$name.reg" -Force -ErrorAction Ignore
    ([Net.WebClient]::new()).DownloadString("$gurl/readme.md") -replace '(?is).*?### 설정.*?```(?:\r\n|\n)(.*?)(?:\r\n|\n)```.*', '$1'
	
    set-window
	Write-Host "`n### 완료" -ForegroundColor Green
}
catch {
	Write-Error ($_.Exception | Format-List -Force | Out-String) -ErrorAction Continue
	Write-Error ($_.InvocationInfo | Format-List -Force | Out-String) -ErrorAction Continue
	throw
}

Write-Host "`n아무 키나 누르십시오..." -NoNewline
Read-Host
