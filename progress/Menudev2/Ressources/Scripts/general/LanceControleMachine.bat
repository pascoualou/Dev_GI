@echo off
call dfvarenv.bat

rem Parametres recus :

rem %1 nom de l'utilisateur de menudev2
rem %2 repertoire ou trouver les bases
rem %3 repertoire basedos


rem Paramètres à envoyer si besoin (séparateur ','):

rem FICHIER-LOG=nom du fichier log sans répertoire (le répertoire sera automatiquement %disque%\dev\log)
rem REPERTOIRE-BASES=Répertoire ou trouver les bases
rem REPERTOIRE-BASESDOS=Répertoire ou trouver les basesdos issues des dump-load
rem UTILISATEUR=automatiquement assigné avec le %1 de ce batch
rem ADRESSE-EMAIL=Votre adresse mail pour être prévenu par mail
rem SVG-PRESENTE=OUI (pour vérifier qu'une sauvegarde est présente et qu'elle porte le bon nom)
rem BASE+SVG-PRESENTE=OUI (pour vérifier que la base est présente bien que la sauvegar le soit aussi (spécifique pour xcompil))
rem FICHIER-7Z=OUI (Pour vérifier si le fichier 7z est correct/viable)
rem VISU-LOG=OUI (Pour voir le fichier log en fin de traitement. non pris en compte si adresses mail saisie)
rem MAIL-QUE-SI-ERREUR=OUI (ne pas envoyer le mail si par d'erreur)
rem BASEDOS=OUI (pour vérifier la présence de bases potentiellement inutiles à cet endroit)
rem DISPONIBLE=OUI (pour avoir la place restante sur la machine par disques locaux)

rem Lancement du programme de controle en fonction du code utilisateurs
rem Ainsi chaque utilisateur peut avoir ses propres paramètres

rem parametrage par defaut pour tout le monde
set PARAMETRES=fichier-log=Controle-Machine-%1.log,repertoire-bases=%2,utilisateur=%1,mail-que-si-erreur=OUI,repertoire-basesdos=%3,basedos=OUI,disponible=OUI,



REM Parametrage par utilisateur 
rem !!! ATTENTION CASE-SENSITIVE !!!!

if "%1" == "COMPIL" set PARAMETRES=%PARAMETRES%adresse-email=plucas@la-gi.fr,visu-log=NON,svg-presente=OUI,base+svg-presente=OUI,fichier-7z=OUI
if "%1" == "PPL" set PARAMETRES=%PARAMETRES%adresse-email=plucas@la-gi.fr,visu-log=NON,svg-presente=OUI,base+svg-presente=NON,fichier-7z=OUI
if "%1" == "PPL.DEV" set PARAMETRES=%PARAMETRES%adresse-email=,visu-log=OUI,svg-presente=OUI,base+svg-presente=NON,fichier-7z=OUI
if "%1" == "Eeepc" set PARAMETRES=%PARAMETRES%visu-log=OUI,svg-presente=OUI,base+svg-presente=NON,fichier-7z=OUI



REM Lancement du programme de controle
start "" %dlc%\bin\%PROWIN% -ininame %windir%\outilsgi.ini -p "%SER_OUTILS%\progress\menudev2\sources.dev\controleMachine.p" -param "%PARAMETRES%"

exit