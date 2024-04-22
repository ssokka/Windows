### Windows 시각 효과
- 설정
```
set _url=https://raw.githubusercontent.com/ssokka/Windows/master/Setting/VisualEffects/install.ps1
powershell Start-Process -Verb RunAs wt 'powershell Invoke-Expression ([Net.WebClient]::new()).DownloadString(''%_url%'')'

```
- 참고
```
SystemPropertiesPerformance.exe

> 최적 성능으로 조정
> 사용자 지정
   V 바탕화면의 아이콘 레이블에 그림자 사용
   V 아이콘 대신 미리 보기로 표시
   V 화면 글꼴의 가장자리 다듬기
```
