## Notepad++

### 설치
```
set _url=https://raw.githubusercontent.com/ssokka/Windows/master/Notepad%2B%2B/install.ps1
powershell start -Wait -v RunAs powershell 'iex([Text.Encoding]::UTF8.GetString(([Net.WebClient]::new()).DownloadData(''%_url%'')))'

```

### 다운로드
https://notepad-plus-plus.org/downloads/

### 기본 설정
```
> 보기
  [v] 자동 줄바꿈
> 설정
  > 환경 설정
    > 편집
      [o] 부드러운 폰트 활성화
    > 최근 파일 사용 기록
      최대 기록 수 : 30
    > 자동 완성
      [v] (
      [v] [
      [v] {
      [v] "
      [v] '
      [v] html/xml 닫기 태그
    > 다중 실행 & 날짜
      [o] 항상 다중 실행 모드
    > 기타
      [v] Notepad++ 자동 업데이트 사용
      [v] 바로 쓰기 사용 (특수 문자 그리기 속도가 개선될 수 있음, Notepad++ 재시작 필요)
  > 스타일 설정
    테마 선택 : Dracula
    언어 : Global Styles
    스타일 : Global override
    글꼴이름 : Consolas
    크기 : 11
    [v] 전역 글꼴 사용
    [v] 전역 글꼴 크기 사용
    [v] 전역 굵은 글꼴 사용
    [v] 전역 기울임 글꼴 사용
    [v] 전역 밑줄 글꼴 사용
> 플러그인
  > 플러그인 관리
    > 사용 가능
      찾기 : compare > [v] Compare > 설치
      찾기 : json > [v] JSON Viewer > 설치
```
