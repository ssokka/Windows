### Windows 인증
`1.5.5.2` `개인 키 복원`
`CMD`
```
set _url=https://raw.githubusercontent.com/ssokka/Windows/master/Activation/install.ps1
powershell start -v runas wt 'powershell iex ([Net.WebClient]::new()).DownloadString(''%_url%'')'
```
