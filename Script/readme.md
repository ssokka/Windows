### Event-Security-4625.ps1
```
powershell -Command "Start-Process powershell -ArgumentList '-Command [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString("""""""""https://raw.githubusercontent.com/ssokka/Windows/master/Script/Event-Security-4625.ps1"""""""""))' -Wait -Verb RunAs"
```
