﻿$ErrorActionPreference = 'Stop'

try {
	$name = 'Windows 터미널'
	$path = "$Env:ProgramFiles\WindowsApps\Microsoft.WindowsTerminal_1.18.10301.0_x64__8wekyb3d8bbwe"
	$exec = "$path\wt.exe"

	Write-Host -f Green "`n### $name 설정"
	$path = "$Env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
	$file = 'settings.json'
	$url = 'https://raw.githubusercontent.com/ssokka/Windows/master/WindowsTerminal'
	ni $path -it d -f -ea ig | Out-Null
	Start-BitsTransfer "$url/$file" "$path\$file"
	$str = ([Net.WebClient]::new()).DownloadString("$url\readme.md")
	$str -replace '(?is).*?설정 내용.*```(?:\r\n|\n)(.*?)(?:\r\n|\n)```.*','$1'

	Write-Host -f Green "`n### 완료"
}
catch {
	Write-Error ($_.Exception | fl -Force | Out-String)
	Write-Error ($_.InvocationInfo | fl -Force | Out-String)
}

Write-Host -n "`n아무 키나 누르십시오..."
Read-Host
