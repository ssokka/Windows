Invoke-Expression -Command ([Net.WebClient]::new()).DownloadString("https://raw.githubusercontent.com/ssokka/Windows/master/Script/ps/header.ps1")

try {
	$name = "Visual C++ 재배포 가능 패키지"
	
	$site = "https://api.github.com/repos/abbodi1406/vcredist/releases/latest"
	$surl = (Invoke-RestMethod -Uri $site | ForEach-Object assets | Where-Object name -like '*x64.exe').browser_download_url
	
    $inst = "$Global:Temp\$($surl -replace '.*/(.*)', '$1')"
	
	$host.ui.RawUI.WindowTitle = $name
	Write-Host "`n### $name" -ForegroundColor Green
	
	Write-Host "`n# 다운로드" -ForegroundColor Blue
    Start-BitsTransfer -Source $surl -Destination $inst
	
    Write-Host "`n# 설치" -ForegroundColor Blue
    ("/aiR /y", "/y") | ForEach-Object { Start-Process -NoNewWindow -Wait -FilePath $inst -ArgumentList $_ }
	
    Remove-Item -Path $inst -Force -ErrorAction Ignore
	
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
