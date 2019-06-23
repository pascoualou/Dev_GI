REM @echo off

REM ***********************************************************************************
REM     Programme : maj.bat
REM     Fonction  : Mise à jour de l environnement et l application Menudev2
REM ***********************************************************************************

REM ---------------------------------------
REM Sauvegarde des fichier de l utilisateur
REM ---------------------------------------
echo Sauvegarde des fichiers de l utilisateur >> %FIC_SUIVI%
copy %windir%\outilsgi-11.ini %windir%\outilsgi_V11.ini
copy %windir%\outilsg2-11.ini %windir%\outilsg2_V11.ini
copy %windir%\outilsg3-11.ini %windir%\outilsg3_V11.ini
copy /Y %windir%\outilsg*.ini %REP_SVG%
del %windir%\outilsgi-11.ini
del %windir%\outilsg2-11.ini
del %windir%\outilsg3-11.ini

REM -------------------
REM Copies des fichiers
REM -------------------
echo Copies des fichiers de la mise a jour >> %FIC_SUIVI%
copy /Y %REP_MAJ%\Fichiers\outilsg*.ini %windir%
copy c:\pfgi\cnxmndev_v117.pf c:\pfgi\cnxmndev_v11.pf
del c:\pfgi\cnxmndev_v117.pf
