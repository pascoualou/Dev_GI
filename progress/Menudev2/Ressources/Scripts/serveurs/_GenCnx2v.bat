@echo off

rem ATTENTION : on travaille en APPEND sur le fichier cnx

rem Paramètres
rem 1 = Répertoire de stockage des bases client
rem 2 = Référence
rem 3 = Répertoire des bases libellé en fonction de la version de l'appli et de la version Progress
rem 4 = TOUT ou QUE_LIB

if "%4" == "TOUT" (
	echo -db %1\%2\sadb >> c:\pfgi\cnx%2.pf
	echo -db %1\%2\cadb >> c:\pfgi\cnx%2.pf
	echo -db %1\%2\compta >> c:\pfgi\cnx%2.pf
	echo -db %1\%2\inter >> c:\pfgi\cnx%2.pf
	echo -db %1\%2\transfer >> c:\pfgi\cnx%2.pf
	echo #-db %1\%2\dwh >> c:\pfgi\cnx%2.pf
	echo. >> c:\pfgi\cnx%2.pf
)
echo -db %3\baselib\lcompta >> c:\pfgi\cnx%2.pf
echo -db %3\baselib\ltrans >> c:\pfgi\cnx%2.pf
echo -db %3\baselib\ladb >> c:\pfgi\cnx%2.pf
echo -db %3\baselib\wadb >> c:\pfgi\cnx%2.pf
echo. >> c:\pfgi\cnx%2.pf
echo -h 12 >> c:\pfgi\cnx%2.pf
exit
