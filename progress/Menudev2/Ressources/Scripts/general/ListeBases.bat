@echo off
call dfvarenv.bat
set FichierListe=%LOC_TMP%\bases.csv
echo Utilisateur;Repertoire;Version;Base;Sauvegarde;Commentaire;Date > %FichierListe%
for /R "%SER_OUTILS%\progress\Menudev2\Ressources\Utilisateurs" %%f in (*.bases) do type "%%f" >> %FichierListe%
start %FichierListe%
exit