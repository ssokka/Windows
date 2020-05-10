<img src="logo.png" height="30" style="vertical-align:bottom"> [**Xshell**](https://www.netsarang.com/xshell/)
===

## [다운로드](https://www.majorgeeks.com/mg/getmirror/xshell,1.html)  
30일 평가판  
기능 제한 없음

## [업데이트 내역](https://www.netsarang.com/ko/xshell-update-history/)

## 무인 응답 파일

여기서 `xshell.exe` 파일은 설치 파일이다.

### 생성
* 설치 `xshell.exe -r -f1"%temp%\install.iss"`
* 삭제 `xshell.exe -r -f1"%temp%\uninstall.iss"`

### 적용
* 설치 `xshell.exe -s -f1"%temp%\install.iss"`
* 삭제 `xshell.exe -s -f1"%temp%\uninstall.iss"`

### -f1 옵션
* 전체 경로를 명시해야 적용된다.
* 네트워크 드라이브 경로가 포함된 경우 적용되지 않는다.

## <img src="https://github.com/ssokka/Windows/raw/master/PowerShell/logo.png" height="25" style="vertical-align:bottom"> Xshell.ps1

자동 설치 및 설정 스크립트

### 실행 옵션
```
-install : 30일 평가판 설치
-setting : 기본 설정
-restore : 개인 설정 복원
           암호 필요
-keymap  : 사용자 지정 키 매핑 설정
           암호 필요
-m       : 필수 모듈 module.psm1 강제 다운로드
-p       : 일시 정지 후 스크립트 종료
-d       : 디버그 모드
-t       : 테스트 모드
           개발자용
```

### 기본 설정 내용

#### D2Coding 글꼴 설치
```
powershell.exe -nop -ep bypass -f font.ps1
```

#### 실험 기능 창 닫기
```
reg.exe add "HKEY_CURRENT_USER\Software\NetSarang\Common\6" /v "ExpFeaturesPopup" /t REG_DWORD /d "1"
```

#### 메뉴 - 보기 - 도구 모음 - [ ] 주소 표시줄
```
reg.exe add HKEY_CURRENT_USER\Software\NetSarang\Xshell\6\Layout\current" /v "AddressBar" /t REG_DWORD /d "0"
```

#### 메뉴 - 보기 - 도구 모음 - [ ] 연결 표시
```
reg.exe add "HKEY_CURRENT_USER\Software\NetSarang\Xshell\6\Layout\current" /v "LinksBar" /t REG_DWORD /d "0"
```

#### 메뉴 - 도구 - 웹에서 검색 - 검색 엔진 관리 - 추가 - 네이버, 다음
설정 파일 경로 `%USERPROFILE%\Documents\NetSarang Computer\6\Xshell\Xshell.ini`
```ini
[SearchEngineList]
Count=4
DefaultSearchEngine=0
SearchEngine0.Name=구글
SearchEngine0.PercentEncoding=1
SearchEngine0.Query=https://www.google.co.kr/search?q=%s
SearchEngine1.Name=네이버
SearchEngine1.PercentEncoding=1
SearchEngine1.Query=https://search.naver.com/search.naver?query=%s
SearchEngine2.Name=다음
SearchEngine2.PercentEncoding=1
SearchEngine2.Query=https://search.daum.net/search?q=%s
SearchEngine3.Name=Bing
SearchEngine3.PercentEncoding=1
SearchEngine3.Query=https://www.bing.com/search?q=%s
```

#### 세션 등록 정보

세션 폴더 경로 `%USERPROFILE%\Documents\NetSarang Computer\6\Xshell\Sessions`  
기본 세션 파일 경로 `%USERPROFILE%\Documents\NetSarang Computer\6\Xshell\Sessions\default`
```
- 연결
  [v] 예기치 않게 연결이 끊겼을 때 자동으로 다시 연결
  - 연결 유지
    [v] 네트워크가 유휴 상태일 때 문자열을 보냄
    간격: 280초, 문자열: \n
    [v] 네트워크가 유휴 상태일 때 TCP 연결 유지 패킷 보냄
- 터미널
  터미널 종류: linux
  버퍼 크기: 200000
- 모양
  색 구성표: New Black
  글꼴: D2Coding
  한글 글꼴: D2Coding
  글꼴 품질: Natural ClearType
- 고급
  - 로깅
    [ ] 파일이 존재하는 경우 덮어쓰기
    [v] 연결 시 로깅 시작
    [v] 로그 파일에 기록
```
```ini
[CONNECTION]
AutoReconnect=1
[CONNECTION:KEEPALIVE]
SendKeepAlive=1
SendKeepAliveInterval=280
KeepAliveString=\n
TCPKeepAlive=1
[TERMINAL]
Type=linux
ScrollbackSize=200000
[TERMINAL:WINDOW]
ColorScheme=New Black
FontFace=D2Coding
AsianFont=D2Coding
FontQuality=6
[LOGGING]
Overwrite=0
AutoStart=1
WriteFileTimestamp=1

QuickCommand=Default Quick Command Set
```

## 사용자 지정 키 매핑

사용자 지정 키 매핑 파일 경로 `%USERPROFILE%\Documents\NetSarang Computer\6\Xshell\CustomKeyMap.ckm`  
* 파일을 직접 수정하여 사용할 경우 초기화되는 버그가 있다.
* 파일 수정 후 아래 방법을 적용하면 해당 버그를 해결할 수 있다.
* **`메뉴 - 도구 - 키 매핑 - Alt + 0 - 편집 - 확인 - 확인`**

## 수동 설정

#### 세선 관리 창 자동 숨김
