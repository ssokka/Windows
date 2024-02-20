@echo off
setlocal
pushd %~dp0

powershell start -v runas powershell '^
$ErrorActionPreference=''SilentlyContinue'';^
Write-Host ''### Start OpenVPN'';^
sasv OpenVPNService;^
gsv OpenVPNService;^
Write-Host;^
pause'
