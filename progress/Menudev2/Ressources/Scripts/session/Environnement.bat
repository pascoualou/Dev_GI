@echo off
REM ****************************************************************************
REM * Module de positionnement sur un environnement spécifique                 *
REM *                                                                          *
REM * Pascal LUCAS                                                             *
REM * Le 08/01/2015                                                            *
REM *                                                                          *
REM * %1 : version demandée                                                    *
REM * %2 : surcharge variable reseau                                           *
REM * %3 : surcharge environnement                                             *
REM ****************************************************************************

@echo off
REM ****************************************************************************
REM * Module de positionnement de l'environnement                              *
REM * Pascal LUCAS                                                             *
REM * Le 08/01/2015                                                            *
REM *                                                                          *
REM * %1 : environnement demandé (CLI, DEV, PREC, SUIV, SPE)                   *
REM * %2 : Reseau (si client/serveur)                                          *
REM * %3 : RepGI                                                               *
REM * %4 : Disque                                                              *
REM ****************************************************************************

echo     --------------------------- Environnement.bat : Parametres en entree ------------------------------------
echo     %%1 (Environnement demande)..... = %1
echo     %%2 (Reseau (si client/serveur)) = %2
echo     %%3 (RepGI)..................... = %3
echo     %%4 (Disque).................... = %4

set DISQUE=%4
set REPGI=%3
set RESEAU=%DISQUE%
if not "%2"=="-" set RESEAU=%2
rem nom du .pf et du .ini
set PF_INI=gi
if "%1"=="DEV" set PF_INI=gidev


rem trace de controle
echo     ------------------------------ Positionnement de l environnement ----------------------------------------
echo     Environnement = %1
echo     Disque....... = %DISQUE%
echo     Reseau....... = %RESEAU%
echo     repgi........ = %REPGI%

rem fin du script
rem surtout pas de 'EXIT'
