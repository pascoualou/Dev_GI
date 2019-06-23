@echo off
rem dir /B/S %1\*.doc > %2listeD.txt
rem dir /B/S %1\*.docx >> %2listeD.txt  !!!! visiblement la recherche des .doc retourne aussi les .docx
rem dir /B/S %1\*.xls >> %2listeD.txt
rem dir /B/S %1\*.pdf >> %2listeD.txt
rem dir /B/S %1\*.7z >> %2listeD.txt
rem dir /B/S %1\*.zip >> %2listeD.txt
rem dir /B/S %1\*.jpg >> %2listeD.txt
rem dir /B/S %1\*.jpeg >> %2listeD.txt
rem dir /B/S %1\*.txt >> %2listeD.txt

dir /B/S %1\*.* > %2listeD.txt
exit