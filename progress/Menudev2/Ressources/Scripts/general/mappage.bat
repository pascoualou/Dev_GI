@echo off

call dfvarenv.bat
if "%DEVUSR%"=="PJPM" goto FIN
if "%DEVUSR%"=="PJPM_V11" goto FIN

call %reseau%DefinitionServeur.bat

if not "%SERVEUR%"=="barbade" goto SUITE
rem mappage du répertoire personnel
net use p: \\barbade\%USERNAME% /persistent:YES

:SUITE

rem mappage du répertoire des bases
net use x: \\xcompil\Bases /persistent:YES

rem mappage du répertoire des anciennes bases
net use y: \\scompilv11\Backup-xcompil\Anciennes_Sauvegardes /persistent:YES

rem pour les VM
if "%DEVUSR%" == "devgg" goto MAPPAGE
if not "%DEVUSR:~0,2%" == "VM" goto FIN

:MAPPAGE
net use w: \\sdevweb\gidev /persistent:YES

:FIN
