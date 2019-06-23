@echo off

REM ***********************************************************************************
REM     Programme : maj-menudev2.bat
REM     Fonction  : Mise à jour de l environnement et l application Menudev2
REM ***********************************************************************************

REM ------------
REM Parametres :
REM ------------
REM 1 : Numero de version
REM 2 : Code Utilisateur
REM 3 : Version de depart
REM 4 :

REM ------------------------
REM Définition environnement
REM ------------------------
call dfvarenv.bat

REM Avertissement si pb chargement dfvarenv.bat
if not "%SER_OUTILS%" == "" goto SUITE_NORMALE

echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo.
echo Probleme lors du chargement de dfvarenv.bat. 
echo Il manque le répertoire %reseau%dev\outils dans le path !!!!
echo.
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
pause 
exit

:SUITE_NORMALE
md %USERPROFILE%\AppData\Local\Menudev2
md %USERPROFILE%\AppData\Local\Menudev2\Versions
md %USERPROFILE%\AppData\Local\Menudev2\Versions\Suivi
md %USERPROFILE%\AppData\Local\Menudev2\Versions\Derniere
md %USERPROFILE%\AppData\Local\Menudev2\Versions\Svgs
md %USERPROFILE%\AppData\Local\Menudev2\Versions\Svgs\%3
set REP_MAJ=%SER_OUTILS%\progress\Menudev2\Ressources\Majs\%1
set REP_SVG=%USERPROFILE%\AppData\Local\Menudev2\Versions\Svgs\%3
set FIC_SUIVI=%USERPROFILE%\AppData\Local\Menudev2\Versions\Suivi\%1
set FIC_UTIL=%SER_OUTILS%\progress\Menudev2\Ressources\Majs\%1\Suivi\%2

REM --------------------------
REM Affichage des informations
REM --------------------------
echo. > %FIC_SUIVI%
echo Informations... >> %FIC_SUIVI%
echo Maj numero       : %1 >> %FIC_SUIVI%
echo Utilisateur      : %2 >> %FIC_SUIVI%
echo Version initiale : %3 >> %FIC_SUIVI%
echo. >> %FIC_SUIVI%
echo Repertoires... >> %FIC_SUIVI%
echo Profile/Menudev2 : %USERPROFILE%\AppData\Local\Menudev2 >> %FIC_SUIVI%
echo Profile/Versions : %USERPROFILE%\AppData\Local\Menudev2\Versions >> %FIC_SUIVI%
echo Profile/Suivi    : %USERPROFILE%\AppData\Local\Menudev2\Versions\Suivi >> %FIC_SUIVI%
echo Profile/Derniere : %USERPROFILE%\AppData\Local\Menudev2\Versions\Derniere >> %FIC_SUIVI%
echo Profile/Svgs     : %REP_SVG% >> %FIC_SUIVI%
echo Rep_Maj          : %REP_MAJ% >> %FIC_SUIVI%
echo Windir           : %windir% >> %FIC_SUIVI%
echo DLC              : %DLC% >> %FIC_SUIVI%
echo. >> %FIC_SUIVI%
echo Fichiers... >> %FIC_SUIVI%
echo Fic_Suivi        : %FIC_SUIVI% >> %FIC_SUIVI%
echo Fic_Util         : %FIC_UTIL% >> %FIC_SUIVI%



REM ************************************************************************************
REM
REM             >>>>>>>>>>>>>>>>>>> CORPS DE LA MAJ <<<<<<<<<<<<<<<<<<<<<<<
REM 
REM ************************************************************************************



call %REP_MAJ%\maj.bat



REM ************************************************************************************
REM
REM           >>>>>>>>>>>>>>>>>>> FIN CORPS DE LA MAJ <<<<<<<<<<<<<<<<<<<<<<<
REM 
REM ************************************************************************************

REM ----------------
REM Trace de version
REM ----------------
REM echo. > %FIC_UTIL%
copy %FIC_SUIVI% %FIC_UTIL%


REM Pour debug
REM exit

REM ----------------
REM Relance Menudev2
REM ----------------
echo Mise à jour terminée. Menudev2 va se relancer...
if "%RESEAUBIS%" == "" goto MENUDEV-NORMAL
start %DEV%\Progress\menudev2\LanceMenudev2-hl.bat

goto FIN
:MENUDEV-NORMAL
start %DEV%\Progress\menudev2\LanceMenudev2.bat
:FIN
exit