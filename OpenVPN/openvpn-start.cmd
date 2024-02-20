@echo off
setlocal
pushd %~dp0

powershell start -v runas powershell '^
$ErrorActionPreference=''SilentlyContinue'';^
Write-Host `n''### Start OpenVPN'';^
sasv OpenVPNService;^
gsv OpenVPNService;^
Write-Host;^
pause'
