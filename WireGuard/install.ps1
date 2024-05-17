param([bool]$wait = $true)

if (!(Get-Command -Name set-window -CommandType Function 2>$null)) { Invoke-Expression -Command ([Net.WebClient]::new()).DownloadString("https://raw.githubusercontent.com/ssokka/Windows/master/header.ps1") }

try {
	$title = "WireGuard"
	$host.ui.RawUI.WindowTitle = $title
	Write-Host "`n### $title" -ForegroundColor Green
	
	$name = $title
	$path = "$Env:ProgramFiles\$name"
	$exec = "$path\$name.exe"
	
	$site = "https://download.wireguard.com/windows-client"
	$sexe = "wireguard-installer.exe"
	
	Write-Host "`n# 버전" -ForegroundColor Blue
	$cver = get-version $exec '(.*)\.0'
	$sver = get-version $site '(?is).*wireguard-amd64-(.*?)(?:\.msi).*'
	Write-Host "현재: $cver"
	Write-Host "최신: $sver"
	
	if ($cver -ne $sver) {
		$down = dw "$site/$sexe"
		Write-Host "`n# 설치" -ForegroundColor Blue
		& $down | Out-Host
		Remove-Item -Path $down -Force -ErrorAction Ignore
		do {
			Start-Sleep -Milliseconds 250
		} until ($proc = Get-Process | Where-Object { $_.ProcessName -eq $name -and $_.MainWindowTitle -eq $name })
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
	$Global:LastConsoleLine = 0
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
	$ext = "$Temp\$name\" + $file -replace '(.*)\..*', '$1'
	$down = dw "$Git/$name/$file" -ext $ext -wri $false
	Remove-Item -Path $down -Force -ErrorAction Ignore
	
	set-window
	switch($read) {
		{ 1, 2 -eq $_ } {
			Write-Host "`n# IP" -ForegroundColor Blue
			Write-Host "[11~20] 사용자 #1`n[21~30] 사용자 #2"
			Write-Host "선택: " -NoNewline
			$Global:LastConsoleLine = 0
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
	$conf = Get-ChildItem -Path $ext | Where-Object { $_.Name -like $like }
	Start-Process -Wait -WindowStyle Hidden -FilePath "$Env:ComSpec" -ArgumentList "/c del /q `"$path\Data\Configurations\$conf*`""
	Copy-Item -Path "$ext\$conf" "$path\Data\Configurations\" -Force -ErrorAction Ignore
	Copy-Item -Path "$ext\*.cmd" "$path\" -Force -ErrorAction Ignore
	Remove-Item -Path "$Temp\$name" -Recurse -Force -ErrorAction Ignore
	
	("wg.ps1", "wg.cmd") | ForEach-Object { Start-BitsTransfer -Source "$Git/$name/$_" -Destination "$path\$_" }
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
