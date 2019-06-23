@echo off
call dfvarenv.bat

rem Gestion de la connexion à la base gidata 
set CONNEXION="h:\Dev\outils\progress\Menudev2\Connexion.pf"

rem Cas particulier Eeeepc Pascal
if not "%COMPUTERNAME%"=="PORTABLE-PL" goto SUITE_NORMALE
set CONNEXION="h:\Dev\outils\progress\Menudev2\Connexion-Local.pf"

:SUITE_NORMALE

rem Gestion de la version de Progress 
if "%DLC%"=="%DLC_V11%" set DEVUSR=%DEVUSR_V11%

:LANCEMENT
echo DLC=%DLC%
echo DEVUSR=%DEVUSR%
start %DLC%\bin\%PROWIN% -zn -mmax 4000 -pf %CONNEXION% -p "h:\dev\outils\Progress\Menudev2\sources\menudev2.w" -ininame h:\dev\outils\Progress\developpementGI.ini -T %disque%tmp -h 20
rem pause
exit