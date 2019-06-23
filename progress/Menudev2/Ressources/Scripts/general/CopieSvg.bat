rem @echo off
set LIBOK=Copie de la base %6 / %3 en local
set LIBERREUR=Erreur lors de la copie de la base %6 / %3 en local
set erreur=0

rem Connexion a la machine source
rem on commence par supprimer tout lien éventuel à la machine source
net use \\%1\bases /D
rem et a l'ancien mappage permanent sur xcompil
if not "%DEVUSR:~0,2%" == "VM" net use z: /D
net use x: /D
net use b: /D
if "%DEVUSR:~0,2%" == "VM" net use w: /D

rem Montage du disque
net use b: \\%1\bases %5 /user:%4
set erreur=%errorlevel%
if not %erreur%==0 goto FIN

:SUITE1
echo Connexion OK

mkdir %2\%3
mkdir %2\%3\svg
call %SER_OUTILS%\ActionMenudev2.bat ORDREONGLET#BASES-INFOS#%DEVUSR%#Menudev2#0#"Copie de la base %6 / %3 en cours..."
copy b:\%3\svg\%3.7z %2\%3\svg

:FIN
rem Suppression du mappage sur le disque b:
if exist b:\_Dispo.txt net use b: /D

echo avertissement du demandeur
call %SER_OUTILS%\progress\Menudev2\Ressources\Scripts\serveurs\finscript.bat COPIE %erreur%
if %erreur%==0 call %SER_OUTILS%\ActionMenudev2.bat ORDREONGLET#BASES-INFOS#%6#%DEVUSR%#0#"Recuperation de ta sauvegarde de la base %3 terminee."

rem relancer mappage.bat pour reconnecter les lecteurs réseau
call %SER_OUTILS%\progress\Menudev2\Ressources\Scripts\general\mappage.bat


exit