@echo off
REM ****************************************************************************
REM * Module de lancement de l application GI sur l environnement en cours     *
REM *                                                                          *
REM * Pascal LUCAS                                                             *
REM * Le 08/01/2015                                                            *
REM *                                                                          *
REM ****************************************************************************

echo     --------------------------------- Lancement application avec -------------------------------------------
echo     Disque = %Disque%
echo     Reseau = %Reseau%
echo     Repgi  = %Repgi%
echo     PF_INI = %PF_INI%
echo     Ligne de commande : 
echo     %DISQUE%%REPGI%\exe\gi.exe %DISQUE%%REPGI%\ress\init\%PF_INI%nt.ini %DISQUE%%REPGI%\ress\init\%PF_INI%.pf ADB

%DISQUE%%REPGI%\exe\gi.exe %DISQUE%%REPGI%\ress\init\%PF_INI%nt.ini %DISQUE%%REPGI%\ress\init\%PF_INI%.pf ADB

rem fin du script
rem surtout pas de 'EXIT'