iex ([Net.WebClient]::new()).DownloadString('https://raw.githubusercontent.com/ssokka/Windows/master/Script/ps/header.ps1')

$ErrorActionPreference = 'Stop'

try {
	$name = 'Notepad++'
	$path = "$Env:ProgramFiles\$name"
	$exec = "$path\notepad++.exe"
	
	$host.ui.RawUI.WindowTitle = $name

	Write-Host -f Green "`n### $name 버전"
	$cver = "$((gi $exec -ea ig).VersionInfo.FileVersion)".Trim()
	$site = "https://api.github.com/repos/notepad-plus-plus/notepad-plus-plus/releases/latest"
	$rver = "$(((irm $site).tag_name) -replace '(?i)v','')".Trim()
	$rurl = (irm $site | % assets | ? name -like '*.x64.exe').browser_download_url
	Write-Host "현재: $cver"
	Write-Host "최신: $rver"
	
	if ($cver -ne $rver) {
		Write-Host -f Green "`n### $name 설치"
		$file = "$Env:TEMP\$($rurl -replace '.*/(.*)','$1')"
		Start-BitsTransfer $rurl $file
		spps -n $name -f -ea ig
		start -n -wait $file '/S'
		ri $file -Force -ea ig
	}

	spps -n $name -f -ea ig

	Write-Host -f Green "`n### $name 플러그인 설치"
	# https://github.com/notepad-plus-plus/nppPluginList/blob/master/doc/plugin_list_x64.md
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
			Write-Host "$t"
			$repo = "pnedev/$($name[1])"
			ni "$path\plugins\$n" -it d -ea ig | Out-Null
			$rurl = (irm https://api.github.com/repos/$r/releases/latest | % assets | ? name -like '*x64.zip').browser_download_url
			$file = "$path\plugins\$n\$($rurl -replace '.*/(.*)','$1')"
			Start-BitsTransfer $rurl $file
			Expand-Archive $file -d "$path\plugins\$n" -f
			ri $file -Force
		}
	}
	ip -n 'ComparePlus' -r 'pnedev/ComparePlus' -t 'ComparePlus'
	ip -n 'Explorer' -r 'oviradoi/npp-explorer-plugin' -t 'Explorer'
	ip -n 'HexEditor' -r 'chcg/NPP_HexEdit' -t 'HexEditor'
	ip -n 'NppExec' -r 'd0vgan/nppexec' -t 'NppExec'
	ip -n 'NPPJSONViewer' -r 'kapilratnani/JSON-Viewer' -t 'JSON Viewer'
	ip -n 'XMLTools' -r 'morbac/xmltools' -t 'XML Tools'
	
	Write-Host -f Green "`n### $name 설정"
	$site = 'https://raw.githubusercontent.com/ssokka/Windows/master/Notepad%2B%2B'
	
	$path = "$Env:AppData\$name"
	$file = 'config.xml'
	$null = ni $path -it d -f -ea ig
	Start-BitsTransfer "$site/$file" "$path\$file"

	$path = "$Env:AppData\$name\themes"
	$file = 'Dracula.xml'
	$null = ni $path -it d -f -ea ig
	Start-BitsTransfer "https://raw.githubusercontent.com/dracula/notepad-plus-plus/master/$file" "$path\$file"

	([Net.WebClient]::new()).DownloadString("$site\readme.md") -replace '(?is).*?설정.*?```(?:\r\n|\n)(.*?)(?:\r\n|\n)```.*','$1'

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
