#AutoIt3Wrapper_Run_Tidy=Y
#AutoIt3Wrapper_Compression=0
#AutoIt3Wrapper_UseUpx=N
#AutoIt3Wrapper_Change2CUI=Y

#NoTrayIcon

If $CmdLine[0] < 2 Or Not FileExists($CmdLine[2]) Then Exit
If $CmdLine[1] <> 'utf8' And $CmdLine[1] <> 'ansi' Then Exit

If $CmdLine[1] = 'utf8' Then
	$CmdLine[1] = 256
Else
	$CmdLine[1] = 512
EndIf

$encoding = FileGetEncoding($CmdLine[2])
If $encoding = $CmdLine[1] Then Exit
$open = FileOpen($CmdLine[2], $encoding)
$read = FileRead($open)
FileClose($open)
$open = FileOpen($CmdLine[2], 2 + $CmdLine[1])
FileWrite($open, $read)
FileClose($open)
