dim $handle
AutoItSetOption("WinWaitDelay", 250)
AutoItSetOption("WinTitleMatchMode", 3)
;MsgBox(0,"Debug",$CmdLine[1])
$handle = WinGetHandle($CmdLine[1])
WinActivate($handle,"")
send("mastergi{TAB}0145183500{ENTER}")
