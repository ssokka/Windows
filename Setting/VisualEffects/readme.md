### Windows 시각 효과 설정
```
set _url=https://raw.githubusercontent.com/ssokka/Windows/master/Setting/VirtualEffects/install.ps1
powershell Start-Process -Verb RunAs wt 'powershell Invoke-Expression ([Net.WebClient]::new()).DownloadString(''%_url%'')'

```
