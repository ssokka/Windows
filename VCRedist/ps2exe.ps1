# UTF-8 / CRLF

$url = 'https://raw.githubusercontent.com/ssokka/Windows/master/VCRedist/install.ps1'
(New-Object System.Net.WebClient).DownloadString($url)