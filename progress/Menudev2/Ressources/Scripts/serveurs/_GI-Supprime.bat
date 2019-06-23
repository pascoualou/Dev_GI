@echo off
call dfvarenv.bat

mkdir %1\%2\svg

move %1\%2\_infos.mdev2 %LOC_TMP%
move %1\%2\_Commentaire.txt %LOC_TMP%
move %1\%2\_version.txt %LOC_TMP%
move %1\%2\_date.txt %LOC_TMP%
move %1\%2\_Progress.txt %LOC_TMP%
move %1\%2\_Repertoire.txt %LOC_TMP%
move %1\%2\_Taille.txt %LOC_TMP%

del /Q %1\%2\*.*

move %LOC_TMP%\_infos.mdev2 %1\%2
move %LOC_TMP%\_Commentaire.txt %1\%2
move %LOC_TMP%\_version.txt %1\%2
move %LOC_TMP%\_date.txt %1\%2
move %LOC_TMP%\_Progress.txt %1\%2
move %LOC_TMP%\_Repertoire.txt %1\%2
move %LOC_TMP%\_Taille.txt %1\%2

exit
