@echo off
REM ****************************************************************************
REM * Module de lancement d un programme depuis le menudev2 sur environnement  *
REM * spécifique                                                               *
REM * Pascal LUCAS                                                             *
REM * Le 08/01/2015                                                            *
REM *                                                                          *
REM * %1 : environnement demandé (CLI, DEV, PREC, SUIV, SPE)                   *
REM * %2 : programme à lancer                                                  *
REM * %3 : paramètres éventuels du programme  à lancer                         *
REM * %4 : REPGI                                                               *
REM * %5 : Disque                                                              *
REM ****************************************************************************

rem Variables de developpement
call dfvarenv.bat

echo.
echo     ----------------------------- Lancement.bat : Parametres en entree --------------------------------------
echo     %%1 (Environnement demande) = %1
echo     %%2 (Programme a lancer)... = %2
echo     %%3 (parametres)........... = %3
echo     %%4 (RepGI)................ = %4
echo     %%5 (Disque)............... = %5

rem Positionnement sur le bon environnement
call %SER_OUTILS%\progress\Menudev2\Ressources\Scripts\session\environnement.bat %1 %3 %4 %5

rem trace de controle
echo     ----------------------------------- Lancement du programme ----------------------------------------------
echo     Programme  : %2
echo     Parametres : %3
echo     Ligne de commande : %2 %3

rem Lancement du programme
call %2 %3

rem fin du script
rem if "%1"=="DEV" goto SORTIE
call pause 15 "Sortie dans 15 secondes..."
:SORTIE
exit