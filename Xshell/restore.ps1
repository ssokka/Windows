$file = 'nslicense.dll'

$src = "$PSScriptRoot\$file"

$dst = ${env:ProgramFiles(x86)}
$dst = if (!(Test-Path $dst)) {${env:ProgramFiles}} else {$dst}
$dst += "\NetSarang\Xshell 6\$file"

Start-Process "${env:comspec}" "/c move /y `"$src`" `"$dst`"" -Verb RunAs -WindowStyle Normal -Wait
