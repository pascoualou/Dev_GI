;===================================================================================================================================================
;
; Programme    : tooltip.au3
; Descriptif   : Affichage d'une info bulle dans la zone tray
;
; Paramètre(s) :
;       param1 = titre de la bulle
;       param2 = nom du fichier contenant le message de la bulle (Attention:ne pas passer un message car pb de code page entre progress/dos/autoit)
;       param3 = Temps d'affichage de la bulle
;       param4 = option (0, 1, 2 ou 3) = icone du message : 0=rien, 1=information, 2=Avertissement, 3=Erreur
;
; Prérequis    :  Aucun
; Retour       :  Aucun
; Auteur(s)    :  Pascal LUCAS
; Date         :  15/04/2008
;
;===================================================================================================================================================

; Paramètres :
; param1 = titre de la bulle
; param2 = nom du fichier contenant le message de la bulle (Attention:ne pas passer un message car pb de code page entre progress/dos/autoit)
; param3 = Temps d'affichage de la bulle
; param4 = option (0, 1, 2 ou 3) = icone du message : 0=rien, 1=information, 2=Avertissement, 3=Erreur

; Include standard
#include "i_Environnement.au3"

; Ne pas afficher l'icone dans la barre de tache au démarrage du script
#NoTrayIcon

; Définition des variables de travail
Dim $dif, $begin, $cLibelle, $FichierAlerte

; Triggers sur la zone trayicon
TraySetOnEvent($TRAY_EVENT_PRIMARYDOWN, "FermetureBulle")

;~ ; Récupération du message à afficher dans la bulle
;~ $FichierAlerte = FileOpen($CmdLine[2], 0) ; Ouvre le fichier
;~ If $FichierAlerte = -1 Then
;~ 	MsgBox(0, $gcScript, "Erreur !!!" & @LF & "Impossible d'ouvrir le fichier : " & $CmdLine[2])
;~ 	Exit
;~ EndIf
;~ $cLibelle = FileRead($FichierAlerte) ; Lit le fichier en entier
;~ FileClose($FichierAlerte) ; Ferme le fichier

;~ ; Ajout des sauts de ligne si nécessaire
;~ $cLibelle = StringReplace($cLibelle, "[SautLigne]", @LF)

$cLibelle = StringReplace ($CmdLine[2],"%s",@LF)

; Affichage de la bulle
TraySetState(1) ; affichage de l'icone (obligatoire pour afficher la bulle)
TrayTip($CmdLine[1], $cLibelle, $CmdLine[3], $CmdLine[4]) ; affichage de la bulle sur l'icone

;~ ; Temporisation d'affichage de la bulle
$begin = TimerInit()
While 1
	Sleep(5000)
	$dif = TimerDiff($begin)
	If $dif >= ($CmdLine[3] * 1000) Then
		Exit
	EndIf
WEnd
TraySetState(0) ; Suppression de l'icone et donc de la bulle

; Fin du programme
;Exit

Func FermetureBulle()
	;===================================================================================================================================================
	;
	; Fonction     : FermetureBulle
	; Descriptif   : Fermeture de la bulle sur le clique
	;
	; Paramètre(s) : Aucun
	;
	; Retour       : Aucun
	;
	;===================================================================================================================================================
	TraySetState(0) ; Suppression de l'icone
	Exit ; Sortie du programme
EndFunc   ;==>FermetureBulle