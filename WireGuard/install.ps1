Invoke-Expression -Command ([Net.WebClient]::new()).DownloadString("https://raw.githubusercontent.com/ssokka/Windows/master/header.ps1")

try {
	$name = "WireGuard"
	$path = "$Env:ProgramFiles\$name"
	$exec = "$path\$name.exe"
	$gurl = "https://raw.githubusercontent.com/ssokka/Windows/master/$name"
	
	$site = "https://download.wireguard.com/windows-client"
	$sexe = "wireguard-installer.exe"
	$spat = '(?is).*wireguard-amd64-(.*?)(?:\.msi).*'
	
	$host.ui.RawUI.WindowTitle = $name
	Write-Host "`n### $name" -ForegroundColor Green
	
	Write-Host "`n# 버전" -ForegroundColor Blue
	$cver = "$((Get-Item -Path $exec -ErrorAction Ignore).VersionInfo.FileVersion -replace '(.*)\.0', '$1')".Trim()
	$wc = New-Object System.Net.WebClient
	$wc.Headers["User-Agent"] = $UserAgent
	$sver = "$($wc.DownloadString($site) -replace $spat, '$1')".Trim()
	Write-Host "현재: $cver"
	Write-Host "최신: $sver"
	
	if ($cver -ne $sver) {
		Write-Host "`n# 다운로드" -ForegroundColor Blue
		Start-BitsTransfer -Source "$site/$sexe" -Destination "$Env:TEMP\$sexe"
		Write-Host "`n# 설치" -ForegroundColor Blue
		Start-Process -Wait -FilePath "$Env:TEMP\$sexe"
		Remove-Item -Path "$Env:TEMP\$sexe" -Force -ErrorAction Ignore
		do {
			Start-Sleep -Milliseconds 250
		} until ($proc = Get-Process | Where-Object { $_.ProcessName -eq "wireguard" -and $_.MainWindowTitle -eq "WireGuard" })
		$proc.Kill()
		set-window
	}
	
	set-window
	Write-Host "`n# 설정" -ForegroundColor Blue
	$menu = ("회사 클라이언트","개인 클라이언트","회사 서버","개인 서버","종료")
	$menu | % { $i = 1 } {
		$def = ""
		if ($i -eq 1) { $def = " (기본)" }
		Write-Host "[$i] $_$def"
		$i++
	}
	Write-Host "선택: " -NoNewline
	$dread = 1
	$LastConsoleLine = 0
	while ($true) {
		$x, $y = [Console]::CursorLeft, [Console]::CursorTop
		$read = if ($nread = Read-Host) { $nread } else { $dread }
		if ($read -match "^[1-$($menu.count)]$") { break } else { ccp $x $y }
	}
	switch ($read) {
		{ 1, 3 -eq $_ } { $file = "company.7z" }
		{ 2, 4 -eq $_ } { $file = "private.7z" }
		5 { exit }
	}
	
	set-window
	Write-Host "`n# $($menu[$read-1])" -ForegroundColor Blue
	$zip = "$Env:TEMP\$file"
	install-7zip
	Start-BitsTransfer -Source "$gurl/$file" -Destination $zip
	$ext = (Get-Item -Path $zip).Basename
	$null = New-Item -Path "$Env:TEMP\$name\$ext" -ItemType "directory" -ErrorAction Ignore
	Write-Host "암호: " -NoNewline
	$LastConsoleLine = 0
	while ($true) {
		$x, $y = [Console]::CursorLeft, [Console]::CursorTop
		Expand-7Zip -ArchiveFileName $zip -TargetPath "$Env:TEMP\$name\$ext" -SecurePassword (Read-Host -AsSecureString) -ErrorAction Ignore
		if ($?) { break } else { ccp $x $y }
	}
	Remove-Item -Path $zip -Force -ErrorAction Ignore
	
	set-window
	switch($read) {
		{ 1, 2 -eq $_ } {
			Write-Host "`n# IP" -ForegroundColor Blue
			Write-Host "[ 2~10] 서버`n[11~20] 사용자 #1`n[21~30] 사용자 #2"
			Write-Host "선택: " -NoNewline
			$LastConsoleLine = 0
			while ($true) {
				$x, $y = [Console]::CursorLeft, [Console]::CursorTop
				$ip = Read-Host
				if ($ip -In 2 .. 100) { break } else { ccp $x $y }
			}
			$like = "wg-*-client-$ip.conf"
		}
		{ 3, 4 -eq $_ } {
			$like = "wg-server.conf"
		}
	}
	$conf = Get-ChildItem -Path "$Env:TEMP\$name\$ext" | Where-Object { $_.Name -like $like }
	Start-Process -Wait -WindowStyle Hidden -FilePath "$Env:ComSpec" -ArgumentList "/c del /q `"$path\Data\Configurations\$conf*`""
	Copy-Item -Path "$Env:TEMP\$name\$ext\$conf" "$path\Data\Configurations\" -Force
	Copy-Item -Path "$Env:TEMP\$name\$ext\*.cmd" "$path\" -Force -ErrorAction Ignore
	Remove-Item -Path "$Env:TEMP\$name" -Recurse -Force
	Remove-Item -Path "$path\drive.cmd" -Recurse -Force -ErrorAction Ignore
	
	("wg.ps1", "wg.cmd") | ForEach-Object { Start-BitsTransfer -Source "$gurl/$_" -Destination "$path\$_" }
	if (Test-Path -Path "$path\wg.cmd") {
		Write-Host "`n# 실행" -ForegroundColor Blue
		Unregister-ScheduledTask -TaskName $name -Confirm:$false -ErrorAction Ignore
		Register-ScheduledTask -TaskName $name -Action (New-ScheduledTaskAction -Execute "$path\wg.cmd" -Argument "on") -Force | Out-Null
		Start-ScheduledTask -TaskName $name | Out-Null
		Unregister-ScheduledTask -TaskName $name -Confirm:$false
		do {
			Start-Sleep -Milliseconds 250
			$proc = Get-Process -ErrorAction Ignore | Where-Object { $_.mainWindowTitle -eq "$name On" }
		} until ($proc)
		set-window ($proc).Id
		do {
			Start-Sleep -Milliseconds 250
		} until (!(Get-Process | Where-Object { $_.mainWindowTitle -eq "$name On" }))
		set-window
		Write-Host "`n# 시작 화면에 고정" -ForegroundColor Blue
		pt start "WG-On" "$path\wg.cmd" on "$path\$name.exe"
		pt start "WG-Off" "$path\wg.cmd" off "$path\$name.exe"
	}
	
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
