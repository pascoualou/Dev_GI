echo off
rem Script de copie du fichier des versions sur barbade ou neptune2
rem %1 = adresse ou nom du serveur

call dfvarenv.bat

call %LOC_OUTILS%\psenvdev.bat
cd %LOC_TMP%

if "%1"=="barbade" goto BARBADE

:NEPTUNE
rem ouverture de la connexion ftp
rem call ftp -s:%SER_OUTILS%\progress\versions\ressources\scripts\ftpCopyVersionsNeptune.ftp
copy versions.lst \\neptune\nfsdosh\dev\intf
goto FIN

:BARBADE
rem ouverture de la connexion ftp
remcall ftp -s:%SER_OUTILS%\progress\versions\ressources\scripts\ftpCopyVersionsBarbade.ftp
copy versions.lst \\barbade\nfsdosh\dev\intf
goto FIN

:FIN
exit


