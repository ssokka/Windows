@echo off
setlocal
pushd %~dp0

set _pf=%ProgramFiles(x86)%
if not exist "%_pf%" set _pf=%ProgramFiles%

move /y %~n0.bak "%_pf%\NetSarang\Xshell 6\nslicense.dll"
