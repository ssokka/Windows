# UTF-8 / CRLF

# .\ps2exe.ps1
# -inputFile 'D:\GitHub\windows\mvcr\ps2exe.ps1'
# -outputFile 'D:\GitHub\windows\mvcr\mvcr.exe'
# -iconFile 'D:\GitHub\windows\mvcr\images\icon.ico'
# -elevated
# -title 'Microsoft Visual C++ 재배포 가능 패키지 설치'
# -description 'Microsoft Visual C++ 재배포 가능 패키지 설치'
# -company 'SSOKKA'
# -product 'Microsoft Visual C++ 재배포 가능 패키지 설치'
# -copyright 'Copyright SSOKKA. All rights reserved.'
# -version '1.0.0.0'

(New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ssokka/windows/master/mvcr/install.ps1')
