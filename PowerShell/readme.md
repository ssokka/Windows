# PowerShell Script

## 사용 환경
- Windows 명령 프롬프트 : <kbd>Win</kbd> + <kbd>R</kbd> - **`cmd`**

## 참고
### [Command Line Swich Shortcuts](https://docs.microsoft.com/en-us/powershell/module/Microsoft.PowerShell.Core/About/about_pwsh?view=powershell-7)
- -Command : -c
- -ExecutionPolicy : -ep
- -File : -f
- -NoProfile : -nop

## 다운로드 및 실행 방법
### 기본
```{.line-numbers}
set _ps1=file.ps1
set _ps=powershell.exe -nop -ep bypass
set _url=https://raw.githubusercontent.com/ssokka/Windows/master/PowerShell
%_ps% -c "& {[Net.WebClient]::new().DownloadFile('%_url%/%_ps1%', '%_ps1%')}"
if exist "%_ps1%" %_ps% -f "%_ps1%"
```
### 예시
```
set _ps1=administrator-active.ps1
set _ps=powershell.exe -nop -ep bypass
set _url=https://raw.githubusercontent.com/ssokka/Windows/master/PowerShell
%_ps% -c "& {[Net.WebClient]::new().DownloadFile('%_url%/%_ps1%', '%_ps1%')}"
if exist "%_ps1%" %_ps% -f "%_ps1%" -yes -nopause
```

# administrator-active.ps1
**`powershell.exe -nop -ep bypass -f administrator-active.ps1 {-Yes|-No} [-NoPause]`**
```
-Yes : Administrator 계정 활성화
-No : Administrator 계정 비활성화 및 암호 초기화
-NoPause : 일시 정지없이 종료
```
