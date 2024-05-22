### Xshell 설치 `CMD`
```
set _url=https://raw.githubusercontent.com/ssokka/Windows/master/Xshell/install.ps1
powershell start -v runas wt 'powershell iex ([Net.WebClient]::new()).DownloadString(''%_url%'')'

```

### 설정
```
> 보기
  > 도구 모음
    [ ] 주소 표시줄
    [ ] 연결 표시
> 도구
  > 웹에서 검색
    > 검색 엔진 관리
      [V] 구글, 네이버, 다음, Bing
  > 옵션
    > 고급
      [ ] Xshel 시작 시 세션 대화 상자 열기
> 파일 > 세션 등록 정보
  > 연결
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
    글꼴: Consolas
    한글 글꼴: Consolas
    글꼴 품질: Natural ClearType
```

### 참고

#### 최신 평가 버전 다운로드
- https://www.filehorse.com/download-xshell-free/  
- 30일 날짜 제한

#### 업데이트 내역
- https://www.netsarang.com/json/product/update.html?productcode=2&languagestatus=1
