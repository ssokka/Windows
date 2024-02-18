## OpenVPN

### 설치
```
set _url=https://raw.githubusercontent.com/ssokka/Windows/master/OpenVPN/install.ps1
set _ps1=%temp%\openvpn.ps1
curl -Lo "%_ps1%" "%_url%"
powershell start -Wait -v RunAs wt 'powershell -exe bypass -f %_ps1%'

```
