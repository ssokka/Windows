@echo off
:: windows utf-8 crlf
setlocal
pushd %temp%

set _ps1=%~n.ps1
set _url=https://raw.githubusercontent.com/ssokka/Windows/master/%~n/%_ps1%
set _ps=powershell.exe -nop -ep bypass

%_ps% -c "& {[Net.WebClient]::new().DownloadFile('%_url%', '%_ps1%')}"

if exist "%_ps1%" %_ps% -f "%_ps1%" -d2coding -install -restore -setting -keymap -m -r -p
