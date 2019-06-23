@echo off
call Action_Version_Progress.bat BASE_MENUDEV
call proserve %BASE_MENUDEV%
call pause 10 "Fermeture de cet ecran dans 10 secondes"