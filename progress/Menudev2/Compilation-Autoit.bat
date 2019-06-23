@echo off

set AUTOIT="D:\Applications\AutoIt3\Aut2Exe\Aut2exe.exe"
if "%COMPUTERNAME%" == "PORTABLE-PL" set AUTOIT="C:\Program Files (x86)\AutoIt3\Aut2Exe\Aut2exe_x64.exe"

echo Compilation de LanceMenudev2.au3
%AUTOIT% /in LanceMenudev2.au3 /out LanceMenudev2.exe

:FIN
echo.
pause