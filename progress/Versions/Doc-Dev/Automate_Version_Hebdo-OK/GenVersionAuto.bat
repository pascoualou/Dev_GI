@ECHO OFF
REM Batch de génération auto des version hebdo 
REM PL : le 06/06/05 
REM CC : le 07/08/06 probleme sur blat
REM PL : le 13/11/08 Ajout institutions de prévoyance
REM PL : le 20/06/11 Mise à niveau et améliorations
call dfvarenv.bat

REM Titre
TITLE Version hebdomadaire

REM forcage de la variable disque
set disque-svg=%DISQUE%
set DISQUE=d:\

REM Si fichier top de compile présent : on fait le travail sinon on sort
if not exist H:\dev\intf\cV10_GI5.ok goto FIN_ANORMALE

REM Si bloquage de la version : on ne fait rien
if exist H:\dev\intf\BloqueVersionHebdo goto FIN_BLOQUAGE

REM Pour debug : déplacer la ligne ":SUITE"
goto SUITE
:SUITE

echo Création des fichiers de la version.
%dlc%\BIN\%PROWIN% -p %reseau%dev\outils\progress\versions\sources.dev\lance.p   -ininame "h:\dev\outils\progress\developpementGI.ini"  -T %disque%dev\tmp -param montage.w#HEBDO

REM Si abandon de la version : on ne fait rien
if exist H:\dev\intf\AbandonVersionHebdo goto FIN_ABANDON

echo Génération des bases libellé dos depuis unix.
%dlc%\bin\%PROWIN% -p %reseau%dev\outils\_dmpload.w -ininame %windir%\outilsgi.ini -param AUTO

echo Copie des bases libellé de GIDEV dans GI.
call %reseau%dev\outils\lgidevgi.bat

echo Génération des dumps des bases libellé.
call %reseau%gi\maj\delta\rectif\dmplocal.bat

echo Déchargement des Institutions de prévoyance.
call %reseau%dev\outils\majprv.bat gi

echo Déchargement des rubriques.
call %reseau%dev\outils\majrub.bat gi

echo Déchargement des Scénario.
call %reseau%dev\outils\majsce.bat gi

echo Création de la version.
call %reseau%dev\outils\CREVERS.BAT

:SUITE

echo Création Fichier compressé.
del /Q D:\version\gi_image\giadb.zip
del /Q D:\version\gi_image\giadb.exe
"C:\Program Files\WinZip\WINZIP32.EXE" -a -r  D:\version\gi_image\giadb.zip D:\version\gi_image

echo Création Autoextractible.
%reseau%dev/outils/gestautoex.exe D:\version\gi_image\giadb.zip

echo Déplacement Autoextractible.
move /Y D:\version\gi_image\giadb.exe D:\version

echo Avertissement.
echo La version hebdomadaire est disponible comme d'habitude sur la machine de compile. > %reseau%dev\outils\GenVersionAuto.txt
echo. >> %reseau%dev\outils\GenVersionAuto.txt
type D:\version\gi_image\gi\exe\version.maj >> %reseau%dev\outils\GenVersionAuto.txt
goto FIN

:FIN_ANORMALE
echo Version hebdomadaire NON GENEREE !!!!! : Problème de compile > %reseau%dev\outils\GenVersionAuto.txt
goto FIN

:FIN_BLOQUAGE
echo Version hebdomadaire NON GENEREE !!!!! : bloquage version hebdo > %reseau%dev\outils\GenVersionAuto.txt
goto FIN

:FIN_ABANDON
echo Version hebdomadaire NON GENEREE !!!!! : Fichier version non prêt ou problème lors de sa génération automatique (gestbase) > %reseau%dev\outils\GenVersionAuto.txt
goto FIN

:FIN
REM Ajout signature
echo. >> %reseau%dev\outils\GenVersionAuto.txt
echo Service Développement >> %reseau%dev\outils\GenVersionAuto.txt
echo. >> %reseau%dev\outils\GenVersionAuto.txt
type G:\service\gi\textprop-GI.txt >> %reseau%dev\outils\GenVersionAuto.txt

REM Remise en place de la variable disque
set DISQUE=%disque-svg%
if exist %disque%dev\bypass\VERSIONHEBDO_PasMail goto SORTIE
%reseau%\dev\outils\blat\blat.exe %reseau%dev\outils\GenVersionAuto.txt -subject "Version Hebdomadaire" -to "christine.boucher@la-gi.fr,dpt-test@la-gi.fr,c.cazamajor@la-gi.fr,jpmarotte@la-gi.fr,olivier.falcy@la-gi.fr,pascal.lucas@la-gi.fr,richard.farand@la-gi.fr,hotline-pme@la-gi.fr" -log d:\tmp\blat.lg -p %PROFILE_BLAT%
:SORTIE
exit

