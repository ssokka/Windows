try{
	$gfe = 'Get-FileEncoding.ps1'
	if(!(Test-Path "$Env:TEMP\$gfe")){
		(New-Object Net.WebClient).DownloadFile("https://raw.githubusercontent.com/ssokka/Windows/master/Script/$gfe","$Env:TEMP\$gfe")
	}
	if(((iex "$Env:TEMP\$gfe $PSCommandpath").BodyName) -ne 'utf-8'.ToLower()){
		(gc $PSCommandpath -enc UTF8) | Out-File $PSCommandpath UTF8
		iex $PSCommandpath
		exit
	}

	$name = 'OpenVPN'
	
	echo "`n### $name 버전 확인"
	$cver = (gi "$Env:ProgramFiles\OpenVPN\bin\openvpn.exe" -ea ig).VersionInfo.FileVersion -replace '(.*)\.0','$1'
	$patt = '(?is).*?Windows 64-bit MSI installer.*?GnuPG Signature.*?<a href="(.*?)".*?OpenVPN-(.*?)-.*'
	$data = (New-Object Net.WebClient).DownloadString("https://openvpn.net/community-downloads")
	$rurl = $data -replace $patt,'$1'
	$rver = $data -replace $patt,'$2'
	echo "현재 버전 = $cver"
	echo "최신 버전 = $rver"
	
	if($cver -ne $rver){
		echo "`n### $name 다운로드"
		$msi = "$Env:TEMP\$($rurl -replace '.*/(.*)','$1')"
		Start-BitsTransfer $rurl $msi -ea Stop
		echo "`n### $name 설치"
		@('OpenVpnService', 'OpenVPNServiceLegacy', 'OpenVPNServiceInteractive') | % { spsv -f $_ -ea ig }
		@('openvpn', 'openvpn-gui', 'openvpnserv', 'openvpnserv2') | % { spps -f -n $_ -ea ig }
		msiexec.exe /i "$msi" addlocal=all /passive /norestart
	}
}
catch{
	Write-Error ($_.Exception | fl -Force | Out-String)
	Write-Error ($_.InvocationInfo | fl -Force | Out-String)
}
Write-Host "`n아무 키나 누르십시오..." -n
$Host.UI.ReadLine()
