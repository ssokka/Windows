param([bool]$wait = $true)

if (!(Get-Command -Name set-window -CommandType Function 2>$null)) { Invoke-Expression -Command ([Net.WebClient]::new()).DownloadString("https://raw.githubusercontent.com/ssokka/Windows/master/header.ps1") }

try {
	$name = "Xshell"
	$host.ui.RawUI.WindowTitle = $name
	Write-Host "`n### $name" -ForegroundColor Green
	Write-Host "`n# 복원" -ForegroundColor Blue
	$down = dw "$Git/$name/restore.7z" -wri $false
	. "$Temp\restore.ps1"
	
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
