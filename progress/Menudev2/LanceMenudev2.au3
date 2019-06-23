dim $handle, $title

; Mode de recherche des window
AutoItSetOption("WinTitleMatchMode", 1)

; Recherche handle de la fenetre
$handle = WinGetHandle("Menu développeur -")

; Si fenetre trouvée, on récupère le titre exact
$title = WinGetTitle("GI -", "")

; et on l'active
if $title <> "" Then 
	WinActivate($title,"")
else 
	Run ("H:\dev\outils\progress\Menudev2\lancemenudev2.bat", "", @SW_ENABLE)
EndIf