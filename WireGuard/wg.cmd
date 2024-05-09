@echo off
setlocal
pushd %~dp0

if "%1" == "" goto :eof

wt powershell -NoProfile -ExecutionPolicy Bypass -Command ". '%cd%\wg.ps1'\; %1"
