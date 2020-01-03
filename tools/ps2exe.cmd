@echo off
setlocal

rem ANSI / CP949 / CRLF

set _github=https://raw.githubusercontent.com/ssokka/Windows/master

set _ps2exe=D:\Windows\Powershell\PS2EXE-GUI\ps2exe.ps1
if not exist "%_ps2exe%" goto :eof

if "%~1" equ "" goto :exit
if "%~2" equ "" goto :exit

set _path=D:\GitHub\Windows\%~1
if not exist "%_path%" goto :eof

echo Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('%_github%/%~1/install.ps1')) > "%_path%\%~1.ps1"
if not exist %_path%\%~1.ps1 goto :eof

powershell.exe -NoProfile -InputFormat None -ExecutionPolicy Bypass ^
-File "%_ps2exe%" ^
-inputFile "%_path%\%~1.ps1" ^
-outputFile "%_path%\%~1.exe" ^
-iconFile "%_path%\images\logo.ico" ^
-elevated ^
-title "%~2" ^
-description "%~2" ^
-company "SSOKKA" ^
-product "%~2" ^
-copyright "Copyright SSOKKA. All rights reserved." ^
-version "1.0.0.0"

del /f /q "%_path%\%~1.exe.config"
del /f /q "%_path%\%~1.ps1"
goto :eof

:exit
echo Use	ps2exe.cmd [dir] [title]
echo Info	https://gallery.technet.microsoft.com/scriptcenter/PS2EXE-GUI-Convert-9b4b0493