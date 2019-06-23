@echo off
rem Récupération de la taille restante d'un disque
rem %1 contient le chemin
REM Chargement environnement standard
call dfvarenv.bat
dir %1 > %LOC_TMP%\DonneTD.tmp 
grep "octets libres" %LOC_TMP%\DonneTD.tmp > %1\_Dispo.mdev2
