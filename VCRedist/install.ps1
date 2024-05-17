param([bool]$wait = $true)

if (!(Get-Command -Name set-window -CommandType Function 2>$null)) { Invoke-Expression -Command ([Net.WebClient]::new()).DownloadString("https://raw.githubusercontent.com/ssokka/Windows/master/header.ps1") }

try {
	$title = "Visual C++ 재배포 가능 패키지"
	$host.ui.RawUI.WindowTitle = $title
	Write-Host "`n### $title" -ForegroundColor Green
	
	$site = "https://api.github.com/repos/abbodi1406/vcredist/releases/latest"
	$down = dw $site -pat '*x64.exe'
	
    Write-Host "`n# 설치" -ForegroundColor Blue
    ("/aiR /y", "/y") | ForEach-Object { & $down $_ }
    Remove-Item -Path $down -Force -ErrorAction Ignore
	
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
