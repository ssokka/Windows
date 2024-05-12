### [CMD] Windows 인증
`개인 키 복원`
```
set _url=https://raw.githubusercontent.com/ssokka/Windows/master/Activation/install.ps1
powershell Start-Process -Verb RunAs wt 'powershell Invoke-Expression ([Net.WebClient]::new()).DownloadString(''%_url%'')'

```
