@ECHO OFF
call dfvarenv.bat
REM *************************** Debut de votre script. NE PAS MODIFIER AVANT *************************
REM Attention : toute commande, si elle n'est pas pr�c�d�e de "start" mettra en pause le menudev2 jusqu'� la fin du script
REM Exemple : "calc.exe" lancera la calculatrice et attendra que celle-ci soit ferm�e pour rendre la main � menudev2.
REM           Au contraire, "start calc.exe" lancera la calculatrice et rendre la main immediatement.


rem Suppression des �ventuels anciens fichiers d'information
set REPERTOIRE_BASE=%1\%2

if exist %REPERTOIRE_BASE%\_version.txt del %REPERTOIRE_BASE%\_version.txt
if exist %REPERTOIRE_BASE%\_commentaire.txt del %REPERTOIRE_BASE%\_commentaire.txt
if exist %REPERTOIRE_BASE%\_date.txt del %REPERTOIRE_BASE%\_date.txt
if exist %REPERTOIRE_BASE%\_repertoire.txt del %REPERTOIRE_BASE%\_repertoire.txt
if exist %REPERTOIRE_BASE%\_progress.txt del %REPERTOIRE_BASE%\_progress.txt

REM *************************** PAS de commande EXIT dans le batch  *************************
REM *************************** Fin de votre script. NE PAS MODIFIER APRES *************************
