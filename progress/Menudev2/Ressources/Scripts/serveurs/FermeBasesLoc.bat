echo off
echo Fermeture de sadb
call proshut E:\bases\03073\sadb.db -by
echo Fermeture de compta
call proshut E:\bases\03073\compta.db -by
echo Fermeture de inter
call proshut E:\bases\03073\inter.db -by
echo Fermeture de cadb
call proshut E:\bases\03073\cadb.db -by
echo Fermeture de transfer
call proshut E:\bases\03073\transfer.db -by


echo Fermeture de ladb
call proshut d:\integration\gi\baselib\ladb.db -by
echo Fermeture de lcompta
call proshut d:\integration\gi\baselib\lcompta.db  -by
echo Fermeture de ltrans
call proshut d:\integration\gi\baselib\ltrans.db -by
echo Fermeture de wadb
call proshut d:\integration\gi\baselib\wadb.db -by

pause