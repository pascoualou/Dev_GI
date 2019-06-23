rem echo off

rem call dfvarenv.bat

set VERBOSE=/MIN
if "%VOIR_COMMANDES_DOS%"=="oui" set VERBOSE=

call %disque%tmp\commande.bat

:FIN
exit