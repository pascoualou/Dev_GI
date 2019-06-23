@echo off
set LIBOK=Fermeture forcee des serveurs sur la base %2
set LIBERREUR=Erreur lors de la fermeture forcee des serveurs sur la base %2

echo fermeture de sadb
if exist %1\%2\sadb.db call proshut %1\%2\sadb.db -by
set erreur=%errorlevel%
if not %erreur%==0 goto FIN

echo fermeture de compta
if exist %1\%2\compta.db call proshut %1\%2\compta.db -by
set erreur=%errorlevel%
if not %erreur%==0 goto FIN

echo fermeture de inter
if exist %1\%2\inter.db call proshut %1\%2\inter.db -by
set erreur=%errorlevel%
if not %erreur%==0 goto FIN

echo fermeture de cadb
if exist %1\%2\cadb.db call proshut %1\%2\cadb.db -by
set erreur=%errorlevel%
if not %erreur%==0 goto FIN

echo fermeture de transfer
if exist %1\%2\transfer.db call proshut %1\%2\transfer.db -by 
set erreur=%errorlevel%
if not %erreur%==0 goto FIN

echo fermeture de dwh
if exist %1\%2\dwh.db call proshut %1\%2\dwh.db -by
set erreur=%errorlevel%
if not %erreur%==0 goto FIN

:FIN
if %erreur%==0 del %1\%2\_No-Integrity.mdev2
echo avertissement du demandeur
call %SER_OUTILS%\progress\Menudev2\Ressources\Scripts\serveurs\finscript.bat FERME %erreur%

:SORTIE
REM Pause si demandée
%3
exit