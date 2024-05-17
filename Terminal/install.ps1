param([bool]$wait = $true)

if (!(Get-Command -Name set-window -CommandType Function 2>$null)) { Invoke-Expression -Command ([Net.WebClient]::new()).DownloadString("https://raw.githubusercontent.com/ssokka/Windows/master/header.ps1") }

try {
	if (!(Test-Path -Path "$Env:LocalAppData\Microsoft\WindowsApps\wt.exe")) { exit }
	
	$title = "터미널"
	$host.ui.RawUI.WindowTitle = $title
    Write-Host "`n### $title" -ForegroundColor Green
	
	$name = $title
	$path = "$Env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
	
	function edit {
		param([object]$j, [string]$n, $v)
		$p = $n -Split "\."
		If ($p.Count -gt 1) {
			$o = New-Object PSCustomObject
			edit $o ($p[1..($p.count - 1)] -join ".") $v
		} else {
			$o = $v
		}
		$j | Add-Member -MemberType NoteProperty -Name $p[0] -Value $o -Force
	}
	
	Write-Host "`n# 설정" -ForegroundColor Blue
	
	# 기본 터미널 응용 프로그램 : Windows 터미널
	& reg.exe add 'HKCU\Console\%%Startup' /v 'DelegationConsole' /t REG_SZ /d '{2EACA947-7F5F-4CFA-BA87-8F7FBEEFBE69}' /f | Out-Null | Out-Host
	& reg.exe add 'HKCU\Console\%%Startup' /v 'DelegationTerminal' /t REG_SZ /d '{E12CFF52-A866-4C77-9A90-F570A7AA2C6B}' /f | Out-Null | Out-Host
	
	$json = "$path\settings.json"
	$obj = Get-Content $json -Raw | ConvertFrom-Json
	edit $obj "defaultProfile" "{0caa0dad-35be-5f56-a8ff-afceeeaa6101}"
	edit $obj "windowingBehavior" "useExisting"
	edit $obj "copyOnSelect" $true
	edit $obj "disableAnimations" $true
	edit $obj.profiles.defaults "font.face" "Consolas"
	edit $obj.profiles.defaults.font "size" 10
	edit $obj.profiles.defaults "antialiasingMode" "cleartype"
	edit $obj.profiles.defaults "historySize" 2147483647
	$obj | ConvertTo-Json -Depth 4 | Set-Content -Path $json -Encoding utf8
	
	$json = "$path\state.json"
	$obj = Get-Content $json -Raw -ErrorAction Ignore | ConvertFrom-Json
	$v = "closeOnExitInfo"
	if (!($obj.dismissedMessages -contains $v)) {
		$obj.dismissedMessages += $v
		$obj | ConvertTo-Json -Depth 4 | Set-Content -Path $json -Encoding utf8
	}
	
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
