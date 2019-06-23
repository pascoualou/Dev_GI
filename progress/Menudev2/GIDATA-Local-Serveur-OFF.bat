@echo off
call Action_Version_Progress.bat BASE_MENUDEV
call proshut %BASE_MENUDEV% -by
call pause 10 "Fermeture de cet ecran dans 10 secondes"