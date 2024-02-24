### 설정
```
set _url=https://raw.githubusercontent.com/ssokka/Windows/master/WindowsTerminal/install.ps1
powershell start wt 'powershell iex([Text.Encoding]::UTF8.GetString(([Net.WebClient]::new()).DownloadData(''%_url%'')))'

```

### 설정 내용
```
> 시작
    - 기본 프로필 : 명령 프롬프트
    - 기본 터미널 응용 프로그램 : Windows 터미널
    - 새 인스턴스 동작 : 가장 최근에 사용한 창에 첨부
> 상호 작용
    - 선택 영역을 클립보드에 자동으로 복사 : 켬
    - 직사각형 선택 영역의 후행 공백 제거 : 켬
> 모양
    - 창 애니메이션 : 끔
> 기본값
    > 모양
        - 글꼴 크기 : 10
    > 고급
        - 텍스트 앤티앨리어싱 : ClearType
        - 기록 크기 : 2147483640
```
