echo off

call dfvarenv.bat

%dlc%\bin\%PROWIN% -zn -p %reseau%dev\outils\crc2.p -ininame %windir%\outilsgi%suffixe%.ini -T %disque%tmp -param %1

exit