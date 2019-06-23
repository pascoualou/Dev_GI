; ----------------------------------------------------------------
; SaisieAutomatique.au3
; 29/03/2016
; PL
;
; Saisie automatique de données sur une fenetre
;
; ----------------------------------------------------------------
; 9999	99/99/9999	XXX		XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;
; ----------------------------------------------------------------

; Variables de travail
dim $handle
dim $Touches

; Configuration de autoit
AutoItSetOption("WinWaitDelay", 250)
AutoItSetOption("WinTitleMatchMode", 3)

;MsgBox(0,"Debug",$CmdLine[1])

; Récupération et activation de la fenetre par son nom passé en parametre
$handle = WinGetHandle($CmdLine[1])
WinActivate($handle,"")

; gestion des touches particulières
;MsgBox(0,"Debug",$CmdLine[2])
$Touches = $CmdLine[2]
$Touches = StringReplace( $Touches,"%tab%","{TAB}")
$Touches = StringReplace( $Touches,"%return%","{ENTER}")
$Touches = StringReplace( $Touches,"%enter%","{ENTER}")
$Touches = StringReplace( $Touches,"%ctrl%","^")

; Envoi des données à la fenetre
;MsgBox(0,"Debug",$Touches)
send($Touches)
