echo off
rem Script de r√©cup√©ration du fichier liste des bases de la TC sur barbade ou neptune2
rem %1 = nom du serveur

rem On ne passe plus par ftp car trop long sur certaines machines

call dfvarenv.bat

rem recutcon.p modifiÈ sur barbade et neptune2 pour mettre les fichiers de la TC ‡ dispo sur 
REM dev/intf/tc
copy \\%1\nfsdosh\dev\intf\TC\tc.lst %LOC_TMP%



