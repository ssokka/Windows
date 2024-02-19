try{
	$name = 'OpenVPN'
	$path = "$Env:ProgramFiles\$name"
	
	Write-Host "`n### $name 버전 확인"
	$cver = (gi "$path\bin\openvpn.exe" -ea ig).VersionInfo.FileVersion -replace '(.*)\.0','$1'
	$data = (New-Object Net.WebClient).DownloadString("https://openvpn.net/community-downloads")
	$patt = '(?is).*?Windows 64-bit MSI installer.*?GnuPG Signature.*?<a href="(.*?)".*?OpenVPN-(.*?)-.*'
	$rurl = $data -replace $patt,'$1'
	$rver = $data -replace $patt,'$2'
	Write-Host "현재 버전 = $cver"
	Write-Host "최신 버전 = $rver"
	
	if($cver -ne $rver){
		Write-Host "`n### $name 다운로드"
		$file = "$Env:TEMP\$($rurl -replace '.*/(.*)','$1')"
		Start-BitsTransfer $rurl $file -ea Stop
		Write-Host "`n### $name 설치"
		('OpenVpnService','OpenVPNServiceLegacy','OpenVPNServiceInteractive') | % { spsv $_ -f -ea ig }
		('openvpn','openvpn-gui', 'openvpnserv','openvpnserv2') | % { spps -n $_ -f -ea ig }
		msiexec.exe /i "$file" addlocal=all /passive /norestart
		ri $file -f -ea ig
	}
	
	Write-Host "`n### $name 서비스 설정"
	('OpenVPNServiceInteractive','OpenVPNServiceLegacy') | % {
		spsv $_ -f -ea ig
		Set-Service $_ -st Disabled -ea ig
	}
	sc.exe failure 'OpenVPNService' reset= 0 actions= restart/0/restart/0/restart/0
	
	Write-Host "`n### $name 설정"
	$menu = ('회사 클라이언트','개인 클라이언트','회사 서버','개인 서버','종료')
	$menu | % { $i = 1 }{
		$str = ''
		if ($i -eq 1) { $str = ' (기본)' }
		write-host "[$i] $_$str"
		$i++
	}
	Write-Host -n "선택: "
	
	$dread = 1
	$last = 0
	while ($true) {
		$x, $y = [Console]::CursorLeft, [Console]::CursorTop
		$read = if($nread = Read-Host) { $nread } else { $dread }
		if ($read -match '^[1-5]$') {
			break
		} else {
			if ($Env:WT_SESSION -or $Env:OS -ne 'Windows_NT') {
				if ($last -eq 0 -and [Console]::CursorTop -eq [Console]::WindowHeight - 1) {
					$last = 1
					--$y
				}
			}
			[Console]::SetCursorPosition($x, $y)
			$w = [Console]::WindowWidth
			[Console]::Write("{0,-$w}" -f " ")
			[Console]::SetCursorPosition($x, $y)
		}
	}
	
	switch ($read) {
		1 { $file = 'client-c.7z' }
		2 { $file = 'client-p.7z' }
		3 { $file = 'server-c.7z' }
		4 { $file = 'server-p.7z' }
		5 { exit }
	}
	
	Write-Host "`n### $name $($menu[$read-1]) 설정"
	$url = "https://github.com/ssokka/Windows/raw/master/OpenVPN/$file"
	$zip = "$Env:TEMP\$file"
	Start-BitsTransfer $url $zip -ea Stop
	if (!(gmo 7Zip4Powershell -l)) {
		Install-PackageProvider NuGet -min 2.8.5.201 -Force
		Set-PSRepository PSGallery 'https://www.powershellgallery.com/api/v2' -i Trusted
		inmo 7Zip4PowerShell -f
	}
	Write-Host -n "암호: "
	$last = 0
	while ($true) {
		$x, $y = [Console]::CursorLeft, [Console]::CursorTop
		Expand-7Zip $zip "$path\config-auto" -sec (Read-Host -a) -ea ig
		if ($?) {
			break
		} else {
			if ($Env:WT_SESSION -or $Env:OS -ne 'Windows_NT') {
				if ($last -eq 0 -and [Console]::CursorTop -eq [Console]::WindowHeight - 1) {
					$last = 1
					--$y
				}
			}
			[Console]::SetCursorPosition($x, $y)
			$w = [Console]::WindowWidth
			[Console]::Write("{0,-$w}" -f " ")
			[Console]::SetCursorPosition($x, $y)
		}
	}
	ri $zip -f -ea ig
	
	Write-Host "`n### $name 네트워크 어탭터 설정"
	('TAP-Windows Adapter V9','Wintun Userspace Tunnel','OpenVPN Data Channel Offload') | % {
		Get-PnpDevice -f "$_*"
	} | % {
		# pnputil.exe /remove-device $_.InstanceId
		Write-Host "$_ : $_.InstanceId"
	}
	(gi "$path\config-auto\*.ovpn") | % {
		$read = gc $_ -raw
		$hwid = 'ovpn-dco'
		if ($read -match '(?im)^port') { $hwid = 'wintun' }
		$read -replace '(?is).*dev-node (.*?)[\r|\n|\r\n].*','$1'
	} | % {
		# start -n -Wait "$path\bin\tapctl.exe" "create --hwid $hwid --name `"$_`"" -ea Stop
		Write-Host "$_ : $hwid"
	}
	
	Write-Host "`n### $name 서비스 재시작"
	# Restart-Service -f 'OpenVPNService'
}
catch {
	Write-Error ($_.Exception | fl -Force | Out-String)
	Write-Error ($_.InvocationInfo | fl -Force | Out-String)
}

Write-Host -n "`n### 완료`n아무 키나 누르십시오..."
Read-Host
