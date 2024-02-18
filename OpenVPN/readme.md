## OpenVPN

### 설치 [CMD]
```
set _url=https://raw.githubusercontent.com/ssokka/Windows/master/OpenVPN/install.ps1
set _scr=%temp%\openvpn.ps1
curl -Lo "%_scr%" "%_url%"
powershell start -Wait -v RunAs wt 'powershell -exe bypass -f "%_scr%"'

```
