@echo off

rem 1 = R�pertoire racine de la version
rem 2 = Nom Du fichier de sauvegarde
rem 3 = Taux de compression

REM Chargement environnement standard
call dfvarenv.bat

echo Positionnement dans le bon r�pertoire

rem suppression du r�pertoire a restorer
del /Q /F /S %disque%%1
rmdir /Q /S %disque%%1

rem cr�ation du repertoire � restorer
mkdir %disque%%1

echo Decompression du fichier %2
%LOC_APPLI%\exe\7-zip\7z.exe x -y -o%disque%%1 %2 

echo avertissement du demandeur
call %SER_OUTILS%\ActionMenudev2.bat ORDREONGLET#BASES-INFOS#%DEVUSR%#Menudev2#0#"Restauration de la version %2 dans %disque%%1 terminee"


REM ----------------
REM Relance Menudev2
REM ----------------
if "%RESEAUBIS%" == "" goto MENUDEV-NORMAL
start %DEV%\Progress\menudev2\LanceMenudev2-hl.bat

goto FIN
:MENUDEV-NORMAL
start %DEV%\Progress\menudev2\LanceMenudev2.bat
:FIN
exit