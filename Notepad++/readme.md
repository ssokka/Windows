﻿### Notepad++ 설치
`CMD`
```
set _url=https://raw.githubusercontent.com/ssokka/Windows/master/Notepad%2B%2B/install.ps1
powershell start -v runas wt 'powershell iex ([Net.WebClient]::new()).DownloadString(''%_url%'')'

```

### 설정
```
> 보기
  [v] 자동 줄바꿈
> 설정
  > 환경 설정
    > 편집
      [v] 부드러운 폰트 활성화
    > 최근 파일 사용 기록
      최대 기록 수 : 30
    > 자동 완성
      [v] ( )     [v] " "
      [v] [ ]     [v] ' '
      [v] { }     [v] html/xml 닫기 태그
    > 다중 실행 & 날짜
      [o] 항상 다중 실행 모드
    > 기타
      [v] Notepad++ 자동 업데이트 사용
      [v] 바로 쓰기 사용 (특수 문자 그리기 속도가 개선될 수 있음, Notepad++ 재시작 필요)
  > 스타일 설정
    테마 선택 : Dracula
    언어 : Global Styles
    형식 : Global override
    글꼴이름 : Consolas
    크기 : 10
    [v] 전역 글꼴 사용
    [v] 전역 글꼴 크기 사용
    [v] 전역 굵은 글꼴 사용
    [v] 전역 기울임 글꼴 사용
    [v] 전역 밑줄 글꼴 사용
> 플러그인
  > 플러그인 관리
    > 사용 가능
      찾기 : comp > [v] ComparePlus
      찾기 : cust > [v] Customize Toolbar
      찾기 : expl > [v] Explorer
      찾기 : hex  > [v] HexEditor
      찾기 : nppe > [v] NppExec
      찾기 : json > [v] JSON Viewer
      찾기 : xml  > [v] XML Tools
    > 설치
  > Customize Toolbar
    [v] Wrap Toolbar
  > Explorer
    [v] Explorer
  > Hex-Editor
    > Options... > Font
      Font Name: Consolas
      Font Size: 10
  > NppExec
    > Execute NppExec Script...
      ::cmd
      NPP_SAVE
      "$(FULL_CURRENT_PATH)"
      ::powershell
      NPP_SAVE
      powershell -NoProfile -ExecutionPolicy ByPass -File "$(FULL_CURRENT_PATH)"
    > Change Console Font...
      글꼴: Consolas
    > Change Execute Script Font...
      글꼴: Consolas
```
