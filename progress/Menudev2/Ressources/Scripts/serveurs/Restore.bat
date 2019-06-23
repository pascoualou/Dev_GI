@echo off
REM Chargement environnement standard
call dfvarenv.bat

REM Lancement du batch pre restauration
echo Lancement du batch Pre restauration standard
call "%SER_OUTILS%\progress\Menudev2\Ressources\scripts\General\PreResto.bat" %1 %2
if not exist "%SER_OUTILS%\progress\Menudev2\Ressources\Utilisateurs\%DEVUSR%\%DEVUSR%-PreResto-%2.bat" goto SUITE1
echo Lancement du batch Pre restauration utilisateur
call "%SER_OUTILS%\progress\Menudev2\Ressources\Utilisateurs\%DEVUSR%\%DEVUSR%-PreResto-%2.bat"

:SUITE1
echo Decompression dans le répertoire %1\%2
%LOC_APPLI%\exe\7-zip\7z.exe e -y -o%1\%2 %1\%2\svg\%2.7z 

echo repair de %1\%2
repair %1\%2

REM Lancement du batch post restauration
echo Lancement du batch post restauration standard
call "%SER_OUTILS%\progress\Menudev2\Ressources\scripts\General\PostResto.bat" %1 %2
if not exist "%SER_OUTILS%\progress\Menudev2\Ressources\Utilisateurs\%DEVUSR%\%DEVUSR%-PostResto-%2.bat" goto SUITE2
echo Lancement du batch post restauration utilisateur
call "%SER_OUTILS%\progress\Menudev2\Ressources\Utilisateurs\%DEVUSR%\%DEVUSR%-PostResto-%2.bat"

:SUITE2
echo avertissement du demandeur
call %SER_OUTILS%\ActionMenudev2.bat ORDREONGLET#BASES-INFOS#%DEVUSR%#Menudev2#0#"Restauration de la base %2 terminee"

%3

exit