set wshell = createobject("wscript.shell")
set fso = createobject("scripting.filesystemobject")
wshell.run chr(34) & fso.getbasename(wscript.scriptname) & ".cmd" & chr(34), 0
set wshell = nothing
set fso = nothing