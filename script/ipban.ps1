# https://github.com/DigitalRuby/IPBan

$dir = "${Env:ProgramFiles}\IPBan"

if (! $(Test-Path "${dir}\DigitalRuby.IPBan.exe")) {
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/DigitalRuby/IPBan/master/IPBanCore/Windows/Scripts/install_latest.ps1"))
}


echo ""
echo "### Edit ipban.config"
Stop-Service "IPBAN" -Force

$file = "$dir\ipban.config"
if (Test-Path "${file}") {
	$xml = [xml](Get-Content "${file}")
	echo "FailedLoginAttemptsBeforeBan = 4"
	$node = $xml.configuration.appSettings.add | where {$_.key -eq 'FailedLoginAttemptsBeforeBan'}
	$node.value = '4'
	
	echo "BanTime = 00:00:00:00"
	$node = $xml.configuration.appSettings.add | where {$_.key -eq 'BanTime'}
	$node.value = '00:00:00:00'
	
	echo "ExpireTime = 00:00:00:00"
	$node = $xml.configuration.appSettings.add | where {$_.key -eq 'ExpireTime'}
	$node.value = '00:00:00:00'
	
	echo "Whitelist = 10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
	$node = $xml.configuration.appSettings.add | where {$_.key -eq 'Whitelist'}
	$node.value = '10.0.0.0/8,172.16.0.0/12,192.168.0.0/16'
	
	echo "UseDefaultBannedIPAddressHandler = false"
	$node = $xml.configuration.appSettings.add | where {$_.key -eq 'UseDefaultBannedIPAddressHandler'}
	$node.value = 'false'
	$xml.Save("${file}")
}

Start-Service "IPBAN"

echo ""
pause
