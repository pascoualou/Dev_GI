@echo off
set LIBOK=Fermeture des serveurs sur la base %2
set LIBERREUR=Erreur lors de la fermeture des serveurs sur la base %2

echo fermeture de compta
if exist %1\%2\compta.db call proshut %1\%2\compta.db -bn
set erreur=%errorlevel%
if not %erreur%==0 goto FIN

echo fermeture de inter
if exist %1\%2\inter.db call proshut %1\%2\inter.db -bn
set erreur=%errorlevel%
if not %erreur%==0 goto FIN

echo fermeture de transfer
if exist %1\%2\transfer.db call proshut %1\%2\transfer.db -bn 
set erreur=%errorlevel%
if not %erreur%==0 goto FIN

echo fermeture de sadb
if exist %1\%2\sadb.db call proshut %1\%2\sadb.db -bn
set erreur=%errorlevel%
if not %erreur%==0 goto FIN

echo fermeture de cadb
if exist %1\%2\cadb.db call proshut %1\%2\cadb.db -bn
set erreur=%errorlevel%
if not %erreur%==0 goto FIN

echo fermeture de dwh
if exist %1\%2\dwh.db call proshut %1\%2\dwh.db -bn
set erreur=%errorlevel%
if not %erreur%==0 goto FIN

echo fermeture de ladb
if exist %1\%2\ladb.db call proshut %1\%2\ladb.db -bn
set erreur=%errorlevel%
if not %erreur%==0 goto FIN

echo fermeture de lcompta
if exist %1\%2\lcompta.db call proshut %1\%2\lcompta.db -bn
set erreur=%errorlevel%
if not %erreur%==0 goto FIN

echo fermeture de ltrans
if exist %1\%2\ltrans.db call proshut %1\%2\ltrans.db -bn
set erreur=%errorlevel%
if not %erreur%==0 goto FIN

echo fermeture de wadb
if exist %1\%2\wadb.db call proshut %1\%2\wadb.db -bn
set erreur=%errorlevel%
if not %erreur%==0 goto FIN

:FIN
if %erreur%==0 del %1\%2\_No-Integrity.mdev2
echo avertissement du demandeur
call %SER_OUTILS%\progress\Menudev2\Ressources\Scripts\serveurs\finscript.bat FERME %erreur%

:SORTIE
REM Pause si demandée
%3
if "%NO-EXIT%"=="" exit