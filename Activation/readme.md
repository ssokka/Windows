## Windows 인증
`개인 키 복원`

### 설치
```
set _url=https://raw.githubusercontent.com/ssokka/Windows/master/Activation/install.ps1
powershell start -v runas 'powershell iex ([Net.WebClient]::new()).DownloadString(''%_url%'')'

```
