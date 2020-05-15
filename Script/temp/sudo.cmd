@echo off
setlocal EnableDelayedExpansion

:: check first argument
set _chk=%2
if not defined _chk goto exit /b 1

:: get process
if "%~n1" == "powershell" set _ps=1
set _exec=%~1
shift

:: get arguments
:start
set _arg=%1
if not defined _arg goto stop
::if not defined _ps (
	set "_arg=!_arg:"=\"!"
	set "_arg=!_arg:'=''!"
::)
if not defined _args (
	if defined _ps (
		set "_args=!_arg!"
	) else (
		set "_args='!_arg!'"
	)
	goto shift
)
if defined _ps (
	set "_args=!_args! !_arg!"
) else (
	set "_args=!_args!,'!_arg!'"
)
:shift
shift
goto start
:stop

::if defined _ps set "_args=\"-NoExit -NoProfile -Command "& !_args!"\""

echo "args = !_args!"
goto :eof

::https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/start-process?view=powershell-7 -WindowStyle Hidden
powershell.exe -NoProfile -Command "& { Start-Process -FilePath '%_exec%' -ArgumentList '!_args!' -Verb RunAs -Wait }"
