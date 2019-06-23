@echo off
set LIBOK=Ouverture des serveurs sur la base %2
set LIBERREUR=Erreur lors de l ouverture des serveurs sur la base %2

REM Recuperation des parametres des serveurs
call %LOC_OUTILS%\ParamServeurs.bat

echo Ouverture de sadb
if exist %1\%2\sadb.db _mprosrv %1\%2\sadb.db %PARAM_SADB% %4
set erreur=%errorlevel%
if not %erreur%==0 goto FIN

echo Ouverture de compta
if exist %1\%2\compta.db _mprosrv %1\%2\compta.db %PARAM_COMPTA% %4
set erreur=%errorlevel%
if not %erreur%==0 goto FIN

echo Ouverture de inter
if exist %1\%2\inter.db _mprosrv %1\%2\inter.db %PARAM_INTER% %4
set erreur=%errorlevel%
if not %erreur%==0 goto FIN

echo Ouverture de transfer
if exist %1\%2\transfer.db _mprosrv %1\%2\transfer.db %PARAM_TRANSFER% %4
set erreur=%errorlevel%
if not %erreur%==0 goto FIN

echo Ouverture de cadb
if exist %1\%2\cadb.db _mprosrv %1\%2\cadb.db %PARAM_CADB% %4
set erreur=%errorlevel%
if not %erreur%==0 goto FIN

echo Ouverture de dwh
if exist %1\%2\dwh.db _mprosrv %1\%2\dwh.db %PARAM_DWH% %4
set erreur=%errorlevel%
if not %erreur%==0 goto FIN

:FIN
echo avertissement du demandeur
call %SER_OUTILS%\progress\Menudev2\Ressources\Scripts\serveurs\finscript.bat OUVRE %erreur%

:SORTIE
REM Pause si demandée
%3
exit