@echo off
C:
cd \dlc\wrkOE117
copy /Y .\magiController\openedge\oerealm\token.r     .\magimodele\openedge\oerealm\token.r
copy /Y .\magiController\openedge\outils\collection.r .\magimodele\openedge\outils\collection.r
copy /Y .\magiController\openedge\outils\logHandler.r .\magimodele\openedge\outils\logHandler.r
copy /Y c:\magi\workspace\magiController\src\AppServer\oerealm\spadefault.cp .\magiController\common\lib\spadefault.cp
copy /Y c:\magi\workspace\magiController\src\AppServer\spaService.properties .\magiController\openedge\spaService.properties
REM On ne teste que l'existence du fichier !!!
copy /Y c:\magi\workspace\magiController\src\AppServer\spaService.properties .\magiController\openedge\passe.exe
echo duplicate rcode deployed
pause
rem START CMD /C "ECHO duplicate rcode deployed && PAUSE"
