@echo off
REM Chargement environnement standard
call dfvarenv.bat

echo Fermeture de la base...
call proshut %1\%2\sadb.db -by
call proshut %1\%2\compta.db -by
call proshut %1\%2\inter.db -by
call proshut %1\%2\cadb.db -by
call proshut %1\%2\transfer.db -by
call proshut %1\%2\dwh.db -by

REM Lancement du batch pre restauration
echo Lancement du batch Pre Sauvegarde
if not exist "%SER_OUTILS%\progress\Menudev2\Ressources\Utilisateurs\%DEVUSR%\%DEVUSR%-PreSvg-%2.bat" goto SUITE1
call "%SER_OUTILS%\progress\Menudev2\Ressources\Utilisateurs\%DEVUSR%\%DEVUSR%-PreSvg-%2.bat"

:SUITE1
echo Compression dans le répertoire %1\%2\svg
mkdir %1\%2\svg
%LOC_APPLI%\exe\7-zip\7z.exe a %4 %LOC_TMP%\%2.7z %1\%2\*.*
move %LOC_TMP%\%2.7z %1\%2\svg

echo Lancement du batch Post Sauvegarde
if not exist "%SER_OUTILS%\progress\Menudev2\Ressources\Utilisateurs\%DEVUSR%\%DEVUSR%-PostSvg-%2.bat" goto SUITE2
call "%SER_OUTILS%\progress\Menudev2\Ressources\Utilisateurs\%DEVUSR%\%DEVUSR%-PostSvg-%2.bat"

:SUITE2
echo avertissement du demandeur
call %SER_OUTILS%\ActionMenudev2.bat ORDREONGLET#BASES-Infos#%DEVUSR%#Menudev2#0#"Sauvegarde de la base %2 terminee"

%3

exit