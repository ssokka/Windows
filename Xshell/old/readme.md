2021.02.07

## <img src="https://raw.githubusercontent.com/ssokka/Icons/master/xshell.ico" width=25> [Xshell](https://www.netsarang.com/xshell/)
### 최신 평가 버전 자동 설치/설정 스크립트

<br><br>

## 다운로드
### [Xshell.zip](https://raw.githubusercontent.com/ssokka/Windows/master/Xshell/Xshell.zip)

<br><br>

## 자동 설정 내용
### [setting.reg](setting.reg)
```
* 메뉴 > 보기 > 도구 모음 > [ ] 주소 표시줄
* 메뉴 > 보기 > 도구 모음 > [ ] 연결 표시
```
### [Xshell.ini](Xshell.ini)
- 파일 : %USERPROFILE%\Documents\NetSarang Computer\7\Xshell\Xshell.ini
- ! 주의 : 파일 교체 방식으로 이전 설정은 초기화된다.
```
* 메뉴 > 도구 > 웹에서 검색 > 검색 엔진 관리 > [V] 구글, 네이버, 다음, Bing
* 메뉴 > 도구 > 옵션 > 고급 > [ ] Xshel 시작 시 세션 대화 상자 열기
```
### Sessions
- 파일 : %USERPROFILE%\Documents\NetSarang Computer\7\Xshell\Sessions
- ! 주의 : 모든 세션 파일이 아래 설정으로 적용된다. (기본 세션 포함)
- \*D2Coding : 글꼴이 설치되어 있는 경우에만 적용된다.
```
* 메뉴 > 파일 > 세션 등록 정보
   > 연결
     [V] 예기치 않게 연결이 끊겼을 때 자동으로 다시 연결
     > SSH
       [V] 처음 연결시 자동으로 수락 및 호스트 키 저장
     > 연결 유지
       [V] 네트워크가 유휴 상태일 때 문자열을 보냄
       간격: 290초, 문자열:  (공백한칸)
       [V] 네트워크가 유휴 상태일 때 TCP 연결 유지 패킷 보냄
   > 터미널
     터미널 종류: linux
     버퍼 크기: 200000
   > 모양
     색 구성표: New Black
     글꼴: *D2Coding
     한글 글꼴: *D2Coding
     글꼴 품질: Natural ClearType
   > 고급
     > 로깅
       [ ] 파일이 존재하는 경우 덮어쓰기
       [V] 연결 시 로깅 시작
       [ ] 로그 파일에 기록
```
### [개발중] CustomKeyMap.ckm
- 파일 : %USERPROFILE%\Documents\NetSarang Computer\7\Xshell\CustomKeyMap.ckm
- ! 주의 : 파일을 직접 수정하여 사용할 경우 초기화되는 버그가 있다.
- \* 파일 수정 후 아래 방법을 적용하면 해당 버그를 해결할 수 있다.
```
* 메뉴 > 도구 > 키 매핑 > Alt + 0 > 편집 > 확인 > 확인
```

<br><br>

## 수동 설정
```
* 세선 관리 창 자동 숨김
```

<br><br>

## 참고 - 파워쉘 실행
```
powershell.exe -nop -ep bypass -f xshell.ps1 -d2coding -install -setting -restore -keymap -m -r -p

-d2coding : D2Coding.ttc 글꼴 설치
-install  : 30일 평가판 설치
-setting  : 기본 설정
-restore  : 개인 자료 복원, 암호 필요
-keymap   : 개인 키 매핑 추가, 암호 필요, 업무용, 개발중
-m        : 필수 모듈 module.psm1 강제 다운로드
-p        : 일시 정지 후 스크립트 종료
-r        : 스크립트 작동 후 임시 작업 폴더 삭제
-d        : 디버그 모드, 개발자용
-t        : 테스트 모드, 개발자용
```

<br><br>

## 참고 - 개발
### [최신 평가 버전 다운로드](https://www.filehorse.com/download-xshell-free/)  
- 30일 날짜 제한 : O
- 기능 제한 : X
### [업데이트 내역](https://www.netsarang.com/json/product/update.html?productcode=2&languagestatus=1)
### 설치 파일
- 평가 버전
  - 파일명 : Xshell-x.x.xxxx.exe
  - 30일 날짜 제한 : O
  - 기능 제한 : X
- 무료 버전
  - 파일명 : Xshell-x.x.xxxx`p`.exe
  - 30일 날짜 제한 : X
  - 기능 제한 : O
  - 1개의 창은 최대 4개의 탭(세션) 생성이 가능하다.
  - 5번째 탭(세션)부터 자동으로 새 창에서 실행된다.
### 무인 응답 파일
- 설치 파일
  - Xshell.exe
- -f1 옵션
  - 전체 경로를 명시해야 적용된다.
  - 네트워크 드라이브 경로가 포함된 경우 적용되지 않는다.
- 생성
  - 설치 : Xshell.exe -r -f1"%temp%\install.iss"
  - 삭제 : Xshell.exe -r -f1"%temp%\uninstall.iss"
- 적용
  - 설치 : Xshell.exe -s -f1"%temp%\install.iss"
  - 삭제 : Xshell.exe -s -f1"%temp%\uninstall.iss"
