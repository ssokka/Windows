param([bool]$wait = $true)

if (!(Get-Command -Name set-window -CommandType Function 2>$null)) { Invoke-Expression -Command ([Net.WebClient]::new()).DownloadString("https://raw.githubusercontent.com/ssokka/Windows/master/header.ps1") }

try {
	$title = "Xshell"
	$host.ui.RawUI.WindowTitle = $title
	Write-Host "`n### $title" -ForegroundColor Green
	
	$name = $title
	$rkey = "HKLM:\SOFTWARE\WOW6432Node\NetSarang\Xshell"
	$skey = (Get-ChildItem -Path $rkey -ErrorAction Ignore).Name | Sort-Object -Descending | Select-Object -First 1
	$skey = $skey -replace 'HKEY_LOCAL_MACHINE', 'HKLM:'
	$path = Get-ItemPropertyValue -Path $skey -Name "Path" -ErrorAction Ignore
	$cver = Get-ItemPropertyValue -Path $skey -Name "Version" -ErrorAction Ignore
	$exec = "$path\$name.exe"
	$mver = $skey -replace '.*\\(.*)', '$1'
	
	$site = "https://www.filehorse.com/download-xshell-free/download/"
	
	Write-Host "`n# 버전" -ForegroundColor Blue
	$sver = get-version $site '(?is).*?Xshell Free (\d+\.\d+) Build (\d+).*' '$1.$2'
	Write-Host "현재: $cver"
	Write-Host "최신: $sver"
	
	if ($cver -ne $sver) {
		$down = dw $([Net.WebClient]::new().DownloadString($site) -replace '(?is).*(https://www.filehorse.com/download/file/.*?)".*', '$1')
		Write-Host "`n# 설치" -ForegroundColor Blue
		$mver = $down -replace '.*?Xshell-(\d+).*', '$1'
		"uninstall.iss", "install.iss" | ForEach-Object {
			Start-BitsTransfer -Source "$Git/$name/$_" -Destination "$Temp\$_"
			(Get-Content "$Temp\$_") -replace "$name \d+", "$name $mver" | Out-File "$Temp\$_" -Encoding ASCII
			& $down -s -f1"$Temp\$_" | Out-Null | Out-Host
			Remove-Item -Path $_ -Force -ErrorAction Ignore
		}
		Remove-Item -Path $down -Force -ErrorAction Ignore
		$path = Get-ItemPropertyValue -Path $rkey\$mver -Name "Path" -ErrorAction Ignore
		$exec = "$path\$name.exe"
	}
	
	Write-Host "`n# 설정" -ForegroundColor Blue
	Stop-Process -Name $name -Force -ErrorAction Ignore
	
	$rkey = "HKCU\Software\NetSarang\Xshell\$mver\Layout\current"
	& reg.exe add $rkey /v "AddressBar" /t REG_DWORD /d "0" /f | Out-Null | Out-Host
	& reg.exe add $rkey /v "LinksBar" /t REG_DWORD /d "0" /f | Out-Null | Out-Host
	& reg.exe add $rkey /v "ComposePane" /t REG_DWORD /d "1" /f | Out-Null | Out-Host
	
	$pudf = (Get-ItemPropertyValue -Path "HKCU:\Software\NetSarang\Common\$mver\UserData" -Name "UserDataPath" -ErrorAction Ignore) + "\$name"
	$file = "$pudf\$name.ini"
	if (!(Test-Path -Path $pudf)) { New-Item -Path $pudf -ItemType Directory -Force | Out-Null }
	if (!(Test-Path -Path $file)) { "" | Out-File -FilePath $file -Encoding BigEndianUnicode }
	install-psini
	$ini = Get-IniContent $file
	"SearchEngineList", "XshellOptions" | ForEach-Object { if($ini[$_] -eq $null) { $ini[$_] = @{ } } }
	$ini["SearchEngineList"]["Count"] = 4
	$ini["SearchEngineList"]["DefaultSearchEngine"] = 0
	$ini["SearchEngineList"]["SearchEngine0.Name"] = "구글"
	$ini["SearchEngineList"]["SearchEngine0.PercentEncoding"] = 1
	$ini["SearchEngineList"]["SearchEngine0.Query"] = "https://www.google.com/search?q=%s"
	$ini["SearchEngineList"]["SearchEngine1.Name"] = "네이버"
	$ini["SearchEngineList"]["SearchEngine1.PercentEncoding"] = 1
	$ini["SearchEngineList"]["SearchEngine1.Query"] = "https://search.naver.com/search.naver?query=%s"
	$ini["SearchEngineList"]["SearchEngine2.Name"] = "다음"
	$ini["SearchEngineList"]["SearchEngine2.PercentEncoding"] = 1
	$ini["SearchEngineList"]["SearchEngine2.Query"] = "https://search.daum.net/search?q=%s"
	$ini["SearchEngineList"]["SearchEngine3.Name"] = "Bing"
	$ini["SearchEngineList"]["SearchEngine3.PercentEncoding"] = 1
	$ini["SearchEngineList"]["SearchEngine3.Query"] = "https://www.bing.com/search?q=%s"
	$ini["XshellOptions"]["ShowProfileDlgAtStartUp"] = 0
	$edit = "$Env:ProgramFiles\Notepad++\notepad++.exe"
	if (Test-Path -Path $edit) {
		$ini["XshellOptions"]["UseNotepad"] = 0
		$ini["XshellOptions"]["TextEditorPath"] = $edit
		$ini["XshellOptions"]["TextEditorName"] = "Notepad++"
	}
	Out-IniFile -InputObject $ini -FilePath $file -Force
	
	function ini-replace {
		[Alias("ir")]
		param (
			[string] $file,
			[string] $name,
			[string] $data
		)
		if (!(Test-Path -Path $file)) { return }
		(Get-Content -Path $file) -Replace "^$name=.*?$", "$name=$data" | Set-Content $file
	}
	Get-ChildItem -Path "$pudf\Sessions" -Include ("default", "*.xsh") -Recurse | ForEach-Object {
		ir $_.FullName "SaveHostKey" "1"
		ir $_.FullName "SendKeepAlive" "1"
		ir $_.FullName "SendKeepAliveInterval" "290"
		ir $_.FullName "KeepAliveString" " "
		ir $_.FullName "TCPKeepAlive" "1"
		ir $_.FullName "Type" "linux"
		ir $_.FullName "ScrollbackSize" "200000"
		ir $_.FullName "ColorScheme" "New Black"
		ir $_.FullName "FontFace" "Consolas"
		ir $_.FullName "AsianFont" "Consolas"
		ir $_.FullName "FontQuality" "6"
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
