function CurrentCursorPosition {
	[Alias("ccp")]
	param(
		[Parameter(Mandatory=$true)]
		[Int]$x,
		[Int]$y
	)
	if ($lline -eq $null) { $lline = 0 }
	if ($Env:WT_SESSION -or $Env:OS -ne 'Windows_NT') {
		if ($lline -eq 0 -and [Console]::CursorTop -eq [Console]::WindowHeight - 1) {
			$lline = 1
			--$y
		}
	}
	$w = [Console]::WindowWidth
	[Console]::SetCursorPosition($x, $y)
	[Console]::Write("{0,-$w}" -f " ")
	[Console]::SetCursorPosition($x, $y)
}

function PinToStartScreen {
	[Alias("ptss")]
	param(
		[Parameter(Mandatory=$true)]
		[string]$p,
		[string]$i ="$Env:ProgramFiles\WindowsApps\Microsoft.WindowsTerminal_1.18.10301.0_x64__8wekyb3d8bbwe\wt.exe"
	)
	$ErrorActionPreference = 'Ignore'
	$bnm = (gi $p).BaseName
	Write-Host -f Green "`n### $bnm 시작 화면에 고정"
	$exe = "syspin.exe"
	$gid = ([System.Guid]::NewGuid()).ToString()
	$tmp = "$Env:TEMP\$gid.exe"
	$dir = "$Env:APPDATA\Microsoft\Windows\Start Menu\Programs"
	$lnk = "$dir\$gid.lnk"
	$new = "$dir\$bnm.lnk"
	ri $new -Force
	if (!(Test-Path "$Env:TEMP\$exe")) {
		Start-BitsTransfer "https://github.com/ssokka/Windows/raw/master/Tool/$exe" "$Env:TEMP\$exe"
	}
	$null = ni $tmp -it File -f
	start -wait -win h "$Env:TEMP\$exe" "`"$tmp`" 51201"
	do {
		sleep 1
	} until (Test-Path $lnk)
	sleep 5
	$sc = (New-Object -ComObject WScript.Shell).CreateShortcut($lnk)
	$sc.TargetPath = $p
	$sc.IconLocation = $i
	$sc.Save()
	rni $lnk $new -f
	ri $tmp -Force
}

function StopOpenVPN {
	[Alias("sov")]
	PARAM()
	$ErrorActionPreference = 'Ignore'
	('OpenVpnService','OpenVPNServiceLegacy','OpenVPNServiceInteractive') | % { spsv $_ -f }
	('openvpn','openvpn-gui', 'openvpnserv','openvpnserv2') | % { spps -n $_ -f }
}

$ErrorActionPreference = 'Stop'

try {
	$name = 'OpenVPN'
	$path = "$Env:ProgramFiles\$name"
	$exec = "$path\bin\openvpn.exe"

	$host.ui.RawUI.WindowTitle = $name
	
	Write-Host -f Green "`n### $name 버전"
	$cver = "$((gi $exec -ea ig).VersionInfo.FileVersion -replace '(.*)\.0','$1')".Trim()
	$site = "https://openvpn.net/community-downloads"
	$spat = '(?is)Windows 64-bit MSI installer.*?GnuPG Signature.*?<a href="(.*?)".*?OpenVPN-(.*?)-'
	$rver = ''; $rurl = ''
	$data = (New-Object Net.WebClient).DownloadString($site)
	if ($data -match $spat) {
		$rurl = "$($Matches[1])".Trim()
		$rver = "$($Matches[2])".Trim()
	}
	Write-Host "현재: $cver"
	Write-Host "최신: $rver"
	
	if ($cver -ne $rver) {
		Write-Host -f Green "`n### $name 설치"
		$file = "$Env:TEMP\$($rurl -replace '.*/(.*)','$1')"
		Start-BitsTransfer $rurl $file
		sov
		start -n -wait msiexec.exe "/i `"$file`" addlocal=all /passive /norestart"
		ri $file -Force -ea ig
	}
	
	Write-Host -f Green "`n### $name 서비스 설정"
	('OpenVPNServiceInteractive','OpenVPNServiceLegacy') | % {
		spsv $_ -f -ea ig
		Set-Service $_ -st Disabled -ea ig
	}
	start -n -wait sc.exe 'failure OpenVPNService reset= 0 actions= restart/0/restart/0/restart/0'
	
	Write-Host -f Green "`n### $name 설정"
	$menu = ('회사 클라이언트','개인 클라이언트','회사 서버','개인 서버','종료')
	$menu | % { $i = 1 } {
		$def = ''
		if ($i -eq 1) { $def = ' (기본)' }
		write-host "[$i] $_$def"
		$i++
	}
	Write-Host -n "선택: "
	
	$dread = 1
	$lline = 0
	while ($true) {
		$x, $y = [Console]::CursorLeft, [Console]::CursorTop
		$read = if ($nread = Read-Host) { $nread } else { $dread }
		if ($read -match "^[1-$($menu.count)]$") {
			break
		} else {
			ccp $x $y
		}
	}
	
	switch ($read) {
		1 { $file = 'client-c.7z' }
		2 { $file = 'client-p.7z' }
		3 { $file = 'server-c.7z' }
		4 { $file = 'server-p.7z' }
		5 { exit }
	}
	
	Write-Host -f Green "`n### $name $($menu[$read-1]) 설정"
	if (!(gmo 7Zip4Powershell -l)) {
		Set-ExecutionPolicy Bypass -f
		$null = Install-PackageProvider NuGet -min 2.8.5.201 -Force
		Register-PSRepository -d -ea ig
		Set-PSRepository PSGallery -i Trusted
		$null = inmo 7Zip4PowerShell -f
	}
	$url = "https://github.com/ssokka/Windows/raw/master/OpenVPN/$file"
	$zip = "$Env:TEMP\$file"
	Start-BitsTransfer $url $zip
	Write-Host -n "암호: "
	$lline = 0
	while ($true) {
		$x, $y = [Console]::CursorLeft, [Console]::CursorTop
		try { $test = $(Get-7Zip $zip -s ($pass = read-host -a)) } catch {}
		if ($test){
			break
		} else {
			ccp $x $y
		}
	}
	if (Test-Path "$path\config-auto\server.ovpn") { ri "$path\config-auto\*" -Force -ea ig }
	Expand-7Zip $zip "$path\config-auto" -s $pass
	ri $zip -Force -ea ig
	
	Write-Host -f Green "`n### 네트워크 어탭터 설정"
	Write-Host "$name - $($menu[$read-1])"
	sov
	('TAP-Windows Adapter V9','Wintun Userspace Tunnel','OpenVPN Data Channel Offload') | % {
		Get-PnpDevice -f "$_*"
	} | % {
		start -wait -win h pnputil.exe '/remove-device',$_.InstanceId
		# Write-Host "$_ : $_.InstanceId"
	}
	(gi "$path\config-auto\*.ovpn") | % {
		$conf = gc $_ -raw
		$hwid = 'ovpn-dco'
		if ($conf -match '(?im)^port') { $hwid = 'wintun' }
		$conf -replace '(?is).*dev-node (.*?)[\r|\n|\r\n].*','$1'
	} | % {
		start -wait -win h "$path\bin\tapctl.exe" "create --hwid $hwid --name `"$_`""
		Get-NetAdapter "$_"
		# Write-Host "$_ : $hwid"
	}
	
	Write-Host -f Green "`n### 서비스 재시작"
	Write-Host "$name"
	Restart-Service -f 'OpenVPNService'
	
	Write-Host -f Green "`n### 네트워크 드라이브 연결"
	(gi "$path\config-auto\drive*.cmd" -ea ig) | % {
		$dname = $_ -replace '(?i).*drive-(.*?)\..*','$1'
		$dname = (Get-Culture).TextInfo.ToTitleCase($dname)
		$sname = (gi $_).Basename
		Write-Host $dname
		start -n -wait schtasks.exe "/create /tn `"$sname`" /tr `"$_`" /sc onstart /ru `"$Env:USERNAME`" /f"
		start -n -wait schtasks.exe "/run /tn `"$sname`""
		start -n -wait schtasks.exe "/delete /tn `"$sname`" /f"
		ptss "$_"
	}
	
	
	Write-Host -f Green "`n### 완료"
}
catch {
	Write-Error ($_.Exception | fl -Force | Out-String)
	Write-Error ($_.InvocationInfo | fl -Force | Out-String)
}

Write-Host -n "`n아무 키나 누르십시오..."
Read-Host
