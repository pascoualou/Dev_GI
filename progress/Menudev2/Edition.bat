@echo off
rem Lancement de menudev2 en mode édition sous app builder

call dfvarenv.bat

start afficheEnv.bat edition.bat

set CONNEXION="h:\Dev\outils\progress\Menudev2\Connexion.pf"

rem Cas particulier Portable développement Pascal
if not "%COMPUTERNAME%"=="PORTABLE-PL" goto SUITE_NORMALE
set DEVUSR=PPL
set CONNEXION="h:\Dev\outils\progress\Menudev2\Connexion-Local.pf"

:SUITE_NORMALE
echo DLC=%DLC%
echo DEVUSR=%DEVUSR%
echo PROWIN=%PROWIN%

start "" /B /WAIT %DLC%\bin\%PROWIN% -zn -mmax 4000 -pf %CONNEXION% -p _ab.p  -param "h:\dev\outils\progress\Menudev2\sources.dev\menudev2.w"  -ininame "h:\dev\outils\progress\developpementGI.ini"

rem Menage avec un pause pour laisser à progress le temps de se fermer
call Menage_Progress.bat h:\dev\outils\progress\Menudev2\sources.dev

exit

