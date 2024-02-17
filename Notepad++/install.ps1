$path = "$Env:ProgramFiles\Notepad++"

if(!(Test-Path "$path\notepad++.exe")){
	echo "`n### Notepad++ 설치"
	irm https://api.github.com/repos/notepad-plus-plus/notepad-plus-plus/releases/latest | % assets | ? name -l '*.x64.exe' | % { iwr $_.browser_download_url -o (Join-Path $Env:TEMP $_.name) }
	start -wait (Get-Item "$Env:TEMP\npp*.x64.exe") '/S'
}

spps 'Notepad++'

$title = 'Compare'
$name = 'ComparePlus'
if(!(Test-Path "$path\plugins\$name")){
	echo "`n### Notepad++ 플러그인 - $title 설치"
	ni "$path\plugins\$name" -it d -ea ig
	$repo = "pnedev/$name"
	$info = irm https://api.github.com/repos/$repo/releases/latest | % assets | ? name -like '*x64.zip'
	iwr $($info.browser_download_url) -o "$path\plugins\$name\$($info.name)"
	Expand-Archive "$path\plugins\$name\$($info.name)" -d "$path\plugins\$name" -f
	ri "$path\plugins\$name\$($info.name)" -ea ig
}

$title = 'JSON Viewer'
$name = 'NPPJSONViewer'
if(!(Test-Path "$path\plugins\$name")){
	echo "`n### Notepad++ 플러그인 - $title 설치"
	ni "$path\plugins\$name" -it d -ea ig
	$repo = "kapilratnani/JSON-Viewer"
	$info = irm https://api.github.com/repos/$repo/releases/latest | % assets | ? name -like '*x64.zip'
	iwr $($info.browser_download_url) -o "$path\plugins\$name\$($info.name)"
	Expand-Archive "$path\plugins\$name\$($info.name)" -d "$path\plugins\$name" -f
	ri "$path\plugins\$name\$($info.name)" -ea ig
}

$path = "$Env:AppData\Notepad++"

echo "`n### Notepad++ 기본 설정"
$file = 'config.xml'
iwr https://raw.githubusercontent.com/ssokka/Windows/master/Notepad%2B%2B/config.xml -o "$path\$file"

echo "`n### Notepad++ 테마 설정"
$file = 'Dracula.xml'
ni "$path\themes" -it 'directory' -ea ig
iwr https://raw.githubusercontent.com/dracula/notepad-plus-plus/master/$file -o "$path\themes\$file"

#$xml = [xml](Get-Content '$path\themes\$file')
#$node = $xml.NotepadPlus.GlobalStyles.WidgetStyle | where {$_.name -eq 'Global override'}
#$node.fontSize = '10'
#$xml.Save('$path\themes\$file')

echo "`n### Notepad++ 파일 연결 (.log, .txt)"
reg add 'HKLM\SOFTWARE\Classes\Notepad++_file' /ve /t REG_SZ /d 'Notepad++ Document' /f
reg add 'HKLM\SOFTWARE\Classes\Notepad++_file\DefaultIcon' /ve /t REG_SZ /d '"%ProgramFiles%\Notepad++\notepad++.exe",0' /f
reg add 'HKLM\SOFTWARE\Classes\Notepad++_file\shell\open\command' /ve /t REG_SZ /d '"%ProgramFiles%\Notepad++\notepad++.exe" "%%1"' /f
reg add 'HKCU\Software\Classes\.log' /ve /t REG_SZ /d 'Notepad++_file' /f
reg add 'HKCU\Software\Classes\.log' /v 'Notepad++_backup' /t REG_SZ /d 'txtfile' /f
reg add 'HKCU\Software\Classes\.txt' /ve /t REG_SZ /d 'Notepad++_file' /f
reg add 'HKCU\Software\Classes\.txt' /v 'Notepad++_backup' /t REG_SZ /d 'txtfile' /f

Start-Sleep -Milliseconds 500
echo ""
cmd /c pause
