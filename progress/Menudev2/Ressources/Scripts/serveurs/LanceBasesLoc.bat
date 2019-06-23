echo off

echo Ouverture de sadb
_mprosrv E:\bases\03073\sadb.db -L 25000 -n 50 -B 600 -Ma 7 -Mn 7 -Mi 2 %4
echo Ouverture de compta
_mprosrv E:\bases\03073\compta.db -L 25000 -n 50 -B 600 -Ma 7 -Mn 7 -Mi 2 %4
echo Ouverture de inter
_mprosrv E:\bases\03073\inter.db -L 25000 -n 50 -B 600 -Ma 7 -Mn 7 -Mi 2 %4
echo Ouverture de cadb
_mprosrv E:\bases\03073\cadb.db -L 25000 -n 50 -B 600 -Ma 7 -Mn 7 -Mi 2 %4
echo Ouverture de transfer
_mprosrv E:\bases\03073\transfer.db -L 25000 -n 50 -B 600 -Ma 7 -Mn 7 -Mi 2 %4

echo Ouverture de ladb
_mprosrv d:\integration\gi\baselib\ladb.db -L 25000 -n 50 -B 600 -Ma 7 -Mn 7 -Mi 2 %4
echo Ouverture de lcompta
_mprosrv d:\integration\gi\baselib\lcompta.db -L 25000 -n 50 -B 600 -Ma 7 -Mn 7 -Mi 2 %4
echo Ouverture de ltrans
_mprosrv d:\integration\gi\baselib\ltrans.db -L 25000 -n 50 -B 600 -Ma 7 -Mn 7 -Mi 2 %4
echo Ouverture de wadb
_mprosrv d:\integration\gi\baselib\wadb.db -L 25000 -n 50 -B 600 -Ma 7 -Mn 7 -Mi 2 %4

pause