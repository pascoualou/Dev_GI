@echo off

rem Cas ou les infos sont passées en parametre
set TEMPO_REF=%HC_REF%
set TEMPO_VER=%HC_VER%

if not "%1" == "" set TEMPO_REF= %1
if not "%2" == "" set TEMPO_VER=%2

echo Ouverture des serveurs sur %TEMPO_REF% / %TEMPO_VER% >%disque%tmp\null

rem Saisie de la référence
set /P TEMPO_REF="Référence (5 derniers caractères du fichier cnx) ? (%TEMPO_REF%) : "
if "%TEMPO_REF%" == "" set TEMPO_REF=%HC_REF%
if "%TEMPO_REF%" == "" goto REF_INCONNUE
rem Sauvegarde de la reference pour la prochaine fois
setX HC_REF %TEMPO_REF% 1>>%disque%tmp\null

rem Saisie de la version
set /P TEMPO_VER="Version à utiliser (CLI, PREC, SUIV, SPE, TRC) ? (%TEMPO_VER%) : "
if "%TEMPO_VER%" == "" set TEMPO_VER=%HC_VER%
if "%TEMPO_VER%" == "" goto VER_ INCONNUE
rem Sauvegarde de la version pour la prochaine fois
setX HC_VER %TEMPO_VER% 1>%disque%tmp\null



rem verification de l'environnement
set REP=%DISQUE%
if "%TEMPO_VER%" == "TRC" set TEMPO_VER=SPE
if "%TEMPO_VER%" == "PREC" set REP=%DISQUE%gi_prec\
if "%TEMPO_VER%" == "SUIV" set REP=%DISQUE%gi_suiv\
if "%TEMPO_VER%" == "SPE" set REP=%DISQUE%gi_spe\

if not exist %REP%\gi\exe\gi.exe goto ENV_INCONNU

call %disque%dev\outils\HorsConnexion\psenvbases.bat
cd \
cd bases

echo.
echo Traitement des bases (Ouverture) ...
echo.
echo --- sadb
_mprosrv %TEMPO_REF%\sadb.db -L 25000 -n 50 -B 600 -Ma 7 -Mn 7 -Mi 2
echo.
echo --- compta
_mprosrv %TEMPO_REF%\compta.db -L 25000 -n 50 -B 600 -Ma 7 -Mn 7 -Mi 2
echo.
echo --- cadb
_mprosrv %TEMPO_REF%\cadb.db -L 25000 -n 50 -B 600 -Ma 7 -Mn 7 -Mi 2
echo.
echo --- inter
_mprosrv %TEMPO_REF%\inter.db -L 25000 -n 50 -B 600 -Ma 7 -Mn 7 -Mi 2
echo.
echo --- transfer
_mprosrv %TEMPO_REF%\transfer.db -L 25000 -n 50 -B 600 -Ma 7 -Mn 7 -Mi 2
echo.
echo --- dwh
_mprosrv %TEMPO_REF%\dwh.db -L 25000 -n 50 -B 600 -Ma 7 -Mn 7 -Mi 2
echo.
echo Traitement des bases libellé....
_mprosrv %REP%gi\baselib\ladb.db -L 25000 -n 50 -B 600 -Ma 7 -Mn 7 -Mi 2
_mprosrv %REP%gi\baselib\wadb.db -L 25000 -n 50 -B 600 -Ma 7 -Mn 7 -Mi 2
_mprosrv %REP%gi\baselib\ltrans.db -L 25000 -n 50 -B 600 -Ma 7 -Mn 7 -Mi 2
_mprosrv %REP%gi\baselib\lcompta.db -L 25000 -n 50 -B 600 -Ma 7 -Mn 7 -Mi 2

goto FIN

:REF_INCONNUE
echo.
echo Référence inconnue !!!
pause
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
pause
exit