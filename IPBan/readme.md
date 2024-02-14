### [CMD]
```
powershell -Command "Start-Process powershell -ArgumentList '-Command [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString("""""""""https://raw.githubusercontent.com/ssokka/Windows/master/IPBan/install.ps1"""""""""))' -Wait -Verb RunAs"
```
