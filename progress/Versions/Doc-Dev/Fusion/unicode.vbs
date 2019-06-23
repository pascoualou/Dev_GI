' Programme : unicode.vbs - Visual Basic Script
' Auteur    : Charles CAZAMAJOR 
' Date      : 11/02/2004
' Version   : V1.0 
' Objet     : Transformation en UNICODE d'un fichier transmis en argument


Option Explicit

Const ForReading = 1, ForWriting = 2, ForAppending = 8

Dim fso, FileIn, FileOut, f1, f2, f3
Dim args
Dim ReadLineTextFile

Set args  = Wscript.Arguments
If args.count >= 2 or args.count = 0 Then 
    WScript.Echo "Erreurs dans le nombre d'arguments"
    WScript.Quit(1)
End If

  'WScript.Quit(1)
Set fso = CreateObject("Scripting.FileSystemObject")

FileIn = args(0)

If not fso.FileExists(FileIn) Then
    WScript.Quit(1)
End If

FileOut = FileIn + ".temp"

Set f1 = fso.OpenTextFile(FileIn, ForReading, True)
Set f2 = fso.CreateTextFile(FileOut, true, true)

do While f1.AtEndOfStream <> True
  ReadLineTextFile = f1.ReadLine    
  f2.WriteLine(ReadLineTextFile)
'  WScript.Echo ReadLineTextFile
loop

f1.close
f2.Close

Set f3 = fso.GetFile(FileIn)
f3.Delete

Set f3 = fso.GetFile(FileOut)
f3.Move (FileIn)


