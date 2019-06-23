@echo off

rem Paramètres :
rem     1 - Fichier log pour la trace
rem     2 - Répertoire de stockage des bases
rem     3 - programme de controle des bases
rem     4 - Log activé

call dfvarenv.bat

rem Horodatage
for /f %%d in ('date /t') do set horodatage=%%d
for /f %%d in ('time /t') do set horodatage=%horodatage% - %%d:00
set horodatage=%horodatage% - VerifiePartage.bat
rem Lancement du programme d analyse/controle du repertoire des bases
if "%4"=="OUI" echo %horodatage% - Lancement du programme d analyse/controle du repertoire des bases >> %1 
if "%4"=="OUI" echo %horodatage% - Repertoire des bases : %2 >> %1 
start %dlc%\bin\%PROWIN% -p %3 -ininame %windir%\outilsgi.ini -cpstream iso8859-1 -T %disque%tmp


SUITE:
rem On sort

FIN:
rem Sortie du batch
exit