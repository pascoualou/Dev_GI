@echo off

rem Paramètres :
rem     1 - Fichier log pour la trace
rem     2 - Répertoire de stockage des bases

call dfvarenv.bat

rem Horodatage
for /f %%d in ('date /t') do set horodatage=%%d
for /f %%d in ('time /t') do set horodatage=%horodatage% - %%d:00
set horodatage=%horodatage% - Menage.bat
rem Lancement du programme d analyse/controle du repertoire des bases
echo %horodatage% - Lancement du programme de suppression des fichiers .lk >> %1 
echo %horodatage% - Repertoire des bases : %2 >> %1 

rem suppression des .lk dans le répertoire des bases
del /s %2\*.lk

rem suppression des .lk dans les répertoires des versions
del %disque%gidev\baselib\*.lk
del %disque%gi\baselib\*.lk
del %disque%gi_prec\gi\baselib\*.lk
del %disque%gi_suiv\gi\baselib\*.lk
del %disque%gi_spe\gi\baselib\*.lk

exit