@echo off
setlocal enabledelayedexpansion

set _title=Microsoft Visual C++ 재배포 가능 패키지 설치
set _reboot=0

echo.
echo  ### %_title% 시작 ###
echo.

set _ver=2005
set _sp=SP1
set _opt=/q
set _url=https://download.microsoft.com/download/1/e/4/1e4d029e-1d34-4ca8-b269-2cfeb91bd066/vcredist_
call :install

set _ver=2008
set _sp=SP1
set _opt=/q
set _url=https://download.microsoft.com/download/5/d/8/5d8c65cb-c849-4025-8e95-c3966cafd8ae/vcredist_
call :install

set _ver=2010
set _sp=SP1
set _opt=/q /norestart
set _url=https://download.microsoft.com/download/1/6/5/165255e7-1014-4d0a-b094-b6a430a6bffc/vcredist_
call :install

set _ver=2012
set _sp=SP4
set _opt=/quiet /norestart
set _url=https://download.microsoft.com/download/0/d/8/0d8c2d7c-75dd-409d-b70a-fdc0953343c1/vsu4/vcredist_
call :install

set _ver=2013
set _sp=
set _opt=/quiet /norestart
set _url=http://download.microsoft.com/download/f/8/d/f8d970bd-4218-49b9-b515-e6f1669d228b/vcredist_
call :install

rem set _ver=2015
rem set _sp=sp3
rem set _opt=/quiet /norestart
rem set _url=https://download.microsoft.com/download/6/a/a/6aa4edff-645b-48c5-81cc-ed5963aead48/vc_redist.
rem call :install

rem set _ver=2017
rem set _sp=
rem set _opt=/quiet /norestart
rem set _url=https://aka.ms/vs/15/release/vc_redist.
rem call :install

set _ver=2019
set _sp=
set _opt=/quiet /norestart
set _url=https://aka.ms/vs/16/release/VC_redist.
call :install

echo  ### %_title% 완료 ###
echo.
pause

goto :eof

:install
for /l %%i in (1,1,2) do (
	if %%i equ 1 (
		set _bit=X86
	) else (
		set _bit=X64
		if not exist "%ProgramFiles(x86)%" goto :eof
	)
	if defined _sp (
		set _name=%_ver% %_sp% !_bit!
		set _exe=%temp%\MVCR-%_ver%-%_sp%-!_bit!.exe
	) else (
		set _name=%_ver% !_bit!
		set _exe=%temp%\MVCR-%_ver%-!_bit!.exe
	)
	echo      + !_name! 다운로드
	powershell -command "(new-object System.Net.WebClient).DownloadFile(\"%_url%!_bit!.exe\", \"!_exe!\")"
	if exist "!_exe!" (
		echo      + !_name! 설치
		"!_exe!" %_opt%
	) else (
		echo      ! !_name! 오류
	)
	echo.
)
goto :eof
