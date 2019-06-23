@echo off
REM ****************************************************************************
REM * Module de lancement gestionnaire de patches sur l environnement en cours s*
REM *                                                                          *
REM * Pascal LUCAS                                                             *
REM * Le 08/01/2015                                                            *
REM *                                                                          *
REM ****************************************************************************

set COMMANDE=start "" %disque%%repgi%\exe\gespatch.exe %disque%%repgi%\ress\init\%PF_INI%.ini %disque%%repgi%\ress\init\%PF_INI%.pf ADB MANUEL

echo     ----------------------------------- Lancement Patches avec ----------------------------------------------
echo     Disque = %Disque%
echo     Reseau = %Reseau%
echo     Repgi  = %Repgi%
echo     PF_INI = %PF_INI%
echo     Ligne de commande : 
echo     %COMMANDE%

%COMMANDE%

rem fin du script
rem surtout pas de 'EXIT'