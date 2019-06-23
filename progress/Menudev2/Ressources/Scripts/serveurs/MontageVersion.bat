@echo off
call dfvarenv.bat

echo Montage d une version
echo.

rem set PROPATH=%PROPATH%,%DLC%\src

echo PROWIN = %PROWIN%
echo PROPATH = %PROPATH%
echo DISQUE = %DISQUE%
echo RESEAU = %RESEAU%
echo 1 = %1
echo 2 = %2
echo 3 = %3

rem pause

rem %dlc%\BIN\%PROWIN% -pf c:\pfgi\cnxmd2_montage.pf -p %reseau%gi\maj\routines\exe\maj.r -T %disque%dev\tmp -h 11 -param %3
rem %dlc%\BIN\%PROWIN% -pf c:\pfgi\cnxmd2_montage.pf -p %reseau%gi\maj\routines\src\maj.p -T %disque%dev\tmp -h 11 -param %3
%dlc%\BIN\%PROWIN% -p %reseau%gi\maj\routines\src\compile_maj.p -T %disque%dev\tmp -param %reseau%gi\maj\routines\src\maj.p
%dlc%\BIN\%PROWIN% -pf c:\pfgi\cnxmd2_montage.pf -p %disque%dev\tmp\maj.r -T %disque%dev\tmp -h 11 -param %3

echo avertissement du demandeur
set NO-EXIT=TRUE
call %SER_OUTILS%\ActionMenudev2.bat ORDREONGLET#BASES-INFOSSANSMAJ#%DEVUSR%#Menudev2#0#"Fermeture de la base %2 pour prise en compte des modifications"

echo Fermeture de la base pour prise en compte des modifications
call %SER_OUTILS%\progress\Menudev2\Ressources\Scripts\serveurs\FermeServeurs.bat %1 %2

echo Calcul du CRC
call %SER_OUTILS%\ActionMenudev2.bat ORDREONGLET#BASES-INFOSSANSMAJ#%DEVUSR%#Menudev2#1#"Calcul du CRC de la base %2"
%dlc%\bin\%PROWIN% -p %reseau%dev\outils\crc2.p -ininame %windir%\outilsgi.ini -T %disque%tmp -param %1\%2

echo Avertissement utilisateur...
call %SER_OUTILS%\ActionMenudev2.bat ORDREONGLET#BASES-infos#%DEVUSR%#Menudev2#2#"Montage de la version sur la base %2 termine"

:FIN
exit