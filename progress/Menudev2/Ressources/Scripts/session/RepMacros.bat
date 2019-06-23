@echo off
REM ****************************************************************************
REM * Module de création des répertoires de travail et de copie des fichiers   *
REM * nécessaires au fonctionnement de l'environnement en cours                *
REM * Pascal LUCAS                                                             *
REM * Le 02/08/2015                                                            *
REM *                                                                          *
REM ****************************************************************************

echo.
echo Creation des rerpertoires de travail
echo.

mkdir %disque%tmp
mkdir %disque%gi\adb\tmp
mkdir %disque%gi\adb\word\docum
mkdir %disque%gi\adb\word\fichiers
mkdir %disque%gi\trans\archive
mkdir %disque%gi\trans\tmp
mkdir %disque%gi\trans\svg
mkdir %disque%gi\trans\svg\supp
mkdir %disque%gi\trans\unit99
mkdir %disque%gi\trans\unit99\sauve
mkdir %disque%gi\cadb\tmp
mkdir %disque%gi\gest\tmp

echo.
echo Copie des macros Word et Excel
echo.
rem h:\ en dur : volontairement pour prendre l'environnement du serveur
rem reseau ne vaut pas forcement h:\ ici
copy h:\gi\adb\word\model\gi\*.* %disque%gi\adb\word\model\gi
copy h:\gi\adb\word\model\client\*.* %disque%gi\adb\word\model\client
copy h:\gi\adb\word\macro\*.* %disque%gi\adb\word\macro

h:
cd h:\gi\adb\excel
for /d %%r in (*) do mkdir %disque%gi\adb\excel\%%r
for /d %%r in (*) do mkdir %disque%gi\adb\excel\%%r\macro
for /d %%r in (*) do mkdir %disque%gi\adb\excel\%%r\doc
for /d %%r in (*) do copy h:\gi\adb\excel\%%r\macro\*.xls %disque%gi\adb\excel\%%r\macro

rem fin du script
pause
exit