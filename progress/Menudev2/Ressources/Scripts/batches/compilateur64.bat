@echo off

echo Configuration de l'environnement de compilation...

set PROMSGS=%DLC%\prolang\fre\promsgs.fre
set PROBUILD=%DLC%\probuild
set PROPATH=%DLC%\PROBUILD\EUCAPP,%DLC%\PROBUILD\EUCAPP\EUC.PL,h:\dev\outils\progress,%DLC%

PATH=%PATH%;%DLC%\bin

rem Suppression des anciens executables
echo Suppression des anciens executables...
del %DISQUE%%REPGI%\*.r /s /Q

echo Récupération du fichier assemblies...
copy %RESEAU%%REPGI%\assemblies.xml %DISQUE%%REPGI%

echo Lancement de la compilation...
start %DLC%\bin\prowin.exe -p %RESEAU%dev\outils\compil11.w -h 15 -ininame C:\windows\outilsg2.ini -inp 8000 -T %DISQUE%tmp -s 100 -assemblies %DISQUE%%REPGI%

echo Fermeture de cette fenetre dans 10s...

ping localhost -n 10 > %TEMP%\null

exit