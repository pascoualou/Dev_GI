@echo off

REM ------------------------
REM Définition environnement
REM ------------------------
call dfvarenv.bat

REM ----------------
REM Relance Menudev2
REM ----------------

rem boucle d'attente
set iAttente=0
:BOUCLE
if %iAttente%==2000 goto SUITE
set /a iAttente=%iAttente%+1
goto BOUCLE
:SUITE

echo Mise à jour terminée. Menudev2 va se relancer...
if "%RESEAUBIS%" == "" goto MENUDEV-NORMAL
start %DEV%\Progress\menudev2\LanceMenudev2-hl.bat

goto FIN
:MENUDEV-NORMAL
start %DEV%\Progress\menudev2\LanceMenudev2.bat
:FIN
exit