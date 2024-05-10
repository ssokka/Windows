### WireGuard 설치
```
set _url=https://raw.githubusercontent.com/ssokka/Windows/master/WireGuard/install.ps1
powershell Start-Process -Verb RunAs wt 'powershell Invoke-Expression ([Net.WebClient]::new()).DownloadString(''%_url%'')'

```
