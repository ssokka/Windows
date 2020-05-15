2020.05.15
# 윈도우 글꼴 설치
<img src="logo.png" width=100>
<br><br>

# 자동 설치 스크립트 다운로드

## [D2Coding.cmd](https://github.com/ssokka/Windows/blob/master/Font/D2Coding.zip?raw=true)
<br>

# font.ps1
<img src="https://github.com/ssokka/Windows/raw/master/PowerShell/logo.png" width=100>

윈도우 글꼴 설치 파워셸 스크립트

## 명령 프롬프트 실행
```
powershell.exe -nop -ep bypass -f font.ps1 D2Coding.ttc https://raw.githubusercontent.com/ssokka/Fonts/master/D2Coding.ttc -m -r -p
```

## 실행 옵션
```
-file : 글꼴 파일 .ttc .ttf 지원
        기본 D2Coding.ttc
-url  : 기본 https://raw.githubusercontent.com/ssokka/Fonts/master
-m    : 필수 모듈 module.psm1 강제 다운로드
-p    : 일시 정지 후 스크립트 종료
-r    : 스크립트 작동 후 임시 작업 폴더 삭제
-d    : 디버그 모드
-t    : 테스트 모드
        개발자용
```
