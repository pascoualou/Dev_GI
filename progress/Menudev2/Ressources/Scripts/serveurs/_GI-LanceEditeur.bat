echo off

call dfvarenv.bat
start "" %dlc%\bin\%PROWIN% -zn -pf %1 -ininame %windir%\outilsgi%suffixe%.ini -T %disque%tmp
rem start "" %dlc%\bin\%PROWIN% -zn -pf %1 -ininame %windir%\outilsgi.ini -T %disque%tmp
rem Pause si demandée
%2
exit