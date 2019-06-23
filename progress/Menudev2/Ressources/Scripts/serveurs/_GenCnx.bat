@echo off
echo # Fichier de connexion généré par menudev2 > c:\pfgi\cnx%2.pf

set DEBUG=OUI

if "%DEBUG%"=="OUI" echo # %%1 = %1 >> c:\pfgi\cnx%2.pf
if "%DEBUG%"=="OUI" echo # %%2 = %2 >> c:\pfgi\cnx%2.pf
if "%DEBUG%"=="OUI" echo # %%3 = %3 >> c:\pfgi\cnx%2.pf

set DISQUE_RACINE=%DISQUE%%repgi%\
if "%3"=="SPE" set DISQUE_RACINE=%DISQUE%gi_%3\gi
if "%3"=="PREC" set DISQUE_RACINE=%DISQUE%gi_%3\gi
if "%3"=="SUIV" set DISQUE_RACINE=%DISQUE%gi_%3\gi
if "%3"=="CLI" set DISQUE_RACINE=%DISQUE%gi
if "%3"=="DEV" set DISQUE_RACINE=%DISQUE%gidev
if "%3"=="" set DISQUE_RACINE=%DISQUE%gidev

if "%DEBUG%"=="OUI" echo # DISQUE_RACINE = %DISQUE_RACINE% >> c:\pfgi\cnx%2.pf

echo. >> c:\pfgi\cnx%2.pf

echo -db %1\%2\sadb >> c:\pfgi\cnx%2.pf
echo -db %1\%2\cadb >> c:\pfgi\cnx%2.pf
echo -db %1\%2\compta >> c:\pfgi\cnx%2.pf
echo -db %1\%2\inter >> c:\pfgi\cnx%2.pf
echo -db %1\%2\transfer >> c:\pfgi\cnx%2.pf
echo #-db %1\%2\dwh >> c:\pfgi\cnx%2.pf

echo. >> c:\pfgi\cnx%2.pf


echo -db %DISQUE_RACINE%\baselib\lcompta >> c:\pfgi\cnx%2.pf
echo -db %DISQUE_RACINE%\baselib\ltrans >> c:\pfgi\cnx%2.pf
echo -db %DISQUE_RACINE%\baselib\ladb >> c:\pfgi\cnx%2.pf
echo -db %DISQUE_RACINE%\baselib\wadb >> c:\pfgi\cnx%2.pf

echo. >> c:\pfgi\cnx%2.pf

echo -h 12 >> c:\pfgi\cnx%2.pf

rem pour compatibilité avec les machine HL
rem copy c:\pfgi\cnx%2.pf %disque%%repgi%\pfgi\cnx%2.pf

exit
