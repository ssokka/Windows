# https://github.com/DigitalRuby/IPBan

$dir = "$Env:ProgramFiles\IPBan"

if (! $(Test-Path $dir\DigitalRuby.IPBan.exe)) {
	echo "`n### IPBan 설치"
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/DigitalRuby/IPBan/master/IPBanCore/Windows/Scripts/install_latest.ps1"))
}

$file = "$dir\ipban.config"
echo "`n### Edit ""$file"""
if (Test-Path $file) {
	$xml = [xml](Get-Content $file)
	
	echo "FailedLoginAttemptsBeforeBan = 1"
	$node = $xml.configuration.appSettings.add | where {$_.key -eq 'FailedLoginAttemptsBeforeBan'}
	$node.value = '1'
	
	echo "BanTime = 00:00:00:00"
	$node = $xml.configuration.appSettings.add | where {$_.key -eq 'BanTime'}
	$node.value = '00:00:00:00'
	
	echo "ExpireTime = 00:00:00:00"
	$node = $xml.configuration.appSettings.add | where {$_.key -eq 'ExpireTime'}
	$node.value = '00:00:00:00'
	
	echo "UseDefaultBannedIPAddressHandler = false"
	$node = $xml.configuration.appSettings.add | where {$_.key -eq 'UseDefaultBannedIPAddressHandler'}
	$node.value = 'false'
	
 	$xml.Save($file)
}

Start-Service "IPBAN"

Start-Sleep -Milliseconds 500
echo "`n"
cmd /c 'pause'
