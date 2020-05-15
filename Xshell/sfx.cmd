@echo off
setlocal
pushd %~dp0

set _file=restore
set _pass=sokaapp1!

"C:\Program Files\WinRAR\WinRAR.exe" a -c- -cfg- -ep -ep1 -hp%_pass% -iadm -iicon"%_file%.ico" -inul -m5 -ma5 -o+ -p%_pass% -sfx -s -y -z"%_file%.txt" "%_file%.exe" "%_file%.cmd" "%_file%.vbs" "%_file%.bak"
