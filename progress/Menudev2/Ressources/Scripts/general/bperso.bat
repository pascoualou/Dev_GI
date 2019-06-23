@echo off
set Attente=NON
if not !%1!==!ATTENTE! goto SUITE
set Attente=OUI
shift

:SUITE
REM Le code situé avant cette ligne ne doit pas être modifié
REM ----------------- Debut du corps du batch --------------------
REM ------------- Vous pouvez saisir ici votre code --------------






REM ----------------- fin du corps du batch --------------------
REM Le code situé après cette ligne ne doit pas être modifié
if %Attente%==NON goto FIN
pause

:FIN
exit

