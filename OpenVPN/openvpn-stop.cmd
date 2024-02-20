@echo off
setlocal
pushd %~dp0

powershell start -v runas powershell '^
$ErrorActionPreference=''SilentlyContinue'';^
Write-Host `n''### Stop OpenVPN'';^
spsv OpenVPNService -f;^
spps -n openvpn -f;^
spps -n openvpnserv2 -f;^
gsv OpenVPNService;^
Write-Host;^
pause'
