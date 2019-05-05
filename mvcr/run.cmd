@echo off
setlocal
powershell.exe -command "(new-object System.Net.WebClient).DownloadFile(\"https://raw.githubusercontent.com/ssokka/windows/master/tools/nircmdc.exe\",\"nircmdc.exe\")"
powershell.exe -command "(new-object System.Net.WebClient).DownloadFile(\"https://raw.githubusercontent.com/ssokka/windows/master/mvcr/install.cmd\",\"install.cmd\")"
powershell.exe -command "(Get-Content \"install.cmd\" -Raw).Replace("`n","`r`n") | Set-Content \"install.cmd\" -Force"
nircmdc.exe elevate install.cmd