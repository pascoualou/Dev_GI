@echo off
echo Replication sur neptune en cours ...
xcopy /e/s *.* \\neptune2\nfsdosh\dev\outils\progress\Menudev2\Ressources\Majs
xcopy /e/s h:\dev\outils\progress\Menudev2\includes\*.* \\neptune2\nfsdosh\dev\outils\progress\Menudev2\includes
xcopy /e/s h:\dev\outils\progress\Menudev2\ressources\*.* \\neptune2\nfsdosh\dev\outils\progress\Menudev2\ressources
xcopy /e/s h:\dev\outils\progress\Menudev2\sources\*.* \\neptune2\nfsdosh\dev\outils\progress\Menudev2\sources

echo Replication sur neptune terminée ...
pause
exit
