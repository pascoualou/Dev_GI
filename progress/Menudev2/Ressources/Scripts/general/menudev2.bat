@ECHO OFF
REM *************************** Debut du script menudev2.bat. NE PAS MODIFIER AVANT ****************
REM Attention : toute commande, si elle n'est pas pr�c�d�e de "start" mettra en pause le menudev2 jusqu'� la fin du script
REM Exemple : "calc.exe" lancera la calculatrice et attendra que celle-ci soit ferm�e pour rendre la main � menudev2.
REM           Au contraire, "start calc.exe" lancera la calculatrice et rendre la main immediatement.

mkdir %DISQUE%dev\outils
mkdir %DISQUE%dev\tmp
copy %1Ressources\Scripts\general\tooltip.bat %DISQUE%dev\outils
copy %1Ressources\Scripts\general\tooltip.exe %DISQUE%dev\outils

REM *************************** Fin du script. NE PAS MODIFIER APRES *************************
exit