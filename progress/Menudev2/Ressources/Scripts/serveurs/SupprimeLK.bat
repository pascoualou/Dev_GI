echo off

echo Suppression des fichiers .LK
del /Q %1\%2\*.lk 
set erreur=%errorlevel%
if %erreur%==0 del %1\%2\_No-Integrity.mdev2

echo avertissement du demandeur
call %SER_OUTILS%\ActionMenudev2.bat ORDREONGLET#BASES-INFOS#%DEVUSR%#Menudev2#0#"Suppression des .lk sur la base %2 terminee"

REM Pause si demandée
%3

exit