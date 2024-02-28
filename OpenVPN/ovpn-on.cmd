@echo off
setlocal
pushd %~dp0

wt powershell -NoProfile -ExecutionPolicy Bypass -Command ". '%cd%\ovpn.ps1'\; %~n0"

exit /b
