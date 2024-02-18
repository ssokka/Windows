## OpenVPN

### 설치
```
set _url=https://raw.githubusercontent.com/ssokka/Windows/master/OpenVPN/install.ps1
powershell start -Wait -v RunAs wt 'powershell iex([Text.Encoding]::UTF8.GetString(([Net.WebClient]::new()).DownloadData(''%_url%'')))'

```
