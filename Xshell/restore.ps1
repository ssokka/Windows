if (!(Get-Command -Name set-window -CommandType Function 2>$null)) { Invoke-Expression -Command ([Net.WebClient]::new()).DownloadString("https://raw.githubusercontent.com/ssokka/Windows/master/header.ps1") }

try {
	$down = dw "$Git/Xshell/restore.7z" -wri $false
	Start-Process -Verb RunAs -Wait -FilePath wt.exe -ArgumentList "powershell.exe", "$Temp\restore.ps1"
}
catch {
	Write-Error ($_.Exception | Format-List -Force | Out-String) -ErrorAction Continue
	Write-Error ($_.InvocationInfo | Format-List -Force | Out-String) -ErrorAction Continue
	throw
}
