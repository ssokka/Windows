### 이벤트 - 보안 - ID 4625
```
set _url=https://raw.githubusercontent.com/ssokka/Windows/master/Script/EventSecurity4625.ps1
start -Wait -v RunAs powershell 'iex([Text.Encoding]::UTF8.GetString(([Net.WebClient]::new()).DownloadData(''%_url%'')))'

```

### 파일 열기 - 보안 경고 - 끄기
```
set _url=https://raw.githubusercontent.com/ssokka/Windows/master/Script/DisableOpenFileSecurityWarning.ps1
start -Wait -v RunAs powershell 'iex([Text.Encoding]::UTF8.GetString(([Net.WebClient]::new()).DownloadData(''%_url%'')))'

```
