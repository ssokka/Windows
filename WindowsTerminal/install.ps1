$ErrorActionPreference = 'Stop'

try {
	$name = 'Windows 터미널'
	$path = "$Env:ProgramFiles\WindowsApps\Microsoft.WindowsTerminal_1.18.10301.0_x64__8wekyb3d8bbwe"
	$exec = "$path\wt.exe"
	
	Write-Host -f Green "`n### $name 기본 설정"
	$path = "$Env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
	$file = 'settings.json'
	ni $path -it d -f -ea ig | Out-Null
	Start-BitsTransfer "https://raw.githubusercontent.com/ssokka/Windows/master/WindowsTerminal/$file" "$path\$file"
    
	Write-Host -f Green "`n### 완료"
}
catch {
	Write-Error ($_.Exception | fl -Force | Out-String)
	Write-Error ($_.InvocationInfo | fl -Force | Out-String)
}

Write-Host -n "`n아무 키나 누르십시오..."
Read-Host
