function set-consoleFontSize {
	param (
		[int16] $h
	)
	[int16] $w = 0
	[Win32API.Console]::SetSize($w, $h)
}

function set-consoleFontName {
	param (
		[string] $name
	)
	[Win32API.Console]::SetName($name)
}

$src = gc -raw (([Net.WebClient]::new()).DownloadData('https://raw.githubusercontent.com/ssokka/Windows/master/Script/psm/console.cs')))
add-type -typeDef $src

set-consoleFontName -name 'Consolas'

$ErrorActionPreference = 'Stop'

try {
	$name = 'Notepad++'
	$path = "$Env:ProgramFiles\$name"
	$exec = "$path\notepad++.exe"
	
	Write-Host -f Green "`n### $name 버전 확인"
	$cver = "$((gi $exec -ea ig).VersionInfo.FileVersion)".Trim()
	$site = "https://api.github.com/repos/notepad-plus-plus/notepad-plus-plus/releases/latest"
	$rver = "$(((irm $site).tag_name) -replace '(?i)v','')".Trim()
	$rurl = (irm $site | % assets | ? name -like '*.x64.exe').browser_download_url
	Write-Host "현재: $cver"
	Write-Host "최신: $rver"
	
	if ($cver -ne $rver) {
		Write-Host -f Green "`n### $name 다운로드"
		$file = "$Env:TEMP\$($rurl -replace '.*/(.*)','$1')"
		Start-BitsTransfer $rurl $file
		Write-Host -f Green "`n### $name 설치"
		spps -n $name -f -ea ig
		start -n -wait $file '/S'
		ri $file -Force -ea ig
	}

	spps -n $name -f -ea ig

	function InstallPlugin {
		[Alias("ip")]
		param(
			[Parameter(Mandatory=$true)]
			[string]$n,
			[string]$r,
			[string]$t
		)
		$ErrorActionPreference = 'Ignore'
		if(!(Test-Path "$path\plugins\$n")){
			Write-Host -f Green "`n### $name 플러그인 - $t 설치"
			$repo = "pnedev/$($name[1])"
			ni "$path\plugins\$n" -it d -ea ig | Out-Null
			$url = (irm https://api.github.com/repos/$r/releases/latest | % assets | ? name -like '*x64.zip').browser_download_url
			$file = "$path\plugins\$n\$($url -replace '.*/(.*)','$1')"
			Start-BitsTransfer $url $file
			Expand-Archive $file -d "$path\plugins\$n" -f
			ri $file -Force
		}
	}

	ip -n 'ComparePlus' -r 'pnedev/ComparePlus' -t 'Compare'
	ip -n 'NPPJSONViewer' -r 'kapilratnani/JSON-Viewer' -t 'JSON Viewer'
	
	$path = "$Env:AppData\$name"

	Write-Host -f Green "`n### $name 기본 설정"
	$path = "$Env:AppData\$name"
	$file = 'config.xml'
	ni $path -it d -f -ea ig | Out-Null
	Start-BitsTransfer "https://raw.githubusercontent.com/ssokka/Windows/master/Notepad%2B%2B/$file" "$path\$file"

	Write-Host -f Green "`n### $name 테마 설정"
	$path = "$Env:AppData\$name\themes"
	$file = 'Dracula.xml'
	ni $path -it d -f -ea ig | Out-Null
	Start-BitsTransfer "https://raw.githubusercontent.com/dracula/notepad-plus-plus/master/$file" "$path\$file"

	#$xml = [xml](Get-Content '$path\themes\$file')
	#$node = $xml.NotepadPlus.GlobalStyles.WidgetStyle | where {$_.name -eq 'Global override'}
	#$node.fontSize = '10'
	#$xml.Save('$path\themes\$file')

	#Write-Host -f Green "`n### $name 파일 연결 (.log, .txt)"
	#reg add 'HKLM\SOFTWARE\Classes\Notepad++_file' /ve /t REG_SZ /d 'Notepad++ Document' /f
	#reg add 'HKLM\SOFTWARE\Classes\Notepad++_file\DefaultIcon' /ve /t REG_SZ /d '"%ProgramFiles%\Notepad++\notepad++.exe",0' /f
	#reg add 'HKLM\SOFTWARE\Classes\Notepad++_file\shell\open\command' /ve /t REG_SZ /d '"%ProgramFiles%\Notepad++\notepad++.exe" "%%1"' /f
	#reg add 'HKCU\Software\Classes\.log' /ve /t REG_SZ /d 'Notepad++_file' /f
	#reg add 'HKCU\Software\Classes\.log' /v 'Notepad++_backup' /t REG_SZ /d 'txtfile' /f
	#reg add 'HKCU\Software\Classes\.txt' /ve /t REG_SZ /d 'Notepad++_file' /f
	#reg add 'HKCU\Software\Classes\.txt' /v 'Notepad++_backup' /t REG_SZ /d 'txtfile' /f

	Write-Host -f Green "`n### 완료"
}
catch {
	Write-Error ($_.Exception | fl -Force | Out-String)
	Write-Error ($_.InvocationInfo | fl -Force | Out-String)
}

Write-Host -n "`n아무 키나 누르십시오..."
Read-Host
