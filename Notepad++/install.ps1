$path = "$Env:ProgramFiles\Notepad++"

if(!(Test-Path "$path\notepad++.exe")){
	echo "`n### Notepad++ 설치"
	irm https://api.github.com/repos/notepad-plus-plus/notepad-plus-plus/releases/latest | % assets | ? name -like '*.x64.exe' | % { iwr $_.browser_download_url -o (Join-Path $Env:TEMP $_.name) }
	start -wait (Get-Item "$Env:TEMP\npp*.x64.exe") '/S'
}

spps -n 'Notepad++' -ea ig

$name = 'Compare', 'ComparePlus'
if(!(Test-Path "$path\plugins\$($name[1])")){
	$repo = "pnedev/$($name[1])"
	echo "`n### Notepad++ 플러그인 - $($name[0]) 설치"
	ni "$path\plugins\$($name[1])" -it d -ea ig | Out-Null
	$info = irm https://api.github.com/repos/$repo/releases/latest | % assets | ? name -like '*x64.zip'
	iwr $($info.browser_download_url) -o "$path\plugins\$($name[1])\$($info.name)"
	Expand-Archive "$path\plugins\$($name[1])\$($info.name)" -d "$path\plugins\$($name[1])" -f
	ri "$path\plugins\$($name[1])\$($info.name)" -ea ig
}

$name = 'JSON Viewer', 'NPPJSONViewer'
if(!(Test-Path "$path\plugins\$($name[1])")){
	$repo = "kapilratnani/JSON-Viewer"
	echo "`n### Notepad++ 플러그인 - $($name[0]) 설치"
	ni "$path\plugins\$($name[1])" -it d -ea ig | Out-Null
	$info = irm https://api.github.com/repos/$repo/releases/latest | % assets | ? name -like '*x64.zip'
	iwr $($info.browser_download_url) -o "$path\plugins\$($name[1])\$($info.name)"
	Expand-Archive "$path\plugins\$($name[1])\$($info.name)" -d "$path\plugins\$($name[1])" -f
	ri "$path\plugins\$($name[1])\$($info.name)" -ea ig
}

$path = "$Env:AppData\Notepad++"

echo "`n### Notepad++ 기본 설정"
$file = 'config.xml'
ni "$path" -it 'directory' -ea ig | Out-Null
iwr https://raw.githubusercontent.com/ssokka/Windows/master/Notepad%2B%2B/config.xml -o "$path\$file"

echo "`n### Notepad++ 테마 설정"
$file = 'Dracula.xml'
ni "$path\themes" -it 'directory' -ea ig | Out-Null
iwr https://raw.githubusercontent.com/dracula/notepad-plus-plus/master/$file -o "$path\themes\$file"

#$xml = [xml](Get-Content '$path\themes\$file')
#$node = $xml.NotepadPlus.GlobalStyles.WidgetStyle | where {$_.name -eq 'Global override'}
#$node.fontSize = '10'
#$xml.Save('$path\themes\$file')

#echo "`n### Notepad++ 파일 연결 (.log, .txt)"
#reg add 'HKLM\SOFTWARE\Classes\Notepad++_file' /ve /t REG_SZ /d 'Notepad++ Document' /f
#reg add 'HKLM\SOFTWARE\Classes\Notepad++_file\DefaultIcon' /ve /t REG_SZ /d '"%ProgramFiles%\Notepad++\notepad++.exe",0' /f
#reg add 'HKLM\SOFTWARE\Classes\Notepad++_file\shell\open\command' /ve /t REG_SZ /d '"%ProgramFiles%\Notepad++\notepad++.exe" "%%1"' /f
#reg add 'HKCU\Software\Classes\.log' /ve /t REG_SZ /d 'Notepad++_file' /f
#reg add 'HKCU\Software\Classes\.log' /v 'Notepad++_backup' /t REG_SZ /d 'txtfile' /f
#reg add 'HKCU\Software\Classes\.txt' /ve /t REG_SZ /d 'Notepad++_file' /f
#reg add 'HKCU\Software\Classes\.txt' /v 'Notepad++_backup' /t REG_SZ /d 'txtfile' /f

Start-Sleep -Milliseconds 500
echo ""
cmd /c pause
