@echo off

rem Cas ou les infos sont passées en parametre
set TEMPO_VER=%HC_VER%
if not "%2" == "" set TEMPO_VER=%2

echo Ouverture des serveurs sur  %TEMPO_VER% >%disque%tmp\null

rem Saisie de la version
set /P TEMPO_VER="Version à utiliser (CLI, PREC, SUIV, SPE, TRC) ? (%TEMPO_VER%) : "
if "%TEMPO_VER%" == "" set TEMPO_VER=%HC_VER%
if "%TEMPO_VER%" == "" goto VER_ INCONNUE
rem Sauvegarde de la version pour la prochaine fois
setX HC_VER %TEMPO_VER% 1>%disque%tmp\null



rem verification de l'environnement
set DISQUE_REF=%DISQUE%
if "%TEMPO_VER%" == "PREC" set DISQUE=%DISQUE_REF%gi_prec\
if "%TEMPO_VER%" == "SUIV" set DISQUE=%DISQUE_REF%gi_suiv\
if "%TEMPO_VER%" == "SPE" set DISQUE=%DISQUE_REF%gi_spe\
if "%TEMPO_VER%" == "TRC" set DISQUE=%DISQUE_REF%gitrace\

if not exist %DISQUE%\gi\exe\gi.exe goto ENV_INCONNU

set RESEAU=%DISQUE%

echo.
echo Lancement de l'application sur %DISQUE%

set REPGI=gi

%DISQUE%gi\exe\gi.exe %DISQUE%gi\ress\init\gint.ini %DISQUE%gi\ress\init\gi.pf ADB

goto FIN

:VER_INCONNUE
echo.
echo Version inconnue !!!
pause
goto FIN

:ENV_INCONNU
echo.
echo Environnement de version inconnu !!!
pause
goto FIN

:FIN
exit