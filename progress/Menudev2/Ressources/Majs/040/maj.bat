REM @echo off

REM ***********************************************************************************
REM     Programme : maj.bat
REM     Fonction  : Mise à jour de l environnement et l application Menudev2
REM ***********************************************************************************

REM ---------------------------------------
REM Sauvegarde des fichier de l utilisateur
REM ---------------------------------------
echo Sauvegarde des fichiers de l utilisateur >> %FIC_SUIVI%
copy %dlc%\asvarenv.i %REP_SVG%
copy %dlc%\dfvarenv.i %REP_SVG%
rem copy %windir%\outilsg*.ini %REP_SVG%

REM -------------------
REM Copies des fichiers
REM -------------------
echo Copies des fichiers de la mise a jour >> %FIC_SUIVI%
copy %REP_MAJ%\Fichiers\asvarenv.i %dlc%
copy %REP_MAJ%\Fichiers\dfvarenv.i %dlc%
rem copy %REP_MAJ%\Fichiers\outilsg*.ini %windir%
