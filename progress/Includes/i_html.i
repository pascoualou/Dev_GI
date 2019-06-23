/*--------------------------------------------------------------------------*
|                                                                           |
| Application      : A.D.B. Progress version graphique                      |
| Programme        : edithtml.i                                             |
| Objet            : Editions sommaires au format html                      |
|                                                                           |
|---------------------------------------------------------------------------|
|                                                                           |
| Date de cr�ation : 13/11/2008                                             |
| Auteur(s)        : PL                                                     |
| Dossier analyse  : ?                                                      |
|                                                                           |
|---------------------------------------------------------------------------|
|                                                                           |
| Param�tres d'entr�es  :                                                   |
|                                                                           |
| Param�tres de sorties :                                                   |
|                                                                           |
| Exemple d'appel       :                                                   |
|                                                                           |
*---------------------------------------------------------------------------*


*---------------------------------------------------------------------------*
| Historique des modifications                                              |
|---------------------------------------------------------------------------|
|  N�  |    Date    | Auteur |                  Objet                       |
|------+------------+--------+----------------------------------------------|
| .... | ../../.... |  ....  | .                                            |
|      |            |        |                                              |
*--------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 | DEFINITIONS                                                             |
 *-------------------------------------------------------------------------*/
/* Proc�dures externes */
PROCEDURE ShellExecuteA EXTERNAL "shell32.dll" :
  DEFINE INPUT  PARAMETER hwnd          AS short.
  DEFINE INPUT  PARAMETER lpOperation   AS CHAR.
  DEFINE INPUT  PARAMETER lpFile        AS CHAR.
  DEFINE INPUT  PARAMETER lpParameters  AS CHAR.
  DEFINE INPUT  PARAMETER lpDirectory   AS CHAR.
  DEFINE INPUT  PARAMETER nShowCmd      AS short.
  DEFINE RETURN PARAMETER hInstance     AS short.
END PROCEDURE.

/* Definition de la table des cellules */
DEFINE TEMP-TABLE HTML_Cellules
    FIELD sTypeCellule AS CHARACTER             /* "E"nt�te / "L"igne */
    FIELD iNumeroCellule AS INTEGER             /* Numero de la cellule ou 0 pour toutes les cellules de la ligne */
    FIELD sTaille AS CHARACTER INIT ""          /* Taille du texte de la cellule (en fait = niveau au sens Html */
    FIELD sCouleurFond AS CHARACTER INIT ""     /* Couleur de fond de la cellule */
    FIELD sCouleurEncre AS CHARACTER INIT ""    /* Couleur de l'encre de la cellule */
    FIELD sAlignement AS CHARACTER INIT ""      /* Alignement de la cellule = rien/< (cadr� � gauche)/> (cadr� � droite)/<> (Justifi�)/>< (centr�) */
    .

/* Variables utilisables dans les programmes appelants */
DEFINE VARIABLE devSeparateurEdition AS CHARACTER INIT "�" .    /* Caract�re de s�paration des cellules */
DEFINE VARIABLE devBlancPourEdition AS CHARACTER INIT "&nbsp" . /* Blanc ins�cable au sens Html */

/* Variables de travail */
DEFINE VARIABLE HTML_sFichier   AS CHARACTER    NO-UNDO.    /* Nom du fichier d'�dition */
DEFINE STREAM HTML_stEdi.                                   /* Stream du fichier d'�dition */
DEFINE STREAM HTML_stEnt.                                   /* Pour l'�dition d'un fichier */

/*-------------------------------------------------------------------------*
 | FONCTIONS                                                               |
 *-------------------------------------------------------------------------*/
FUNCTION HTML_DonneCouleur RETURN CHARACTER(sCouleur AS CHARACTER):
/* ------------------------------------------------------------------------------------------ 
   Retourne le numero de la couleur depuis son nom                                            
   Entr�e : Nom de la couleur                                                               
   ------------------------------------------------------------------------------------------ */
    DEFINE VARIABLE sRetour AS CHARACTER    NO-UNDO.

    sRetour = "".
    If sCouleur = "rouge" Then sRetour = "#FF0000".
    If sCouleur = "vert" Then sRetour = "#00CC33".
    If sCouleur = "bleu" Then sRetour = "#3300CC".
    If sCouleur = "jaune" Then sRetour = "#FFFF66".
    If sCouleur = "orange" Then sRetour = "#FFCC33".
    If sCouleur = "gris" Then sRetour = "#C0C0C0".
    If sCouleur = "noir" Then sRetour = "#000000".
    If sCouleur = "blanc" Then sRetour = "#FFFFFF".
    
    RETURN sRetour.
End FUNCTION.

FUNCTION HTML_DonneTaille RETURN CHARACTER(sTexte AS CHARACTER , iNiveau AS INTEGER):
/* ------------------------------------------------------------------------------------------ 
   Retourne une chaine formatt�e avec la taille du texte demand�                                          
   Entr�e : texte, taille (attention plus iNiveau est grand plus le texte est ecrit petit
   ------------------------------------------------------------------------------------------ */
    DEFINE VARIABLE sRetour AS CHARACTER    NO-UNDO.
    If iNiveau <> 0 Then sRetour = "<h" + STRING(iNiveau) + ">" + sTexte + "</h" + STRING(iNiveau) + ">".
    RETURN sRetour.
End FUNCTION.

FUNCTION HTML_DonneAlignement RETURN CHARACTER(sAlignement As CHARACTER):
/* ------------------------------------------------------------------------------------------ 
   Retourne une chaine formatt�e avec l'alignement du texte demand�                                          
   Entr�e : alignement au format html
   ------------------------------------------------------------------------------------------ */
    DEFINE VARIABLE sRetour AS CHARACTER    NO-UNDO.
    
    sRetour = "".
    If sAlignement = "<" Then sRetour = "left".
    If sAlignement = ">" Then sRetour = "right".
    If sAlignement = "><" Then sRetour = "center".
    If sAlignement = "<>" Then sRetour = "justify".
    
    If sRetour <> "" Then sRetour = " align=""" + sRetour + """".
    RETURN sRetour.
End FUNCTION.

FUNCTION HTML_DonneFormatCellule RETURN CHARACTER (sTypeCellule AS CHARACTER,iNumeroCellule AS INTEGER ):
/* ------------------------------------------------------------------------------------------ 
   Retourne le format de la cellule donn�e en parametre SAUF LA TAILLE 
   Entr�e : type de cellule ("E"ntete / "L"igne),num�ro de la cellule 
   ------------------------------------------------------------------------------------------ */
    DEFINE VARIABLE sRetour AS CHARACTER    NO-UNDO INIT "".
    
    DEFINE VARIABLE sFormatFond AS CHARACTER NO-UNDO.
    DEFINE VARIABLE sFormatEncre AS CHARACTER NO-UNDO.
    DEFINE VARIABLE sFormatAlignement AS CHARACTER NO-UNDO.
    
    /* On cherche d'abord le format g�n�ral */
    FIND FIRST HTML_Cellules
        WHERE   HTML_Cellules.sTypeCellule = sTypeCellule
        AND     HTML_Cellules.iNumeroCellule = 0
        NO-ERROR.
    IF AVAILABLE(HTML_Cellules) THEN DO:
        If HTML_Cellules.sCouleurFond <> "" Then sFormatFond = " bgcolor=""" + HTML_DonneCouleur(HTML_Cellules.sCouleurFond) + """".
        If HTML_Cellules.sCouleurEncre <> "" Then sFormatEncre = " style=""color:" + HTML_DonneCouleur(HTML_Cellules.sCouleurEncre) + ";""".
        If HTML_Cellules.sAlignement <> "" Then sFormatAlignement = HTML_DonneAlignement(HTML_Cellules.sAlignement).
    END.
    /* ensuite le format particulier */
    FIND FIRST HTML_Cellules
        WHERE   HTML_Cellules.sTypeCellule = sTypeCellule
        AND     HTML_Cellules.iNumeroCellule = iNumeroCellule
        NO-ERROR.
    IF AVAILABLE(HTML_Cellules) THEN DO:
        If HTML_Cellules.sCouleurFond <> "" Then sFormatFond = " bgcolor=""" + HTML_DonneCouleur(HTML_Cellules.sCouleurFond) + """".
        If HTML_Cellules.sCouleurEncre <> "" Then sFormatEncre = " style=""color:" + HTML_DonneCouleur(HTML_Cellules.sCouleurEncre) + ";""".
        If HTML_Cellules.sAlignement <> "" Then sFormatAlignement = HTML_DonneAlignement(HTML_Cellules.sAlignement).
    END.
    /* gestion du retour */
    sRetour = sFormatFond + sFormatEncre + sFormatAlignement.
    RETURN(sRetour).    
End FUNCTION.

FUNCTION HTML_DonneTailleCellule RETURN CHARACTER (sTypeCellule As CHARACTER, iNumeroCellule AS INTEGER, sValeurCellule AS CHARACTER ):
/* ------------------------------------------------------------------------------------------ 
   Retourne le format de la taille de la cellule donn�e en parametre UNIQUEMENT LA TAILLE 
   Entr�e : type de cellule ("E"ntete / "L"igne),num�ro de la cellule, valeur de la cellule
   ------------------------------------------------------------------------------------------ */
    DEFINE VARIABLE sRetour AS CHARACTER    NO-UNDO INIT "".
    
    /* Par d�faut, le format est la valeur initiale de la cellule sans taille */
    sRetour = sValeurCellule.
    
    /* D'abord le format g�n�ral */
    FIND FIRST HTML_Cellules
        WHERE   HTML_Cellules.sTypeCellule = sTypeCellule
        AND     HTML_Cellules.iNumeroCellule = 0
        NO-ERROR.
    IF AVAILABLE(HTML_Cellules) THEN DO:
        If HTML_Cellules.sTaille <> "" Then sRetour = HTML_DonneTaille(sRetour, INTEGER(HTML_Cellules.sTaille)).
    END.
    /* Ensuite le format particulier */
    FIND FIRST HTML_Cellules
        WHERE   HTML_Cellules.sTypeCellule = sTypeCellule
        AND     HTML_Cellules.iNumeroCellule = iNumeroCellule
        NO-ERROR.
    IF AVAILABLE(HTML_Cellules) THEN DO:
        If HTML_Cellules.sTaille <> "" Then sRetour = HTML_DonneTaille(sRetour, INTEGER(HTML_Cellules.sTaille)).
    END.
    
    /* gestion du retour */
    RETURN(sRetour).
End FUNCTION.

FUNCTION HTML_FormateBlancs RETURN CHARACTER(sChaine AS CHARACTER):
/* ------------------------------------------------------------------------------------------ 
   Retourne une chaine avec les blancs formatt� en espace ins�cables pour html
   Entr�e : une chaine
   Sortie : la chaine avec les blancs remplac�s
   ------------------------------------------------------------------------------------------ */
    DEFINE VARIABLE sRetour AS CHARACTER NO-UNDO.
    
    /* Par d�faut, la valeur de la chaine est la chaine elle-m�me */
    sRetour = sChaine.
    
    /* Remplacement des blancs */
    If Trim(sChaine) = "" Then sRetour = REPLACE( sChaine," ", devBlancPourEdition).
    
    /* Gestion du retour */
    RETURN sRetour.
End FUNCTION.

/*-------------------------------------------------------------------------*
 | PROCEDURES                                                              |
 *-------------------------------------------------------------------------*/
PROCEDURE HTML_VideFormatCellule:
/* ------------------------------------------------------------------------------------------
   Vidage de la table des formats de cellule                                                 
   ------------------------------------------------------------------------------------------*/
    EMPTY TEMP-TABLE HTML_Cellules.
END PROCEDURE.

PROCEDURE HTML_ChargeFormatCellule:
/* ------------------------------------------------------------------------------------------
   stocke le format de la cellule donn�e en parametre                                        
   Entr�e : type de cellule ("E"ntete / "L"igne),num�ro de la cellule,informations           
   ------------------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER sTypeCellule As CHARACTER.
DEFINE INPUT PARAMETER iNumeroCellule AS INTEGER.
DEFINE INPUT PARAMETER sInformations As CHARACTER.

    DEFINE VARIABLE iBoucle             AS INTEGER NO-UNDO.
    DEFINE VARIABLE sTypeInformation    As CHARACTER    NO-UNDO.
    DEFINE VARIABLE sValeurInformation  As CHARACTER    NO-UNDO.
    DEFINE VARIABLE iCellule            AS INTEGER NO-UNDO.
    
    /* Ajout de la cellule dans la table */    
    CREATE HTML_Cellules.
    HTML_Cellules.sTypeCellule = sTypeCellule.
    HTML_Cellules.iNumeroCellule = iNumeroCellule.
    
    /* D�codage des informations de formattage de chaque cellule */
    DO iBoucle = 1 To NUM-ENTRIES(sInformations):
        sTypeInformation = ENTRY(1, ENTRY(iBoucle, sInformations), "=").
        sValeurInformation = ENTRY(2, ENTRY(iBoucle, sInformations), "=").
        CASE sTypeInformation:
            WHEN "T" THEN 
                HTML_Cellules.sTaille = sValeurInformation.
            WHEN "CF" THEN 
                HTML_Cellules.sCouleurFond = sValeurInformation.
            WHEN "CE" THEN 
                HTML_Cellules.sCouleurEncre = sValeurInformation.
            WHEN "A" THEN
                HTML_Cellules.sAlignement = sValeurInformation.
        End CASE.
    END.
END PROCEDURE.

PROCEDURE HTML_OuvreFichier:
/* ------------------------------------------------------------------------------------------
   Ouverture du fichier d'�dition
   Entr�e : un nom de fichier �ventuellement
   ------------------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER sNomFichier  AS CHARACTER    NO-UNDO.
    
    /* nom de fichier donn� ou non */
    IF sNomFichier = "" THEN DO:
         sNomFichier = OS-GETENV("TEMP") + "\Edition.html".
    END.

    /* Affectation globale du nom de fichier pour les autres procedure et fonctions */
    HTML_sFichier = sNomFichier.
    
    /* Ouverture du fichier */
    OUTPUT STREAM  HTML_stEdi TO VALUE(HTML_sFichier).
    
    /* Vidage de la table temporaire des cellules */
    RUN HTML_VideFormatCellule.
END PROCEDURE.

PROCEDURE HTML_DebutEdition:
/* ------------------------------------------------------------------------------------------
   Proc�dure de d�but de l'�dition
   Entr�e : titre de l'�dition
   ------------------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER sTitre AS CHARACTER NO-UNDO.
    RUN HTML_Ligne ("<html><head><title>" + sTitre + "</title>","").
END PROCEDURE.

PROCEDURE HTML_TitreEdition:
/* ------------------------------------------------------------------------------------------
   Proc�dure d'ecriture du titre de l'�dition
   Entr�e : titre de l'�dition
   ------------------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER sTitre AS CHARACTER NO-UNDO.

    /* Lancement du d�but de l'�dition */
    RUN HTML_DebutEdition (sTitre).
    
    /* Ecriture du titre */
    RUN HTML_Ligne (HTML_DonneTaille(sTitre, 2), "><").
END PROCEDURE.

PROCEDURE HTML_DebutTableau:
/* ------------------------------------------------------------------------------------------
   Proc�dure de d�finition d'un tableau + ecriture entete tableau
   Entr�e : entetes des colonnes
   ------------------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER sLigne AS CHARACTER NO-UNDO.
    
    RUN HTML_Ligne ("<table border=""1"" " + HTML_DonneAlignement("<") + ">","").
    RUN HTML_LigneEnteteTableau (sLigne).
END PROCEDURE.

PROCEDURE HTML_LigneEnteteTableau:
/* ------------------------------------------------------------------------------------------
   Proc�dure d'ecriture de l'entete d'un tableau
   Entr�e : entetes des colonnes
   ------------------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER sLigne AS CHARACTER NO-UNDO.

    DEFINE VARIABLE iBoucle AS INTEGER NO-UNDO.
    DEFINE VARIABLE sColonne    AS CHARACTER NO-UNDO.
    
    RUN HTML_Ligne ("<tr>","").
    
    /* Balayage des colonnes */
    DO iBoucle = 1 To NUM-ENTRIES(sLigne, devSeparateurEdition):
        sColonne = ENTRY(iBoucle, sLigne, devSeparateurEdition).
        RUN HTML_Ligne ("<td " + HTML_DonneFormatCellule("E", iBoucle) + ">" + HTML_DonneTailleCellule("E", iBoucle, (IF Trim(sColonne) <> "" THEN sColonne ELSE devBlancPourEdition)) + "</td>","").
    END.
    
    RUN HTML_Ligne ("</tr>","").
END PROCEDURE.

PROCEDURE HTML_LigneTableau:
/* ------------------------------------------------------------------------------------------
   Proc�dure d'ecriture d'une ligne d'un tableau
   Entr�e : valeurs des colonnes
   ------------------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER sLigne AS CHARACTER NO-UNDO.

    DEFINE VARIABLE iBoucle AS INTEGER NO-UNDO.
    DEFINE VARIABLE sColonne    AS CHARACTER NO-UNDO.
    
    RUN HTML_Ligne ("<tr>","").
    
    /* Balayage des colonnes */
    DO iBoucle = 1 To NUM-ENTRIES(sLigne, devSeparateurEdition):
        sColonne = ENTRY(iBoucle, sLigne, devSeparateurEdition).
        RUN HTML_Ligne ("<td " + HTML_DonneFormatCellule("L", iBoucle) + ">" + HTML_DonneTailleCellule("L", iBoucle, (IF Trim(sColonne) <> "" THEN sColonne ELSE devBlancPourEdition)) + "</td>","").
    END.
    
    RUN HTML_Ligne ("</tr>","").
END PROCEDURE.

PROCEDURE HTML_FinTableau:
/* ------------------------------------------------------------------------------------------
   Proc�dure d'ecriture de la fin d'un tableau
   ------------------------------------------------------------------------------------------*/
    RUN HTML_Ligne ("</table>","").
END PROCEDURE.

PROCEDURE HTML_Ligne:
/* ------------------------------------------------------------------------------------------
   Proc�dure d'ecriture d'une ligne normale
   Entr�e : valeurs de la ligne, son alignement
   ------------------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER sLigne AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER sModeTexte AS CHARACTER NO-UNDO.

    DEFINE VARIABLE sAlignement AS CHARACTER NO-UNDO.
    
    /* D�codage de l'alignement */
    sAlignement = HTML_DonneAlignement(sModeTexte).
    
    /* Ecriture de la ligne en fonction des balises d�j� pr�sentes */
    If sAlignement <> "" THEN DO:
        If NUM-ENTRIES(sLigne, ">") < 2 THEN DO:
            PUT STREAM  HTML_stEdi UNFORMATTED "<p " + sAlignement + ">" + sLigne + "</p>" SKIP.
        END.
        ELSE DO:
            PUT STREAM  HTML_stEdi UNFORMATTED REPLACE( sLigne,ENTRY(1, sLigne, ">"), ENTRY(1, sLigne, ">") + sAlignement) SKIP.
        END.
    END.
    ELSE DO:
        PUT STREAM  HTML_stEdi UNFORMATTED sLigne SKIP.
    END.
END PROCEDURE.

PROCEDURE HTML_LigneBlanche:
/* ------------------------------------------------------------------------------------------
   Proc�dure d'ecriture d'une ligne blanche
   ------------------------------------------------------------------------------------------*/
    RUN HTML_Ligne ("<hr>","").
END PROCEDURE.

PROCEDURE HTML_FinEdition:
/* ------------------------------------------------------------------------------------------
   Proc�dure d'ecriture de la fin de l'�dition
   ------------------------------------------------------------------------------------------*/
    RUN HTML_Ligne ("</body></html>","").
END PROCEDURE.

PROCEDURE HTML_FermeFichier:
/* ------------------------------------------------------------------------------------------
   Proc�dure de fermeture du fichier d'�dition
   ------------------------------------------------------------------------------------------*/
    OUTPUT STREAM HTML_stEdi CLOSE.
END PROCEDURE.

PROCEDURE HTML_AfficheFichier:
/* ------------------------------------------------------------------------------------------
   Proc�dure d'affichage du fichier d'�dition avec le navigateur par d�faut de windows
   ------------------------------------------------------------------------------------------*/
    DEFINE VARIABLE hInstance     AS INTEGER   NO-UNDO.
    RUN ShellExecuteA(INT(CURRENT-WINDOW:HANDLE), "open", HTML_sFichier, "", "", 3, OUTPUT hInstance).
END PROCEDURE.

PROCEDURE HTML_AfficheFichierAvecWord:
/* ------------------------------------------------------------------------------------------
   Proc�dure d'affichage du fichier d'�dition avec Word
   ------------------------------------------------------------------------------------------*/
    DEFINE VARIABLE hInstance     AS INTEGER   NO-UNDO.
    OS-COPY VALUE(HTML_sFichier) VALUE(HTML_sFichier + ".doc").
    /*OS-COMMAND NO-WAIT /*SILENT*/ VALUE(HTML_sFichier + ".doc").*/
    RUN ShellExecuteA(INT(CURRENT-WINDOW:HANDLE), "open", HTML_sFichier + ".doc", "", "", 3, OUTPUT hInstance).
END PROCEDURE.

PROCEDURE HTML_EditeFichierTableau:
/* ------------------------------------------------------------------------------------------
   Proc�dure d'�dition d'un fichier au format tableau
   Entr�e : Le nom du fichier � �diter, le s�parateur des champs du fichier
   ------------------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER sFichierEnEntree AS CHARACTER    NO-UNDO.
DEFINE INPUT PARAMETER sSeparateur AS CHARACTER    NO-UNDO.

    DEFINE VARIABLE sLigne AS CHARACTER NO-UNDO.

    /* Ouverture du fichier en entr�e */
    INPUT STREAM HTML_stEnt FROM VALUE(sFichierEnEntree).
    
    /* Edition */
    RUN HTML_OuvreFichier("").
    RUN HTML_TitreEdition(sFichierEnEntree).
    RUN HTML_DebutTableau("").
    REPEAT:
        IMPORT STREAM HTML_stEnt UNFORMATTED sLigne.
        sLigne = REPLACE(sLigne,sSeparateur,devSeparateurEdition).
        RUN HTML_LigneTableau(sLigne).
    END.
    
    RUN HTML_FinTableau.
    RUN HTML_FinEdition.
    RUN HTML_FermeFichier.
    INPUT STREAM HTML_stEnt CLOSE.
    RUN HTML_AfficheFichier.
    

END PROCEDURE.

PROCEDURE HTML_EditeFichier:
/* ------------------------------------------------------------------------------------------
   Proc�dure d'�dition d'un fichier 
   Entr�e : Le nom du fichier � �diter
   ------------------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER sFichierEnEntree AS CHARACTER    NO-UNDO.
DEFINE INPUT PARAMETER cTitre AS CHARACTER    NO-UNDO.

    DEFINE VARIABLE sLigne AS CHARACTER NO-UNDO.

    /* Ouverture du fichier en entr�e */
    INPUT STREAM HTML_stEnt FROM VALUE(sFichierEnEntree).
    
    /* Edition */
    RUN HTML_OuvreFichier("").
    RUN HTML_TitreEdition((IF cTitre <> "" THEN cTitre ELSE sFichierEnEntree)).
    REPEAT:
        IMPORT STREAM HTML_stEnt UNFORMATTED sLigne.
        RUN HTML_Ligne(sLigne,"<").
    END.
    
    RUN HTML_FinEdition.
    RUN HTML_FermeFichier.
    INPUT STREAM HTML_stEnt CLOSE.
    RUN HTML_AfficheFichier.
    

END PROCEDURE.

PROCEDURE HTML_EditeFichierAvecWord:
/* ------------------------------------------------------------------------------------------
   Proc�dure d'�dition d'un fichier 
   Entr�e : Le nom du fichier � �diter
   ------------------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER sFichierEnEntree AS CHARACTER    NO-UNDO.
DEFINE INPUT PARAMETER cTitre AS CHARACTER    NO-UNDO.

    DEFINE VARIABLE sLigne AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichierTempo AS CHARACTER NO-UNDO.
    
    /* Ouverture du fichier en entr�e */
    INPUT STREAM HTML_stEnt FROM VALUE(sFichierEnEntree).
    RUN HTML_OuvreFichier("").
    RUN HTML_TitreEdition((IF cTitre <> "" THEN cTitre ELSE sFichierEnEntree)).
    REPEAT:
        IMPORT STREAM HTML_stEnt UNFORMATTED sLigne.
        RUN HTML_Ligne(sLigne,"<").
    END.
    
    RUN HTML_FinEdition.
    RUN HTML_FermeFichier.
    INPUT STREAM HTML_stEnt CLOSE.

    /* Ouverture du fichier en entr�e */
    RUN HTML_AfficheFichierAvecWord.
    
END PROCEDURE.
