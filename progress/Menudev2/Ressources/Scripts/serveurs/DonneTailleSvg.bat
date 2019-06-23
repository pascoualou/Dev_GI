@echo off
rem Récupération de la taille décompressée de l'archive de la base
rem %1 contient le chemin de la base
rem %2 contient le nom de la base
rem l'archive se nomme donc obligatoirement %1\%2\svg\%2.7z
REM Chargement environnement standard
call dfvarenv.bat
echo %1\svg\%2.7z > %LOC_TMP%\DonneTS.tmp 
%LOC_APPLI%\exe\7-zip\7z.exe l %1\%2\svg\%2.7z >> %LOC_TMP%\DonneTS.tmp 
grep "files" %LOC_TMP%\DonneTS.tmp > %1\%2\_Taille.tmpmdev2