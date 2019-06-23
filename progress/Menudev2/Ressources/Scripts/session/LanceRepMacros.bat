@echo off
REM ****************************************************************************
REM * Lancement du Module de création des répertoires de travail et de copie   *
REM * des fichiers nécessaires au fonctionnement de l'environnement en cours   *
REM * Pascal LUCAS                                                             *
REM * Le 02/08/2015                                                            *
REM *                                                                          *
REM ****************************************************************************

echo     ----------------------------------- Lancement RepMacros avec ----------------------------------------------
echo     Disque = %Disque%
echo     Reseau = %Reseau%
echo     Repgi  = %Repgi%
echo     PF_INI = %PF_INI%
echo     Ligne de commande : %dev%\progress\menudev2\ressources\scripts\session\RepMacros.bat

start %dev%\progress\menudev2\ressources\scripts\session\RepMacros.bat

rem fin du script
rem surtout pas de 'EXIT'