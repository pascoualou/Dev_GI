echo off
set LIBOK=Ouverture des serveurs sur la base libelle %2
set LIBERREUR=Erreur lors de l ouverture des serveurs sur la base libelle %2

REM Recuperation des parametres des serveurs
call %LOC_OUTILS%\ParamServeurs.bat
rem start AfficheEnv.bat
echo Ouverture de ladb
_mprosrv %1\ladb.db %PARAM_LADB% %4
set erreur=%errorlevel%
if not %erreur%==0 goto FIN

echo Ouverture de lcompta
_mprosrv %1\lcompta.db %PARAM_LCOMPTA% %4 
set erreur=%errorlevel%
if not %erreur%==0 goto FIN

echo Ouverture de wadb
_mprosrv %1\wadb.db %PARAM_WADB% %4 
set erreur=%errorlevel%
if not %erreur%==0 goto FIN

echo Ouverture de ltrans
_mprosrv %1\ltrans.db %PARAM_LTRANS% %4 
set erreur=%errorlevel%
if not %erreur%==0 goto FIN

:FIN
echo avertissement du demandeur
call %SER_OUTILS%\progress\Menudev2\Ressources\Scripts\serveurs\finscript.bat OUVRE %erreur%

:SORTIE
REM Pause si demandée
%3
exit