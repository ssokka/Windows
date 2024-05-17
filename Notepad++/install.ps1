param([bool]$wait = $true)

if (!(Get-Command -Name set-window -CommandType Function 2>$null)) { Invoke-Expression -Command ([Net.WebClient]::new()).DownloadString("https://raw.githubusercontent.com/ssokka/Windows/master/header.ps1") }

try {
	$title = "Notepad++"
	$host.ui.RawUI.WindowTitle = $title
	Write-Host "`n### $title" -ForegroundColor Green
	
	$name = $title
	$path = "$Env:ProgramFiles\$name"
	$exec = "$path\$name.exe"

	$site = "https://api.github.com/repos/notepad-plus-plus/notepad-plus-plus/releases/latest"

	Write-Host "`n# 버전" -ForegroundColor Blue
	$cver = get-version $exec
	$sver = get-version $site '(?i)v' ''
	Write-Host "현재: $cver"
	Write-Host "최신: $sver"
	
	if ($cver -ne $sver) {
		$down = dw $site -pat '*x64.exe'
		Write-Host "`n# 설치" -ForegroundColor Blue
		Stop-Process -Name $name -Force -ErrorAction Ignore
		& $down /S | Out-Host
		Remove-Item -Path $down -Force -ErrorAction Ignore
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
		if(Test-Path -Path "$path\plugins\$p\*.dll") { return }
		Write-Host "$t"
		New-Item -Path "$path\plugins\$p" -ItemType Directory | Out-Null
		dw "https://api.github.com/repos/$r/releases/latest" -ext "$path\plugins\$p" | Out-Null
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
	New-Item -Path $path -ItemType Directory -ErrorAction Ignore | Out-Null
	dw "$Git/$name/$file" "$path\$file" | Out-Null
	
	$file = "Dracula.xml"
	$path = "$Env:AppData\$name\themes"
	New-Item -Path $path -ItemType Directory -ErrorAction Ignore | Out-Null
	dw "https://raw.githubusercontent.com/dracula/notepad-plus-plus/master/$file" "$path\$file" | Out-Null
	
	$file = "plugins-config.zip"
	$path = "$Env:AppData\$name\plugins\config"
	New-Item -Path $path -ItemType Directory -ErrorAction Ignore | Out-Null
	dw "$Git/$name/$file" -ext $path | Out-Null
	
	([Net.WebClient]::new()).DownloadString("$gurl/readme.md") -replace '(?is).*?### 설정.*?```(?:\r\n|\n)(.*?)(?:\r\n|\n)```.*', '$1'
	
	#$xml = [xml](Get-Content '$path\themes\$file')
	#$node = $xml.NotepadPlus.GlobalStyles.WidgetStyle | where {$_.name -eq 'Global override'}
	#$node.fontSize = '10'
	#$xml.Save('$path\themes\$file')
	
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
