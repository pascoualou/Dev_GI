REM @echo off

REM ***********************************************************************************
REM     Programme : maj.bat
REM     Fonction  : Mise � jour de l environnement et l application Menudev2
REM ***********************************************************************************

REM ---------------------------------------
REM Sauvegarde des fichier de l utilisateur
REM ---------------------------------------
echo Sauvegarde des fichiers de l utilisateur >> %FIC_SUIVI%
rem copy %dlc%\asvarenv.i %REP_SVG%
copy %windir%\system32\drivers\etc\services %REP_SVG%

REM -------------------
REM Copies des fichiers
REM -------------------
echo Copies des fichiers de la mise a jour >> %FIC_SUIVI%
rem copy %REP_MAJ%\Fichiers\asvarenv.i %dlc%
echo gidata          8999993/tcp     # pour menudev2 >> %windir%\system32\drivers\etc\services
