@echo off
rem echo Entree dans 'FinScript.bat' avec param1=%1, param2=%2

set LIBMESSAGE=!!! %LIBERREUR%

if %2==0 goto FIN_NORMALE
goto FIN_ERREUR_%1_%2

rem Erreurs non gérées
:FIN_ERREUR_FERME_1
:FIN_ERREUR_FERME_3
:FIN_ERREUR_FERME_4
:FIN_ERREUR_FERME_5
:FIN_ERREUR_FERME_6
:FIN_ERREUR_FERME_7
:FIN_ERREUR_FERME_9

:FIN_ERREUR_OUVRE_1
:FIN_ERREUR_OUVRE_3
:FIN_ERREUR_OUVRE_4
:FIN_ERREUR_OUVRE_5
:FIN_ERREUR_OUVRE_6
:FIN_ERREUR_OUVRE_7
:FIN_ERREUR_OUVRE_8
:FIN_ERREUR_OUVRE_9

:FIN_ERREUR_COPIE_1
:FIN_ERREUR_COPIE_3
:FIN_ERREUR_COPIE_4
:FIN_ERREUR_COPIE_5
:FIN_ERREUR_COPIE_6
:FIN_ERREUR_COPIE_7
:FIN_ERREUR_COPIE_8
:FIN_ERREUR_COPIE_9

set LIBCOMPLEMENT=Erreur  : %2 !!!
goto SORTIE

rem Erreurs gérées
:FIN_NORMALE
set LIBMESSAGE=%LIBOK%
set LIBCOMPLEMENT=Terminee
goto SORTIE

:FIN_ERREUR_OUVRE_2
set LIBCOMPLEMENT=La base est deja ouverte ou bien le 'repair' n'est pas fait !!!
goto SORTIE

:FIN_ERREUR_FERME_2
set LIBCOMPLEMENT=La base est en cours d'utilisation !!!
goto SORTIE

:FIN_ERREUR_FERME_8
set LIBCOMPLEMENT=La base est deja fermee. Essayez de supprimer les .lk !!!
goto SORTIE

:FIN_ERREUR_COPIE_2
set LIBCOMPLEMENT=Connexion et mappage du disque B impossibles !!!
goto SORTIE

:FIN_ERREUR_COPIE_53
set LIBCOMPLEMENT=Chemin reseau inexistant. L'utilisateur n'est peut-être pas disponible !!!
goto SORTIE

:SORTIE
call %SER_OUTILS%\ActionMenudev2.bat ORDREONGLET#BASES-INFOS#%DEVUSR%#Menudev2#0#"%LIBMESSAGE% : %LIBCOMPLEMENT%"#%1
