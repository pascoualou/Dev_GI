@echo off
rem Lancement de Norminette en mode édition sous app builder
call dfvarenv.bat

set CONNEXION=

rem Cas particulier Portable développement Pascal
if not "%COMPUTERNAME%"=="PORTABLE-PL" goto SUITE_NORMALE
set DEVUSR=PPL
set CONNEXION=

:SUITE_NORMALE
echo DLC=%DLC%
echo DEVUSR=%DEVUSR%
echo PROWIN=%PROWIN%
start "" /B /WAIT %DLC%\bin\%PROWIN% -zn %CONNEXION% -p _ab.p  -param "h:\dev\outils\progress\Norminette\sources.dev\Norminette.w"  -ininame "h:\dev\outils\progress\developpementGI.ini" -debugalert

rem Menage avec un pause pour laisser à progress le temps de se fermer
call Menage_Progress.bat h:\dev\outils\progress\Norminette\sources.dev

exit

