Dim fso, FichierResultat, disque, Ligne 

Set FSO = CreateObject("Scripting.FileSystemObject")
Set FichierResultat = fso.CreateTextFile(WScript.Arguments(0), True)
 
For Each disque In FSO.Drives
    If Disque.IsReady and (Disque.DriveType = 1 or Disque.DriveType = 2) Then
		Set disque = fso.GetDrive(fso.GetDriveName(Disque.DriveLetter & ":\"))
		Ligne = UCase(disque) & "," & CStr(disque.TotalSize/1024) & "," & CStr(disque.FreeSpace/1024) & "," & CStr(disque.DriveType)
		FichierResultat.WriteLine(Ligne)
    End If
Next

FichierResultat.Close