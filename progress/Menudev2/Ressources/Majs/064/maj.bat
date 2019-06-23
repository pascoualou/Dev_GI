REM @echo off

REM ***********************************************************************************
REM     Programme : maj.bat
REM     Fonction  : Mise à jour de l environnement et l application Menudev2
REM ***********************************************************************************

REM ---------------------------------------
REM Sauvegarde des fichier de l utilisateur
REM ---------------------------------------
echo Sauvegarde des fichiers de l utilisateur >> %FIC_SUIVI%
copy /Y %dlc%\asvarenv.i %REP_SVG%
copy /Y %dlc%\dfvarenv.i %REP_SVG%
copy /Y %windir%\outilsg*.ini %REP_SVG%

REM -------------------
REM Copies des fichiers
REM -------------------
echo Copies des fichiers de la mise a jour >> %FIC_SUIVI%
copy /Y %REP_MAJ%\Fichiers\asvarenv.i %dlc%
copy /Y %REP_MAJ%\Fichiers\asvarenv.i %dlc_V10%
copy /Y %REP_MAJ%\Fichiers\asvarenv.i %dlc_V11%
copy /Y %REP_MAJ%\Fichiers\dfvarenv.i %dlc%
copy /Y %REP_MAJ%\Fichiers\dfvarenv.i %dlc_10%
copy /Y %REP_MAJ%\Fichiers\dfvarenv.i %dlc_11%
copy /Y %REP_MAJ%\Fichiers\outilsg*.ini %windir%

