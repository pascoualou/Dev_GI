@echo off

echo 1 = %1
echo 2 = %2
echo 3 = %3

set DISQUE_RACINE=%DISQUE%%repgi%\
if "%3"=="PREC" set DISQUE_RACINE=%DISQUE%gi_%3\gi
if "%3"=="SUIV" set DISQUE_RACINE=%DISQUE%gi_%3\gi
if "%3"=="CLI" set DISQUE_RACINE=%DISQUE%gi
if "%3"=="DEV" set DISQUE_RACINE=%DISQUE%gidev

echo DISQUE_RACINE = %DISQUE_RACINE%

echo -db %DISQUE_RACINE%\baselib\lcompta >> c:\pfgi\cnx%2.pf
echo -db %DISQUE_RACINE%\baselib\ltrans >> c:\pfgi\cnx%2.pf
echo -db %DISQUE_RACINE%\baselib\ladb >> c:\pfgi\cnx%2.pf
echo -db %DISQUE_RACINE%\baselib\wadb >> c:\pfgi\cnx%2.pf

echo. >> c:\pfgi\cnx%2.pf

echo -h 12 >> c:\pfgi\cnx%2.pf

exit
