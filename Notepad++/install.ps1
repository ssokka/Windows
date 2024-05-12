Invoke-Expression ([Net.WebClient]::new()).DownloadString('https://raw.githubusercontent.com/ssokka/Windows/master/Script/ps/header.ps1')

try {
	$name = "Notepad++"
	$path = "$Env:ProgramFiles\$name"
	$exec = "$path\$name.exe"
	
	$site = "https://api.github.com/repos/notepad-plus-plus/notepad-plus-plus/releases/latest"
	$surl = (Invoke-RestMethod -Uri $site | ForEach-Object assets | Where-Object name -like '*.x64.exe').browser_download_url
	
	$gurl = "https://raw.githubusercontent.com/ssokka/Windows/master/$name"
	
	$host.ui.RawUI.WindowTitle = $name
	Write-Host "`n### $name" -ForegroundColor Green
	
	Write-Host "`n# 버전" -ForegroundColor Blue
	$cver = "$((Get-Item -Path $exec -ErrorAction Ignore).VersionInfo.FileVersion)".Trim()
	$sver = "$(((Invoke-RestMethod -Uri $site).tag_name) -replace '(?i)v','')".Trim()
	Write-Host "현재: $cver"
	Write-Host "최신: $sver"
	
	if ($cver -ne $sver) {
		Write-Host "`n# 다운로드" -ForegroundColor Blue
		$file = "$Env:Temp\$($surl -replace '.*/(.*)', '$1')"
		Start-BitsTransfer -Source $surl -Destination $file
		Write-Host "`n# 설치" -ForegroundColor Blue
		Stop-Process -Name $name -Force -ErrorAction Ignore
		Start-Process -NoNewWindow -Wait -FilePath $file -ArgumentList "/S"
		Remove-Item -Path $file -Force -ErrorAction Ignore
	}
	
	# https://github.com/notepad-plus-plus/nppPluginList/blob/master/doc/plugin_list_x64.md
	Write-Host "`n# 플러그인 설치" -ForegroundColor Blue
	Stop-Process -Name $name -Force -ErrorAction Ignore
	function InstallPlugin {
		[Alias("ip")]
		param(
			[Parameter(Mandatory=$true)]
			[string]$p,	# path
			[string]$r,	# repos
			[string]$t	# title
		)
		$ErrorActionPreference = "Ignore"
		if(!(Test-Path -Path "$path\plugins\$p\*.dll")){
			Write-Host "$t"
			$null = New-Item -Path "$path\plugins\$p" -ItemType Directory
			if ($r -match '^http') {
				$req = [Net.WebRequest]::Create($r)
				$req.AllowAutoRedirect = $true
				$gfn = [IO.Path]::GetFileName($req.GetResponse().ResponseUri.AbsolutePath)
				$rurl = $r
				$file = "$path\plugins\$p\$gfn"
			} else {
				$rurl = (Invoke-RestMethod -Uri https://api.github.com/repos/$r/releases/latest | ForEach-Object assets | Where-Object name -like '*x64.zip').browser_download_url
				$file = "$path\plugins\$p\$($rurl -replace '.*/(.*)', '$1')"
			}
			Start-BitsTransfer -Source $rurl -Destination $file
			Expand-Archive -Path $file -DestinationPath "$path\plugins\$p" -Force
			Remove-Item -Path $file -Force
		}
	}
	ip "ComparePlus" "pnedev/ComparePlus" "ComparePlus"
	ip "_CustomizeToolbar" "https://sourceforge.net/projects/npp-customize/files/latest/download" "Customize Toolbar"
	ip "Explorer" "oviradoi/npp-explorer-plugin" "Explorer"
	ip "HexEditor" "chcg/NPP_HexEdit" "HexEditor"
	ip "NppExec" "d0vgan/nppexec" "NppExec"
	ip "NPPJSONViewer" "kapilratnani/JSON-Viewer" "JSON Viewer"
	ip "XMLTools" "morbac/xmltools" "XML Tools"
	
	Write-Host "`n# 설정" -ForegroundColor Blue
	$file = "config.xml"
	$path = "$Env:AppData\$name"
	$null = New-Item -Path $path -ItemType Directory -ErrorAction Ignore
	Start-BitsTransfer -Source "$gurl/$file" -Destination "$path\$file"
	$file = "Dracula.xml"
	$path = "$Env:AppData\$name\themes"
	$null = New-Item -Path $path -ItemType Directory -ErrorAction Ignore
	Start-BitsTransfer -Source "https://raw.githubusercontent.com/dracula/notepad-plus-plus/master/$file" -Destination "$path\$file"
	$file = "plugins-config.zip"
	$path = "$Env:AppData\$name\plugins\config"
	$null = New-Item -Path $path -ItemType Directory -ErrorAction Ignore
	Start-BitsTransfer -Source "$gurl/$file" -Destination "$path\$file"
	Expand-Archive -Path "$path\$file" -DestinationPath "$path" -Force
	Remove-Item -Path "$path\$file" -Force
	([Net.WebClient]::new()).DownloadString("$gurl/readme.md") -replace '(?is).*?설정.*?```(?:\r\n|\n)(.*?)(?:\r\n|\n)```.*', '$1'
	
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

	set-window
	Write-Host "`n### 완료" -ForegroundColor Green
}
catch {
	Write-Error ($_.Exception | Format-List -Force | Out-String) -ErrorAction Continue
	Write-Error ($_.InvocationInfo | Format-List -Force | Out-String) -ErrorAction Continue
	throw
}

Write-Host "`n아무 키나 누르십시오..." -NoNewline
Read-Host
