dim $handle
AutoItSetOption("WinWaitDelay", 250)
AutoItSetOption("WinTitleMatchMode", 3)
;MsgBox(0,"Debug",$CmdLine[1])
$handle = WinGetHandle($CmdLine[1])
WinActivate($handle,"")
;MsgBox(0,"Debug",$CmdLine[2])
send("{TAB}" & $CmdLine[2] & "{ENTER}" & "^t")
