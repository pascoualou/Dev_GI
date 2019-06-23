rem echo off

call dfvarenv.bat

set VERBOSE=/MIN
if "%VOIR_COMMANDES_DOS%"=="oui" set VERBOSE=

start %VERBOSE% %SER_OUTILS%\progress\Menudev2\Ressources\Scripts\general\CopieSvg.bat %1 %2 %3 %4 %5 %6 %7

exit