### Event-Security-4625.ps1
```
set _url=https://raw.githubusercontent.com/ssokka/Windows/master/Script/Event-Security-4625.ps1
powershell Start-Process -wait -v RunAs powershell "iex(New-Object System.Net.WebClient).DownloadString("""""""""%_url%""""""""")"
```
