Invoke-Expression ([Net.WebClient]::new()).DownloadString('https://raw.githubusercontent.com/ssokka/Windows/master/Script/ps/header.ps1')

$ErrorActionPreference = 'Stop'

try {
	$name = '터미널'
	$path = "$Env:ProgramFiles\WindowsApps\Microsoft.WindowsTerminal_1.18.10301.0_x64__8wekyb3d8bbwe"
	$exec = "$path\wt.exe"
	
    Write-Host -ForegroundColor Green "`n### $name 설정"
	$path = "$Env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
	$file = 'settings.json'
	$site = 'https://raw.githubusercontent.com/ssokka/Windows/master/Terminal'
	
	$null = reg.exe add 'HKCU\Console\%%Startup' /v 'DelegationConsole' /t REG_SZ /d '{2EACA947-7F5F-4CFA-BA87-8F7FBEEFBE69}' /f
	$null = reg.exe add 'HKCU\Console\%%Startup' /v 'DelegationTerminal' /t REG_SZ /d '{E12CFF52-A866-4C77-9A90-F570A7AA2C6B}' /f
	
	$null = New-Item $path -ItemType Directory -ErrorAction Ignore
	Start-BitsTransfer "$site/$file" "$path\$file"
	([Net.WebClient]::new()).DownloadString("$site\readme.md") -replace '(?is).*?설정.*?```(?:\r\n|\n)(.*?)(?:\r\n|\n)```.*','$1'
	
	Write-Host -ForegroundColor Green "`n### 완료"
}
catch {
	Write-Error ($_.Exception | Format-List -Force | Out-String)
	Write-Error ($_.InvocationInfo | Format-List -Force | Out-String)
}

Write-Host -n "`n아무 키나 누르십시오..."
Read-Host
