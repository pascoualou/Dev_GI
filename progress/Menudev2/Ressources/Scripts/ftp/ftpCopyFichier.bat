echo off
rem Script de copie du fichier des versions sur barbade ou neptune2
rem %1 = nom du serveur

rem On ne passe plus par ftp car trop long sur certaines machines

call dfvarenv.bat

rem recutcon.p modifié sur barbade et neptune2 pour mettre les fichiers de la TC à dispo sur 
rem dev/intf/tc
copy %2 \\%1\nfsdosh\dev\intf\TC\DemandesDistantes

exit



