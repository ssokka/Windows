### [CMD]
```
powershell -Command "Start-Process powershell -ArgumentList '-noexit -Command [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString("""""""""https://raw.githubusercontent.com/ssokka/windows/master/IPBan/install.ps1"""""""""))' -Wait -Verb RunAs"
```
