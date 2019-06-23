@echo off
set LIBOK=Fermeture forcee des serveurs sur la base libelle %2
set LIBERREUR=Erreur lors de la fermeture forcee des serveurs sur la base libelle %2

echo fermeture de ladb
call proshut %1\ladb.db -by
set erreur=%errorlevel%
if not %erreur%==0 goto FIN

echo fermeture de lcompta
call proshut %1\lcompta.db -by
set erreur=%errorlevel%
if not %erreur%==0 goto FIN

echo fermeture de wadb
call proshut %1\wadb.db -by
set erreur=%errorlevel%
if not %erreur%==0 goto FIN

echo fermeture de ltrans
call proshut %1\ltrans.db -by
set erreur=%errorlevel%
if not %erreur%==0 goto FIN

:FIN
echo avertissement du demandeur
if "%4"=="MUET" goto SORTIE 
call %SER_OUTILS%\progress\Menudev2\Ressources\Scripts\serveurs\finscript.bat FERME %erreur%

:SORTIE
REM Pause si demandée
%3
exit