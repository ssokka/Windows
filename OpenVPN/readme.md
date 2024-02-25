## OpenVPN

### 설치
```
set _url=https://raw.githubusercontent.com/ssokka/Windows/master/OpenVPN/install.ps1
powershell start -v runas wt 'powershell iex ([Net.WebClient]::new()).DownloadString(''%_url%'')'

```
