### Visual C++ 재배포 가능 패키지 설치
`CMD`
```
set _url=https://raw.githubusercontent.com/ssokka/Windows/master/VCRedist/install.ps1
powershell start -v runas wt 'powershell iex ([Net.WebClient]::new()).DownloadString(''%_url%'')'

```
### 참고
https://github.com/abbodi1406/vcredist  
https://learn.microsoft.com/ko-kr/cpp/windows/latest-supported-vc-redist?view=msvc-170  
