rem echo off

call dfvarenv.bat

if "%3"=="pause" goto AVECPAUSE

set VERBOSE=/MIN
if "%VOIR_COMMANDES_DOS%"=="oui" set VERBOSE=

start %VERBOSE% %SER_OUTILS%\progress\Menudev2\Ressources\Scripts\serveurs\LanceServeurs.bat %1 %2 %3 %4
goto FIN

:AVECPAUSE
start %SER_OUTILS%\progress\Menudev2\Ressources\Scripts\serveurs\LanceServeurs.bat %1 %2 %3 %4

:FIN
exit