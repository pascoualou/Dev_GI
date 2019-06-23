@echo off
call dfvarenv.bat
rem Lancement de MailAuto

%dlc%\bin\%PROWIN% -p %reseau%dev\outils\progress\MailAuto\MailAuto.p -ininame %windir%\outilsgi.ini -T %disque%tmp