@echo off
:: windows utf-8 crlf
setlocal
pushd %temp%

set _ps=powershell.exe -nop -ep bypass
set _url=https://raw.githubusercontent.com/ssokka/Windows/master/PowerShell
set _ps1=font.ps1

%_ps% -c "& {[Net.WebClient]::new().DownloadFile('%_url%/%_ps1%', '%_ps1%')}"

if exist "%_ps1%" %_ps% -f "%_ps1%"
