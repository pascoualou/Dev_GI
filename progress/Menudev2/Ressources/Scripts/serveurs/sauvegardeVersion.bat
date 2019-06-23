@echo off

rem 1 = Répertoire racine de la version
rem 2 = NomDu fichier de sauvegarde
rem 3 = Taux de compression

REM Chargement environnement standard
call dfvarenv.bat

echo Positionnement dans le bon répertoire

set REPSVG=%disque%Svg-Versions

echo Compression dans le répertoire %REPSVG%
mkdir %REPSVG%
%LOC_APPLI%\exe\7-zip\7z.exe a %3 -r %REPSVG%\%2 %disque%%1\*

echo avertissement du demandeur
call %SER_OUTILS%\ActionMenudev2.bat ORDREONGLET#BASES-INFOS#%DEVUSR%#Menudev2#0#"Sauvegarde de la version %1 dans %REPSVG%\%2 terminee"

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