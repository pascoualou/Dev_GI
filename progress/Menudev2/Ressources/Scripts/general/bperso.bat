@echo off
set Attente=NON
if not !%1!==!ATTENTE! goto SUITE
set Attente=OUI
shift

:SUITE
REM Le code situ� avant cette ligne ne doit pas �tre modifi�
REM ----------------- Debut du corps du batch --------------------
REM ------------- Vous pouvez saisir ici votre code --------------






REM ----------------- fin du corps du batch --------------------
REM Le code situ� apr�s cette ligne ne doit pas �tre modifi�
if %Attente%==NON goto FIN
pause

:FIN
exit

