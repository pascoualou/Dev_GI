Attribute VB_Name = "OutilsGI"
' ------------------------------------------------------------------------------------------
'       outils.bas      :    Module contenant les fonctions et procédures de fusion MAGI
'
'       Auteur          :        AF
'       Date            :        ??
' ------------------------------------------------------------------------------------------
' Modifications :
' 16/09/2008 : PL : Ajout de la fonction Attends (Fonction maison) pour mettre une pause de
'                   1 seconde entre les actions lors de l'ajout de l'entete et du pied de
'                   page,car sinon, bascule en mode valeur de champ en plein milieu de
'                   l'ajout.
' 07/11/2008 : PL : Remplacement de la fonction maison par un appel de l'API : sleep + passe
'                   à 2 secondes la pause car ne fonctionne pas sur la machine de CB
'
'
'
'12/01/2011 : P.Pre suppression boite dialogue separateur enregistrement par
'               concatenation des fichiers entete et donnees.
'
'25/01/2011 : CC : modifs fusion
'22/02/2011 : DM : 0211/0146 pb fusion avec ligne vide dans les relances
'04/03/2011 : CC : Supression modif précédente
'05/07/2011 : PL : Pb si la ligne de données ne contient que "
'01/08/2011 : CC : Compatibilite GERER/autres clients
'05/03/2012 : RF : 0212/0255 Conversion HeadDatas.bak en UNICODE !!! Ne fonctionne qu'en gi, pas en gidev
'14/06/2013 : PL : 1012/0191 ajout fichier HeadDatas.ctl pour controle le travail de la 
'                  fusion de entete et donnée pour le 64bits
'11/06/2014 : NP : 0414/0217 pb de formatage quand découpage de word  Sub RecupQckStyle()
'28/07/2014 : CC : Problème fctMakefusionDatas 
' ------------------------------------------------------------------------------------------

' ------------------------------------------------------------------------------------------
' Constantes système
' ------------------------------------------------------------------------------------------

' ------------------------------------------------------------------------------------------
' Procédures externes
' ------------------------------------------------------------------------------------------
#If Win64 Then
Private Declare PtrSafe Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)
#Else
Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)
#End If


' ------------------------------------------------------------------------------------------
' Variables de travail
' ------------------------------------------------------------------------------------------
Dim MonImage As Variant
Dim MonCadre As Variant

Sub essai()
' ------------------------------------------------------------------------------------------
' Lancement manuel de la fusion
' ------------------------------------------------------------------------------------------
     application.Run "attacherfusion"
End Sub

Sub Image()
' ------------------------------------------------------------------------------------------
' Ajout et positionnement du logo
' ------------------------------------------------------------------------------------------
    Selection.HomeKey unit:=wdStory
    
    Set MonImage = Selection.Frames.Add(Range:=Selection.Paragraphs(1).Range)
    MonImage.RelativeHorizontalPosition = wdRelativeHorizontalPositionPage
    MonImage.RelativeVerticalPosition = wdRelativeVerticalPositionPage
    MonImage.HorizontalPosition = 40
    MonImage.VerticalPosition = 40
    MonImage.Borders.Enable = False
    MonImage.Width = 200
    MonImage.Height = 150
    MonImage.LockAnchor = True

    If application.version = "8.0b" Then
        Set MonChamps = MonImage.Range.Fields.Add(Range:=Selection.Range, Type:=wdFieldEmpty, Text:="INCLUREIMAGE  \d ", PreserveFormatting:=False)
        Selection.MoveRight unit:=wdCharacter, Count:=15
        Set MonChamps = MonImage.Range.Fields.Add(Range:=Selection.Range, Type:=wdFieldEmpty, Text:="CHAMPFUSION cheminlogo", PreserveFormatting:=False)
    Else
        ' PL : 16/09/2008 -> bascule en affichage de la définition du champ de fusion
        ActiveWindow.View.ShowFieldCodes = True
        Set MonChamps = MonImage.Range.Fields.Add(Range:=Selection.Range, Type:=wdFieldEmpty, Text:="INCLUDEPICTURE  \d ", PreserveFormatting:=False)
        
        Attends (2) ' PL : 16/09/2008 -> obligatoire car sinon l'insertion se fait trop vite
        Selection.MoveRight unit:=wdCharacter, Count:=17
        Set MonChamps = MonImage.Range.Fields.Add(Range:=Selection.Range, Type:=wdFieldEmpty, Text:="MERGEFIELD cheminlogo", PreserveFormatting:=False)
        Attends (2) ' PL : 16/09/2008 -> obligatoire car sinon l'insertion se fait trop vite
        ' PL : 16/09/2008 -> bascule en affichage de la valeur du champ de fusion
        ActiveWindow.View.ShowFieldCodes = False
    End If
    
    With CommandBars("Outils Gi").FindControl(Type:=msoControlButton, ID:=1)
        .Caption = "Suppression Logo"
        .OnAction = "SupImage"
        .FaceId = 16
    End With

    Selection.HomeKey unit:=wdStory
End Sub
Sub SupImage()
' ------------------------------------------------------------------------------------------
' Suppression du logo
' ------------------------------------------------------------------------------------------
    ' selection globale
    Selection.HomeKey unit:=wdStory
    
    ' suppresion de l'image
    If IsObjectValid(MonImage) Then
        MonImage.Range.Delete
        MonImage.Delete
    End If
    
    ' changement de libellé du bouton de la barre d'outils GI
    With CommandBars("Outils Gi").FindControl(Type:=msoControlButton, ID:=1)
        .Caption = "Insertion Logo"
        .OnAction = "Image"
        .FaceId = 16
    End With
    
    ' Déselection globale
    Selection.HomeKey unit:=wdStory
End Sub

Sub Entete()
' ------------------------------------------------------------------------------------------
' Ajout de l'entete du dcument
' ------------------------------------------------------------------------------------------
    ' Selection globale
    Selection.HomeKey unit:=wdStory
    
    ' passage en mode visualisation sur une page
    If ActiveWindow.View.SplitSpecial <> wdPaneNone Then
        ActiveWindow.Panes(2).Close
    End If
    If ActiveWindow.ActivePane.View.Type = wdNormalView _
    Or ActiveWindow.ActivePane.View.Type = wdOutlineView _
    Or ActiveWindow.ActivePane.View.Type = wdMasterView Then
        ActiveWindow.ActivePane.View.Type = wdPageView
    End If
    
    ' Activation de la section entete
    ActiveWindow.ActivePane.View.SeekView = wdSeekCurrentPageHeader
    
    ' Ajout de l'entete en fonction de la version de word
    If application.version = "8.0b" Then
        Selection.Fields.Add Range:=Selection.Range, Type:=wdFieldEmpty, Text:="INCLURETEXTE ", PreserveFormatting:=False
        Selection.MoveRight unit:=wdCharacter, Count:=15
        Selection.Range.Fields.Add Range:=Selection.Range, Type:=wdFieldEmpty, Text:="CHAMPFUSION Entete", PreserveFormatting:=False
    Else
        ' PL : 16/09/2008 -> bascule en affichage de la valeur du champ de fusion
        ActiveWindow.View.ShowFieldCodes = True
        Selection.Fields.Add Range:=Selection.Range, Type:=wdFieldEmpty, Text:="INCLUDETEXT ", PreserveFormatting:=False
        Attends (2) ' PL : 16/09/2008 -> obligatoire car sinon l'insertion se fait trop vite
        Selection.MoveRight unit:=wdCharacter, Count:=14
        Selection.Range.Fields.Add Range:=Selection.Range, Type:=wdFieldEmpty, Text:="MERGEFIELD Entete", PreserveFormatting:=False
        Attends (2) ' PL : 16/09/2008 -> obligatoire car sinon l'insertion se fait trop vite
        ' PL : 16/09/2008 -> bascule en affichage de la valeur du champ de fusion
        ActiveWindow.View.ShowFieldCodes = False
    End If
    
    ActiveWindow.ActivePane.View.SeekView = wdSeekMainDocument
    
    ' Mise à jour du libellé du bouton dans la barre d'outils GI
    With CommandBars("Outils Gi").FindControl(Type:=msoControlButton, ID:=2)
        .Caption = "Suppression Entete"
        .OnAction = "SupEntete"
        .FaceId = 599
    End With
    
    ' Déselection globale
    Selection.HomeKey unit:=wdStory
End Sub

Sub SupEntete()
' ------------------------------------------------------------------------------------------
' Suppression de l'entete du document
' ------------------------------------------------------------------------------------------
    ' Sélection globale
    Selection.HomeKey unit:=wdStory
       
    ' passage en mode visualisation sur une page
    If ActiveWindow.View.SplitSpecial <> wdPaneNone Then
        ActiveWindow.Panes(2).Close
    End If
    If ActiveWindow.ActivePane.View.Type = wdNormalView _
    Or ActiveWindow.ActivePane.View.Type = wdOutlineView _
    Or ActiveWindow.ActivePane.View.Type = wdMasterView Then
        ActiveWindow.ActivePane.View.Type = wdPageView
    End If
    
    ' Suppression de l'entete
    ActiveWindow.ActivePane.View.SeekView = wdSeekCurrentPageHeader
    Selection.WholeStory
    Selection.Delete unit:=wdCharacter, Count:=1
    
    ActiveWindow.ActivePane.View.SeekView = wdSeekMainDocument
    
    ' Mise à jour du libellé du bouton dans la barre d'outils GI
    With CommandBars("Outils Gi").FindControl(Type:=msoControlButton, ID:=2)
        .Caption = "Insertion Entete"
        .OnAction = "Entete"
        .FaceId = 599
    End With
    
    ' Déselection globale
    Selection.HomeKey unit:=wdStory
End Sub

Sub Pied()
' ------------------------------------------------------------------------------------------
' Ajout du pied de page du document
' ------------------------------------------------------------------------------------------
    
    ' Sélection globale
    Selection.HomeKey unit:=wdStory
    
    ' passage en mode visualisation sur une page
    If ActiveWindow.View.SplitSpecial <> wdPaneNone Then
        ActiveWindow.Panes(2).Close
    End If
    If ActiveWindow.ActivePane.View.Type = wdNormalView _
    Or ActiveWindow.ActivePane.View.Type = wdOutlineView _
    Or ActiveWindow.ActivePane.View.Type = wdMasterView Then
        ActiveWindow.ActivePane.View.Type = wdPageView
    End If
    
    ' Activation de la section pied de page
    ActiveWindow.ActivePane.View.SeekView = wdSeekCurrentPageFooter
    
    ' Ajout du pied de page en fonction de la version de word
    If application.version = "8.0b" Then
        Selection.Fields.Add Range:=Selection.Range, Type:=wdFieldEmpty, Text:="INCLURETEXTE ", PreserveFormatting:=False
        Selection.MoveRight unit:=wdCharacter, Count:=15
        Selection.Range.Fields.Add Range:=Selection.Range, Type:=wdFieldEmpty, Text:="CHAMPFUSION PiedPage", PreserveFormatting:=False
    Else
        ' PL : 16/09/2008 -> bascule en affichage de la définition du champ de fusion
        ActiveWindow.View.ShowFieldCodes = True
        Selection.Fields.Add Range:=Selection.Range, Type:=wdFieldEmpty, Text:="INCLUDETEXT ", PreserveFormatting:=False
        Attends (2) ' PL : 16/09/2008 -> obligatoire car sinon l'insertion se fait trop vite
        Selection.MoveRight unit:=wdCharacter, Count:=14
        Selection.Range.Fields.Add Range:=Selection.Range, Type:=wdFieldEmpty, Text:="MERGEFIELD PiedPage", PreserveFormatting:=False
        Attends (2) ' PL : 16/09/2008 -> obligatoire car sinon l'insertion se fait trop vite
        ' PL : 16/09/2008 -> bascule en affichage de la valeur du champ de fusion
        ActiveWindow.View.ShowFieldCodes = False
    End If
    
    ActiveWindow.ActivePane.View.SeekView = wdSeekMainDocument
    
    ' Mise à jour du libellé du bouton dans la barre d'outils GI
    With CommandBars("Outils Gi").FindControl(Type:=msoControlButton, ID:=3)
        .Caption = "Suppression Pied"
        .OnAction = "SupPied"
        .FaceId = 213
    End With
    
    ' Déselection globale
    Selection.HomeKey unit:=wdStory
End Sub

Sub SupPied()
' ------------------------------------------------------------------------------------------
' Suppression du pied de page du document
' ------------------------------------------------------------------------------------------
    
    ' Sélection globale
    Selection.HomeKey unit:=wdStory
    
    ' passage en mode visualisation sur une page
    If ActiveWindow.View.SplitSpecial <> wdPaneNone Then
        ActiveWindow.Panes(2).Close
    End If
    If ActiveWindow.ActivePane.View.Type = wdNormalView _
    Or ActiveWindow.ActivePane.View.Type = wdOutlineView _
    Or ActiveWindow.ActivePane.View.Type = wdMasterView Then
        ActiveWindow.ActivePane.View.Type = wdPageView
    End If
    
    ' Suppression du pied de page
    ActiveWindow.ActivePane.View.SeekView = wdSeekCurrentPageFooter
    Selection.WholeStory
    Selection.Delete unit:=wdCharacter, Count:=1
    
    ActiveWindow.ActivePane.View.SeekView = wdSeekMainDocument
    
    ' Mise à jour du libellé du bouton dans la barre d'outils GI
    With CommandBars("Outils Gi").FindControl(Type:=msoControlButton, ID:=3)
        .Caption = "Insertion Pied"
        .OnAction = "Pied"
        .FaceId = 213
    End With
    
    ' Déselection globale
    Selection.HomeKey unit:=wdStory
End Sub

Sub Destinataire()
' ------------------------------------------------------------------------------------------
' SAjout des informations sur le destinataire
' ------------------------------------------------------------------------------------------
    Selection.HomeKey unit:=wdStory
    Set MonCadre = ActiveDocument.Shapes.AddTextbox(msoTextOrientationHorizontal, 320, 150, 240.95, 141.75)
    MonCadre.Line.Visible = msoFalse
    MonCadre.TextFrame.TextRange.Select
    MonCadre.RelativeHorizontalPosition = wdRelativeHorizontalPositionPage
    MonCadre.RelativeVerticalPosition = wdRelativeVerticalPositionPage
    MonCadre.Left = CentimetersToPoints(10.5)
    MonCadre.Top = CentimetersToPoints(5.5)
    MonCadre.LockAnchor = True
    MonCadre.WrapFormat.Type = wdWrapSquare
    MonCadre.WrapFormat.Side = wdWrapBoth
    MonCadre.WrapFormat.DistanceTop = CentimetersToPoints(0)
    MonCadre.WrapFormat.DistanceBottom = CentimetersToPoints(0)
    MonCadre.WrapFormat.DistanceLeft = CentimetersToPoints(0.32)
    MonCadre.WrapFormat.DistanceRight = CentimetersToPoints(0.32)
    
    ActiveDocument.MailMerge.Fields.Add Range:=Selection.Range, Name:="NomCompletDestinataire"
    Selection.ParagraphFormat.Alignment = wdAlignParagraphLeft
    Selection.TypeText Text:=Chr(11)
    ActiveDocument.MailMerge.Fields.Add Range:=Selection.Range, Name:="NomCompletDesCO"
    Selection.TypeText Text:=Chr(11)
    ActiveDocument.MailMerge.Fields.Add Range:=Selection.Range, Name:="AdresseDestinataire"
    Selection.TypeText Text:=Chr(11)
    ActiveDocument.MailMerge.Fields.Add Range:=Selection.Range, Name:="SuiteAdresseDestinataire"
    Selection.TypeText Text:=Chr(11)
    ActiveDocument.MailMerge.Fields.Add Range:=Selection.Range, Name:="CodePostalDestinataire"
    Selection.TypeText Text:=" "
    ActiveDocument.MailMerge.Fields.Add Range:=Selection.Range, Name:="VilleCedexDestinataire"
    Selection.TypeText Text:=Chr(11)
    ActiveDocument.MailMerge.Fields.Add Range:=Selection.Range, Name:="PaysDestinataire"
    Selection.ParagraphFormat.SpaceAfter = 24
    Selection.TypeParagraph
    ActiveDocument.MailMerge.Fields.Add Range:=Selection.Range, Name:="Ville_Cabinet"
    Selection.TypeText Text:=", le "
    ActiveDocument.MailMerge.Fields.Add Range:=Selection.Range, Name:="DateLCreationCourrier"
        
    With CommandBars("Outils Gi").FindControl(Type:=msoControlButton, ID:=4)
        .Caption = "Suppression Destinataire"
        .OnAction = "SupDestinataire"
        .FaceId = 363
    End With
    CommandBars("Outils Gi").FindControl(Type:=msoControlButton, ID:=4).FaceId = 363
    Selection.HomeKey unit:=wdStory
End Sub
Sub SupDestinataire()
' ------------------------------------------------------------------------------------------
' Suppression du bloc destinataire
' ------------------------------------------------------------------------------------------
    Selection.HomeKey unit:=wdStory
    If IsObjectValid(MonCadre) Then
        MonCadre.Delete
    End If
    With CommandBars("Outils Gi").FindControl(Type:=msoControlButton, ID:=4)
        .Caption = "Insertion Destinataire"
        .OnAction = "Destinataire"
        .FaceId = 363
    End With
    
    CommandBars("Outils Gi").FindControl(Type:=msoControlButton, ID:=4).FaceId = 363
    Selection.HomeKey unit:=wdStory
End Sub
Sub Verifier()
' ------------------------------------------------------------------------------------------
' Lancement de la vérification de la fusion
' ------------------------------------------------------------------------------------------
    On Error GoTo gesterreur
    ActiveDocument.MailMerge.Check
    Exit Sub
    
gesterreur:
    Select Case Err.Number
        Case 4605
            MsgBox ("Votre modèle ne possède aucun champs de fusion")
    End Select
End Sub

Sub attacherfusion()
' ------------------------------------------------------------------------------------------
' Procedure de fusion
' ------------------------------------------------------------------------------------------
    
    'ActiveDocument.MailMerge.MainDocumentType = 0
    RpTmpUse = Environ("Tmp") + "\"
    
    ActiveDocument.MailMerge.MainDocumentType = wdNotAMergeDocument
        
    #If Win64 Then
    'reduction de la fenetre
    ActiveDocument.ActiveWindow.WindowState = wdWindowStateMinimize

   'Concatenation header et datas dans le meme fichier
    fctMakefusionDatas (RpTmpUse)
    ' Lancement de la fusion : ouverture de la valeur des champs
    ActiveDocument.MailMerge.OpenDataSource Name:=RpTmpUse + "HeadDatas.bak", _
         ConfirmConversions:=False, ReadOnly:=False, LinkToSource:=True, _
        AddToRecentFiles:=False, PasswordDocument:="", PasswordTemplate:="", _
        WritePasswordDocument:="", WritePasswordTemplate:="", Revert:=False, _
        Format:=wdOpenFormatAuto, Connection:="", SQLStatement:="", SQLStatement1 _
        :=""
    #Else
    ' Pour répondre ok ou oui aux deux questions lors de la fusion
    SendKeys "{ENTER}" & "{ENTER}"
    
    ' Lancement de la fusion : ouverture de la définition des champs
    ActiveDocument.MailMerge.OpenHeaderSource Name:=RpTmpUse + "entete.doc" _
        , ConfirmConversions:=False, ReadOnly:=False, AddToRecentFiles:=False, _
        PasswordDocument:="", PasswordTemplate:="", Revert:=False, _
        WritePasswordDocument:="", WritePasswordTemplate:="", Format:= _
       wdOpenFormatAuto
        
    ' Lancement de la fusion : ouverture de la valeur des champs
    ActiveDocument.MailMerge.OpenDataSource Name:=RpTmpUse + "donnees.doc", _
         ConfirmConversions:=False, ReadOnly:=False, LinkToSource:=True, _
        AddToRecentFiles:=False, PasswordDocument:="", PasswordTemplate:="", _
        WritePasswordDocument:="", WritePasswordTemplate:="", Revert:=False, _
        Format:=wdOpenFormatAuto, Connection:="", SQLStatement:="", SQLStatement1 _
        :=""

   #End If

        'Maximisation de la fenetre
        ActiveDocument.ActiveWindow.WindowState = wdWindowStateMinimize
        ActiveDocument.ActiveWindow.WindowState = wdWindowStateMaximize
        

End Sub

Sub Controle()
' ------------------------------------------------------------------------------------------
' ??? Non utilisée
' ------------------------------------------------------------------------------------------
    RpTmpUse = Environ("Tmp") + "\"
    Open RpTmpUse + "controle.txt" For Output As #1

    For I = 1 To ActiveDocument.Fields.Count
        If ActiveDocument.Fields(I).Type = 59 Then
            lbchprch = StrConv(ActiveDocument.Fields(I).Code, vbLowerCase)
            lbchprch = Replace(lbchprch, " ", "")
            lbchprch = Replace(lbchprch, "\*mergeformat", "")
            lbchprch = Replace(lbchprch, "mergefield", "")
            
            lbchprch = StrConv(lbchprch, vbLowerCase)
            
            fgtrvchp = False
            For j = 1 To ActiveDocument.MailMerge.DataSource.DataFields.Count
                lbchpuse = ActiveDocument.MailMerge.DataSource.DataFields(j).Name
                lbchpuse = StrConv(lbchpuse, vbLowerCase)
                
                If lbchpuse = lbchprch Then
                    fgtrvchp = True
                End If
            Next j
            
            If Not fgtrvchp Then
                Print #1, lbchprch
            End If
        End If
    Next I
    
    For h = 1 To ActiveDocument.Shapes.Count
        ActiveDocument.Shapes(h).Select
        For I = 1 To Selection.Fields.Count
            If Selection.Fields(I).Type = 59 Then
                lbchprch = StrConv(Selection.Fields(I).Code, vbLowerCase)
                lbchprch = Replace(lbchprch, " ", "")
                lbchprch = Replace(lbchprch, "\*mergeformat", "")
                lbchprch = Replace(lbchprch, "mergefield", "")
                
                lbchprch = StrConv(lbchprch, vbLowerCase)
                
                fgtrvchp = False
                For j = 1 To ActiveDocument.MailMerge.DataSource.DataFields.Count
                    lbchpuse = ActiveDocument.MailMerge.DataSource.DataFields(j).Name
                    lbchpuse = StrConv(lbchpuse, vbLowerCase)
                    
                    If lbchpuse = lbchprch Then
                        fgtrvchp = True
                    End If
                Next j
                
                If Not fgtrvchp Then
                    Print #1, lbchprch
                End If
            End If
        Next I
    Next h
    
    Close #1
End Sub

Sub Condition()
' ------------------------------------------------------------------------------------------
' ??? Non utilisée
' ------------------------------------------------------------------------------------------
    FrmTest.Show
End Sub

Sub Formulaire()
' ------------------------------------------------------------------------------------------
' Ajout du formulaire
' ------------------------------------------------------------------------------------------
    
    Titre$ = "Insertion d'un Formulaire"
    Message$ = "Veuillez saisir le numéro du formulaire"
    NomFic = WordBasic.[InputBox$](Message$, Titre$, "1")

    For I = 1 To Len(NomFic)
        If Mid(NomFic, I, 1) < Chr$(13) Then Mid(NomFic, I, 1) = ""
    Next I
    NomFic = Trim(NomFic)
    If Trim(NomFic) = "" Then End

    NomFic = ActiveDocument.Path + "\" + "Form-" + NomFic + "-" + ActiveDocument.Name
    ExisteFic = Dir(NomFic)
    mydot = ActiveDocument
    StartSel = Selection.Start
    
    If Trim(ExisteFic) = "" Then
        Documents.Add
        ActiveDocument.SaveAs filename:=NomFic, fileformat:=wdFormatDocument
    Else
        Documents.Open (NomFic)
    End If
    
    Documents(mydot).Range(Start:=StartSel, End:=StartSel).InsertFile filename:=NomFic, Range:="", ConfirmConversions:=False, Link:=True, Attachment:=False

End Sub

Sub Protect()
' ------------------------------------------------------------------------------------------
' protection d'un document
' ------------------------------------------------------------------------------------------

    If ActiveDocument.ProtectionType = wdNoProtection Then
        ActiveDocument.Protect Type:=wdAllowOnlyFormFields, NoReset:=True
        CommandBars("Outils GI").Controls.Item(1).Caption = "Oter la Protection"
    Else
        ActiveDocument.Unprotect
        CommandBars("Outils GI").Controls.Item(1).Caption = "Mettre la Protection"
    End If
End Sub

'Sub Attends(iTemps As Long)
'    Dim iBoucle As Long
'    While iBoucle < iTemps * 5000
'        iBoucle = iBoucle + 1
'    Wend
'
'End Sub

Sub Attends(iSeconde As Single)
' ------------------------------------------------------------------------------------------
' Appel de la routine de pause de windows
' Entrée : Temps de pause en secondes
' ------------------------------------------------------------------------------------------
   Call Sleep(Int(iSeconde * 1000#))
End Sub

Sub Statut(LbStatut As String)
'
'
    ActiveDocument.Shapes.AddTextEffect(msoTextEffect1, LbStatut, _
        "Arial Black", 51#, msoFalse, msoFalse, 10, 10).Select

        With Selection.ShapeRange
                .Fill.Visible = msoFalse
                .IncrementTop 200#
                .IncrementLeft IIf(LbStatut = "Projet", 100#, 40#)
                .IncrementRotation IIf(LbStatut = "Projet", 40, 50)
                .ScaleWidth 2.15, msoFalse, msoScaleFromTopLeft
        End With

End Sub

' ------------------------------------------------------------------------------------------
' Appel de la routine de concatenation du header et des datas.
'
' ------------------------------------------------------------------------------------------

Sub fctMakefusionDatas(strTmpPath As String)

    Dim intFic As Integer
    Dim intFic1 As Integer
    Dim strDatas As String
    Dim strDatasRcd As String
    Dim iLine As Integer
    
    'init variables
    strDatas = ""
    
    ' ajout du header
    '-------------> Vieux code                                               FileCopy strTmpPath + "entete.doc", strTmpPath + "HeadDatas.bak"
                                                                            'intFic = FreeFile
                                                                            'intFic1 = FreeFile
    Open strTmpPath + "entete.doc" For Input As #1
    Open strTmpPath + "HeadDatas.bak" For Output As #2
    Open strTmpPath + "HeadDatas.ctl" For Output As #3
    While Not EOF(1)
        Line Input #1, strDatasRcd
        Print #2, strDatasRcd
    '-------------> Vieux code                                               iLine = iLine + 1
                                                                            'If Not EOF(intFic) Then
                                                                            '    strDatas = strDatas + strDatasRcd '+ vbCrLf
                                                                            'Else
                                                                            '    strDatas = strDatas + strDatasRcd
                                                                            'End If
    Wend
    Close #1
    'Close #2
   
    'Recup des datas
    '-------------> Vieux code                                               intFic = FreeFile
                                                                            'intFic1 = FreeFile
    Open strTmpPath + "donnees.doc" For Input As #1
    'Open strTmpPath + "HeadDatas.bak" For Append As #2
    While Not EOF(1)
        Line Input #1, strDatasRcd
        
        ' Pour un controle de lecture
        sResultat = ""
        If strDatasRcd <> "" Then sResultat = IIf(LenB(strDatasRcd) > 2, Mid(strDatasRcd, 1, LenB(strDatasRcd) - 2), "")
        Print #3, "|" & strDatasRcd & "|" & CStr(LenB(strDatasRcd))& "|" & CStr(Len(strDatasRcd)) & "|" & (strDatasRcd = """") & "|" & sResultat & "|"
 
        If LenB(strDatasRcd) > 2 Then Print #2, Mid(strDatasRcd, 1, LenB(strDatasRcd) - 2)
        
        ' PL 13/07/2011 Il faut tenir compte du fait que la ligne peut ne contenir que "
        If strDatasRcd = """" Then Print #2, Mid(strDatasRcd, 1, 1)
        
        '-------------> Vieux code                                           If LenB(strDatasRcd) = 0 Then Print #2, "" ' DM 0211/0146
                                                                            'iLine = iLine + 1
                                                                            'If Not EOF(intFic) Then
                                                                            '    strDatas = strDatas + strDatasRcd '+ vbCrLf
                                                                            'Else
                                                                            '    strDatas = strDatas + strDatasRcd
                                                                            'End If
    Wend
    Close #1
    Close #2
    Close #3

    '-------------> Vieux code                                               Ajout des datas
                                                                            'intFic = FreeFile
                                                                            'Open strTmpPath + "HeadDatas.bak" For Append As intFic
                                                                            'If iLine = 1 Then Print #intFic, vbCrLf
                                                                            'Print #intFic, strDatas 'vbCrLf + strDatas
                                                                            'Close intFic
    
    ' Le test suivant n'est la que pour eviter la conversion lors des tests
    ' en local (win32). En effet windows demande toujours la permission d'ouvrir le fichier ???
    #If Win64 Then
        'Conversion HeadDatas.bak en UNICODE  RF 05/03/2012 0212/0255
        StConvUni = Environ("reseau") + "gi\adb\word\macro\unicode.bat " + strTmpPath + "HeadDatas.bak"
        Call Shell(StConvUni, 1)
   #End If
    
    'Pour éviter conflit d'utilisation
    Attends (5)
    
End Sub

Sub RecupQckStyle()
' ------------------------------------------------------------------------------------------
' Récupération de la barre des styles rapides du .dot sélectionné
' ------------------------------------------------------------------------------------------

    RpTmpUse = Environ("Temp") + "\" + Environ("COMPUTERNAME")

    WordBasic.SaveAsQuickFormatSet Name:=RpTmpUse +  ".dot", Format:=14, LockAnnot:= _
        0, Password:="", AddToMru:=0, WritePassword:="", RecommendReadOnly:=0, _
        EmbedFonts:=0, NativePictureFormat:=0, FormsData:=0, SaveAsAOCELetter:=0, _
         WriteVersion:=0, VersionDesc:="", Encoding:=0, InsertLineBreaks:=0, _
        AllowSubstitutions:=0, LineEnding:=0, AddBiDiMarks:=0

End Sub