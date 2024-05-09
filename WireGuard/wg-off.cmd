@echo off
setlocal
pushd %~dp0

wt powershell -NoProfile -ExecutionPolicy Bypass -Command ". '%cd%\wg.ps1'\; %~n0"
