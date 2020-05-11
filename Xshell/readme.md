2020.05.12

# [Xshell](https://www.netsarang.com/xshell/)
<img src="logo.png" width=100>

## [Xshell 6 Build 0193 다운로드](https://www.majorgeeks.com/mg/getmirror/xshell,1.html)  
! 30일 평가판이며, 기능 제한은 없다.

## [업데이트 내역](https://www.netsarang.com/ko/xshell-update-history/)

# Xshell.ps1
<img src="https://github.com/ssokka/Windows/raw/master/PowerShell/logo.png" width=100>

설치 및 설정 파워셸 스크립트

## 명령 프롬프트 실행
```
powershell.exe -nop -ep bypass -f xshell.ps1 -d2coding -install -restore -setting -keymap -m -r -p
```

## 실행 옵션
```
-d2coding : D2Coding.ttc 글꼴 설치
-install  : 30일 평가판 설치
-restore  : 개인 자료 복원
            암호 필요
-setting  : 기본 설정
-keymap   : 개인 키 매핑 추가
            암호 필요
-m        : 필수 모듈 module.psm1 강제 다운로드
-p        : 일시 정지 후 스크립트 종료
-r        : 스크립트 작동 후 임시 작업 폴더 삭제
-d        : 디버그 모드
-t        : 테스트 모드
            개발자용
```

## 기본 설정
### [Xshell.reg](Xshell.reg)
```
* 실험 기능 창 닫기
* 메뉴 > 보기 > 도구 모음 > [ ] 주소 표시줄
* 메뉴 > 보기 > 도구 모음 > [ ] 연결 표시
```
### [Xshell.ini](Xshell.ini)
파일 경로 : `%USERPROFILE%\Documents\NetSarang Computer\6\Xshell\Xshell.ini`  
! 파일 교체 방식으로 이전 설정은 초기화된다.
```
* 메뉴 > 도구 > 웹에서 검색 > 검색 엔진 관리 > [V] 구글, 네이버, 다음, Bing
* 메뉴 > 도구 > 옵션 > 고급 > [ ] Xshel 시작 시 세션 대화 상자 열기
```

## 세션 설정
파일 경로 : `%USERPROFILE%\Documents\NetSarang Computer\6\Xshell\Sessions`  
! 기본 세션을 포함하여 모든 세션 파일이 아래 설정으로 적용된다.  
`D2Coding` 글꼴은 설치되어 있는 경우에만 적용된다.
```
> 연결
  [V] 예기치 않게 연결이 끊겼을 때 자동으로 다시 연결
  > 연결 유지
    [V] 네트워크가 유휴 상태일 때 문자열을 보냄
    간격: 280초, 문자열: \n
    [V] 네트워크가 유휴 상태일 때 TCP 연결 유지 패킷 보냄
> 터미널
  터미널 종류: linux
  버퍼 크기: 200000
> 모양
  색 구성표: New Black
  글꼴: D2Coding
  한글 글꼴: D2Coding
  글꼴 품질: Natural ClearType
> 고급
  > 로깅
    [ ] 파일이 존재하는 경우 덮어쓰기
    [V] 연결 시 로깅 시작
    [V] 로그 파일에 기록
```

## 사용자 지정 키 매핑
파일 경로 : `%USERPROFILE%\Documents\NetSarang Computer\6\Xshell\CustomKeyMap.ckm`  
! 파일을 직접 수정하여 사용할 경우 초기화되는 버그가 있다.  
파일 수정 후 아래 방법을 적용하면 해당 버그를 해결할 수 있다.
```
! 메뉴 > 도구 > 키 매핑 > Alt + 0 > 편집 > 확인 > 확인
```

## 수동 설정
```
* 세선 관리 창 자동 숨김
```

## 참고

### 무인 응답 파일

`xshell.exe` 파일은 설치 파일이다.

#### 생성
```
* 설치 : xshell.exe -r -f1"%temp%\install.iss"
* 삭제 : xshell.exe -r -f1"%temp%\uninstall.iss"
```

#### 적용
```
* 설치 : xshell.exe -s -f1"%temp%\install.iss"
* 삭제 : xshell.exe -s -f1"%temp%\uninstall.iss"
```

#### -f1 옵션
```
* 전체 경로를 명시해야 적용된다.
* 네트워크 드라이브 경로가 포함된 경우 적용되지 않는다.
```