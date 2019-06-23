@echo off
call dfvarenv.bat
rem pause
set VERBOSE=/MIN
if "%VOIR_COMMANDES_DOS%"=="oui" set VERBOSE=

start %VERBOSE% %SER_OUTILS%\progress\Menudev2\Ressources\Scripts\serveurs\MontageVersion.bat %1 %2 %3

:FIN
exit