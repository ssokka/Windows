### [CMD] Windows 인증
`1.5.5.2` `개인 키 복원`
```
set _url=https://raw.githubusercontent.com/ssokka/Windows/master/Activation/install.ps1
powershell start -v runas wt 'powershell iex ([Net.WebClient]::new()).DownloadString(''%_url%'')'
```

### [참고] 완료 시 창 바로 닫기
```
powershell start -v runas wt 'powershell "& ([scriptblock]::Create(([Net.WebClient]::new()).DownloadString(''%_url%''))) $false"'
```
