@ECHO OFF
call dfvarenv.bat
REM *************************** Debut de votre script. NE PAS MODIFIER AVANT *************************
REM Attention : toute commande, si elle n'est pas pr�c�d�e de "start" mettra en pause le menudev2 jusqu'� la fin du script
REM Exemple : "calc.exe" lancera la calculatrice et attendra que celle-ci soit ferm�e pour rendre la main � menudev2.
REM           Au contraire, "start calc.exe" lancera la calculatrice et rendre la main immediatement.

rem start %DLC%\bin\%prowin% -p %reseau%dev\outils\PPL-Automate.p -ininame %windir%\outilsgi.ini
start %DLC%\bin\%prowin% -p %reseau%dev\outils\progress\MailAuto\MailAuto.p -ininame %windir%\outilsgi.ini -T %disque%tmp
rem start %DLC%\bin\%prowin% -p %reseau%dev\outils\progress\TicketAuto\TicketAuto.p -ininame %windir%\outilsgi.ini -T %disque%tmp


REM *************************** Fin de votre script. NE PAS MODIFIER APRES *************************
exit