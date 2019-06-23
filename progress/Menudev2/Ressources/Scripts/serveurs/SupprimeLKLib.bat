echo off

echo Suppression des fichiers .LK sur les bases libelle
del /Q %1\*.lk 

echo avertissement du demandeur
call %SER_OUTILS%\ActionMenudev2.bat ORDREONGLET#BASES-INFOS#%DEVUSR%#Menudev2#0#"Suppression des .lk sur la base libelle %2 terminee"

REM Pause si demandée
%3

exit