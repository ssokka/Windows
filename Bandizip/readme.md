### [CMD] 반디집 설치
```
set _url=https://raw.githubusercontent.com/ssokka/Windows/master/Bandizip/install.ps1
powershell start -v runas wt 'powershell iex ([Net.WebClient]::new()).DownloadString(''%_url%'')'

```

### 설정
```
> 일반 설정
  [v] 자석 기능 사용
> 파일 연결
  전부 선택 > [ ] ISO > 지금 적용
> 탐색기 메뉴
  [v] 여기에 풀고 삭제하기
  [v] 알아서 풀고 삭제하기
  [ ] "파일명.7z"로 압축하기
  [v] 관리자 권한으로 압축하기
  [v] 명령 창(cmd) 열기 (Shift 키를 누르면 관리자 권한으로 실행 가능)
  [v] 탐색기 메뉴를 계단식으로 보여주기
  [v] 파일 확장자에 상관없이 파일 내용으로 압축 파일 여부 판단
> 압축 풀기
  [ ] 압축 풀기 완료 후 창을 닫지 않기
> 압축 하기
  [ ] 압축 풀기 완료 후 창을 닫지 않기
  압축 방법: 압축률 최대
> 보기/편집
  파일 목록의 글꼴 바꾸기: Consolas
  트리 컨트롤의 글꼴 바꾸기: Consolas
  압축 파일 설명 창의 글꼴 바꾸기: Consolas
  편집기: C:\Program Files\Notepad++\notepad++.exe
> 고급 설정
  [v] 압축 파일을 열 때 탐색기에서 삭제 가능한 상태로 열기
```
