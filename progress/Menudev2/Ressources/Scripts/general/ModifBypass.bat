@echo off

call dfvarenv.bat


echo Entree dans 'ModifByPass.bat' avec param1=%1, param2=%2, param3=%3, param4=%4

notepad.exe %1

:SORTIE
call %SER_OUTILS%\ActionMenudev2.bat ORDREONGLET#BYPASS-RECHARGE#%DEVUSR%#Menudev2#0#

exit
