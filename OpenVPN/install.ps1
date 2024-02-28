function stop-openvpn {
	[Alias('sov')]
	PARAM()
	$ErrorActionPreference = 'SilentlyContinue'
	('OpenVpnService','OpenVPNServiceLegacy','OpenVPNServiceInteractive') | % { Stop-Service $_ -Force }
	('openvpn','openvpn-gui', 'openvpnserv','openvpnserv2') | % { Stop-Process -Name $_ -Force }
}

$ErrorActionPreference = 'Stop'

try {
	$name = 'OpenVPN'
	$path = "$Env:ProgramFiles\$name"
	$exec = "$path\bin\openvpn.exe"
	$conf = "$path\config-auto"
	
	$host.ui.RawUI.WindowTitle = $name
	
	Write-Host -ForegroundColor Green "`n### $name 버전"
	$cver = "$((Get-Item $exec -ErrorAction Ignore).VersionInfo.FileVersion -replace '(.*)\.0', '$1')".Trim()
	$site = "https://openvpn.net/community-downloads"
	$spat = '(?is)Windows 64-bit MSI installer.*?GnuPG Signature.*?<a href="(.*?)".*?OpenVPN-(.*?)-'
	$rver = $rurl = ''
	$data = (New-Object Net.WebClient).DownloadString($site)
	if ($data -match $spat) {
		$rurl = "$($Matches[1])".Trim()
		$rver = "$($Matches[2])".Trim()
	}
	Write-Host "현재: $cver"
	Write-Host "최신: $rver"
	
	if ($cver -ne $rver) {
		Write-Host -ForegroundColor Green "`n### $name 설치"
		$file = "$Env:TEMP\$($rurl -replace '.*/(.*)', '$1')"
		Start-BitsTransfer $rurl $file
		sov
		('config','config-auto') | % { if ((Get-Item "$path\$_" -ErrorAction Ignore).LinkType -eq 'SymbolicLink') { Remove-Item $_ -Force -ErrorAction Ignore } }
		Start-Process -NoNewWindow -Wait msiexec.exe "/i `"$file`" addlocal=all /passive /norestart"
		Remove-Item $file -Force -ErrorAction Ignore
	}
	$null = reg.exe delete 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' /v 'OPENVPN-GUI' /f 2>$null
	Remove-Item "$Env:Public\Desktop\OpenVPN GUI.lnk" -Force -ErrorAction Ignore
	
	Write-Host -ForegroundColor Green "`n### $name 서비스 설정"
	('OpenVPNServiceInteractive','OpenVPNServiceLegacy') | % {
		Stop-Service $_ -Force -ErrorAction Ignore
		Set-Service $_ -StartupType Disabled -ErrorAction Ignore
	}
	Start-Process -NoNewWindow -Wait sc.exe 'failure OpenVPNService reset= 0 actions= restart/0/restart/0/restart/0'
	
	Write-Host -ForegroundColor Green "`n### $name 설정"
	$menu = ('회사 클라이언트','개인 클라이언트','회사 서버','개인 서버','종료')
	$menu | % { $i = 1 } {
		$def = ''
		if ($i -eq 1) { $def = ' (기본)' }
		Write-Host "[$i] $_$def"
		$i++
	}
	Write-Host -NoNewline '선택: '
	
	$dread = 1;	$lline = 0
	while ($true) {
		$x, $y = [Console]::CursorLeft, [Console]::CursorTop
		$read = if ($nread = Read-Host) { $nread } else { $dread }
		if ($read -match "^[1-$($menu.count)]$") { break } else { ccp $x $y }
	}
	
	switch ($read) {
		1 { $file = 'client-c.7z' }
		2 { $file = 'client-p.7z' }
		3 { $file = 'server-c.7z' }
		4 { $file = 'server-p.7z' }
		5 { exit }
	}
	
	Write-Host -ForegroundColor Green "`n### $name $($menu[$read-1]) 설정"
	if (!(gmo 7Zip4Powershell -l)) {
		Set-ExecutionPolicy Bypass -Force
		$null = Install-PackageProvider NuGet -MinimumVersion 2.8.5.201 -Force
		Register-PSRepository -Default -ErrorAction Ignore
		Set-PSRepository PSGallery -InstallationPolicy Trusted
		$null = Install-Module 7Zip4PowerShell -Force
	}
	$url = "https://github.com/ssokka/Windows/raw/master/OpenVPN/$file"
	$zip = "$Env:TEMP\$file"
	Start-BitsTransfer $url $zip
	Write-Host -NoNewline '암호: '
	$lline = 0
	while ($true) {
		$x, $y = [Console]::CursorLeft, [Console]::CursorTop
		try { $test = $(Get-7Zip $zip -s ($pass = Read-Host -AsSecureString)) } catch {}
		if ($test) { break } else { ccp $x $y }
	}
	if (Test-Path "$conf\server.ovpn") { Remove-Item "$conf\*" -Force -ErrorAction Ignore }
	Expand-7Zip $zip "$conf" -SecurePassword $pass
	Remove-Item $zip -Force -ErrorAction Ignore
	
	Write-Host -ForegroundColor Green "`n### 네트워크 어탭터 설정"
	Write-Host "- $name $($menu[$read-1])"
	sov
	('TAP-Windows Adapter V9','Wintun Userspace Tunnel','OpenVPN Data Channel Offload') | % {
		Get-PnpDevice -FriendlyName "$_*"
	} | % {
		Start-Process -Wait -WindowStyle Hidden pnputil.exe '/remove-device',$_.InstanceId
	}
	(Get-Item "$conf\*.ovpn") | % {
		(Get-Content $_ -raw) -replace '(?is).*dev-node (.*?)(?:\r\n|\n).*', '$1'
	} | % {
		Start-Process -Wait -WindowStyle Hidden "$path\bin\tapctl.exe" "create --hwid wintun --name `"$_`""
		Get-NetAdapter "$_"
	}
	
	$file = "$conf\ovpn-drive.cmd"
	if (Test-Path $file) {
		Write-Host -ForegroundColor Green "`n### 네트워크 드라이브 연결"
		$tn = (Get-Item $file).Basename
		Start-Process -NoNewWindow -Wait schtasks.exe "/create /tn `"$tn`" /tr `"$file`" /sc onstart /ru `"$Env:UserName`" /f"
		Start-Process -NoNewWindow -Wait schtasks.exe "/run /tn `"$tn`""
		Start-Process -NoNewWindow -Wait schtasks.exe "/delete /tn `"$tn`" /f"
	}
	
	Write-Host -ForegroundColor Green "`n### 시작 화면에 고정"
	$icon = "$Env:ProgramFiles\WindowsApps\Microsoft.WindowsTerminal_1.18.10301.0_x64__8wekyb3d8bbwe\wt.exe"
	pt start "$conf\ovpn-on.cmd" $icon
	pt start "$conf\ovpn-off.cmd" $icon
	
	Write-Host -ForegroundColor Green "`n### 완료"
}
catch {
	Write-Error ($_.Exception | Format-List -Force | Out-String)
	Write-Error ($_.InvocationInfo | Format-List -Force | Out-String)
}

Write-Host -NoNewline "`n아무 키나 누르십시오..."; Read-Host
