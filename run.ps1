param(
	[string]$pname,
	[string]$tname,
	[string]$sname,
	[string]$fname,
	[bool]$wait = $true
)

if (!(Get-Command -Name set-window -CommandType Function 2>$null)) { Invoke-Expression -Command ([Net.WebClient]::new()).DownloadString("https://raw.githubusercontent.com/ssokka/Windows/master/header.ps1") }

try {
	$host.ui.RawUI.WindowTitle = $tname
	Write-Host "`n### $tname" -ForegroundColor Green
	Write-Host "`n# $sname" -ForegroundColor Blue
	$down = dw "$Git/$pname/$fname.7z" -wri $false
	. "$Temp\fname.ps1"
	
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
