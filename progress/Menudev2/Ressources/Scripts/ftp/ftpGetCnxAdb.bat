echo off
rem Script de r√©cup√©ration du fichier CNX sur barbade ou neptune2
rem %1 = nom du serveur
rem %2 = reference

rem On ne passe plus par ftp car trop long sur certaines machines

call dfvarenv.bat

rem recutcon.p modifiÈ sur barbade et neptune2 pour mettre les fichiers de la TC ‡ dispo sur 
rem dev/intf/tc
copy \\%1\nfsdosh\dev\intf\TC\cnx%2.pf %LOC_TMP%
copy \\%1\nfsdosh\dev\intf\TC\adb%2 %LOC_TMP%
copy \\%1\nfsdosh\dev\intf\TC\services.%2 %LOC_TMP%

exit

