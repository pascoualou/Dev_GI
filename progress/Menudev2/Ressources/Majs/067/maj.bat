REM @echo off

REM ***********************************************************************************
REM     Programme : maj.bat
REM     Fonction  : Mise à jour de l environnement et l application Menudev2
REM ***********************************************************************************

if "%REP_MAJ%" =="" set REP_MAJ=.
if "%REP_SVG%" =="" set REP_SVG=%disque%dev\tmp
if "%FIC_SUIVI%" =="" set FIC_SUIVI=%REP_SVG%\maj.log

REM ---------------------------------------
REM Sauvegarde des fichier de l utilisateur
REM ---------------------------------------
echo Sauvegarde des fichiers de l utilisateur >> %FIC_SUIVI%
copy /Y %windir%\outilsg*.ini "%REP_SVG%"
copy /Y %DLC%\asvarenv.i "%REP_SVG%"
copy /Y %DLC%\dfvarenv.i "%REP_SVG%"

REM -------------------
REM Copies des fichiers
REM -------------------
echo Copies des fichiers de la mise a jour >> %FIC_SUIVI%
copy /Y "%REP_MAJ%\Fichiers\asvarenv.i" %DLC_V10%
copy /Y "%REP_MAJ%\Fichiers\dfvarenv.i" %DLC_V10%
copy /Y "%REP_MAJ%\Fichiers\asvarenv.i" %DLC_V11%
copy /Y "%REP_MAJ%\Fichiers\dfvarenv.i" %DLC_V11%

setx PROPATH .,%%DLC%%,%%DLC%%\bin,h:\dev\outils\progress

