@echo off

set AUTOIT="D:\Applications\AutoIt3\Aut2Exe\Aut2exe.exe"
if "%COMPUTERNAME%" == "PORTABLE-PL" set AUTOIT="C:\Program Files (x86)\AutoIt3\Aut2Exe\Aut2exe_x64.exe"

echo Compilation de MasterGIToWindow.au3
%AUTOIT% /in MasterGIToWindow.au3 /out MasterGIToWindow.exe /icon H:\dev\outils\progress\Menudev2\Ressources\Images/smile.ico
copy "H:\dev\outils\progress\Menudev2\Ressources\Scripts\general\MasterGIToWindow.exe" d:\dev\outils 1>d:\dev\tmp\null

echo.
echo Compilation de tooltip.au3
%AUTOIT% /in tooltip.au3 /out tooltip.exe /icon H:\dev\outils\progress\Menudev2\Ressources\Images/smile.ico
copy "H:\dev\outils\progress\Menudev2\Ressources\Scripts\general\tooltip.exe" d:\dev\outils 1>d:\dev\tmp\null

echo.
echo Compilation de OuvertureInternet.au3
%AUTOIT% /in OuvertureInternet.au3 /out OuvertureInternet.exe /icon H:\dev\outils\progress\Menudev2\Ressources\Images/smile.ico
copy "H:\dev\outils\progress\Menudev2\Ressources\Scripts\general\OuvertureInternet.exe" d:\dev\outils 1>d:\dev\tmp\null

echo.
echo Compilation de SaisieAutomatique.au3
%AUTOIT% /in SaisieAutomatique.au3 /out SaisieAutomatique.exe /icon H:\dev\outils\progress\Menudev2\Ressources\Images/smile.ico
copy "H:\dev\outils\progress\Menudev2\Ressources\Scripts\general\SaisieAutomatique.exe" d:\dev\outils 1>d:\dev\tmp\null

:FIN
echo.
pause