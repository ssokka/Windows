@echo off
setlocal
pushd %~dp0

:: https://github.com/DigitalRuby/IPBan

net session >nul 2>&1
if %errorlevel% neq 0 (
	copy /y "%~f0" "%temp%\"
	goto admin
)
goto run

:admin
powershell -Command "Start-Process \"%temp%\%~nx0\" -Verb RunAs"
exit /b

:run
set _path=%ProgramFiles%\IPBan
if not exist "%_path%\DigitalRuby.IPBan.exe" powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/DigitalRuby/IPBan/master/IPBanCore/Windows/Scripts/install_latest.ps1'))"

echo.
echo ### Edit ipban.config
sc stop IPBAN
powershell -Command ^
$file = $Env:_path + '\ipban.config'; ^
$xml = [xml](Get-Content $file); ^
$node = $xml.configuration.appSettings.add ^| where {$_.key -eq 'FailedLoginAttemptsBeforeBan'}; ^
$node.value = '4'; ^
$node = $xml.configuration.appSettings.add ^| where {$_.key -eq 'BanTime'}; ^
$node.value = '00:00:00:00'; ^
$node = $xml.configuration.appSettings.add ^| where {$_.key -eq 'ExpireTime'}; ^
$node.value = '00:00:00:00'; ^
$node = $xml.configuration.appSettings.add ^| where {$_.key -eq 'Whitelist'}; ^
$node.value = '10.0.0.0/8,172.16.0.0/12,192.168.0.0/16'; ^
$node = $xml.configuration.appSettings.add ^| where {$_.key -eq 'UseDefaultBannedIPAddressHandler'}; ^
$node.value = 'false'; ^
$xml.Save($file)
sc start IPBAN

echo.
pause
