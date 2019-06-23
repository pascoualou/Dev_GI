/*--------------------------------------------------------------------------*
| Programme        : i_fichier.i                                            |
| Objet            : procedures et fonctions sur les fichiers               |
|---------------------------------------------------------------------------|
| Date de création : 21/03/2008                                             |
| Auteur(s)        : PL                                                     |
*---------------------------------------------------------------------------*
*---------------------------------------------------------------------------*
| Historique des modifications                                              |
|---------------------------------------------------------------------------|
|  Nø  |    Date    | Auteur |                  Objet                       |
|------+------------+--------+----------------------------------------------|
| .... | ../../.... |  ....  | .                                            |
|      |            |        |                                              |
*--------------------------------------------------------------------------*/

/* ----------------------------------------------------------------------- 
    Procédure de copie d'un fichier 
   ----------------------------------------------------------------------- */
PROCEDURE CopieFichier:
    DEFINE INPUT PARAMETER cCheminSource       AS CHARACTER    NO-UNDO.
    DEFINE INPUT PARAMETER cCheminDestination  AS CHARACTER    NO-UNDO.
    
    IF SEARCH(cCheminSource) <> ? THEN
    DO:
        OUTPUT TO VALUE(OS-GETENV("DEVTMP") + "\Commande.bat").
        PUT UNFORMATTED SKIP "COPY ~"" cCheminSource "~" ~"" cCheminDestination "~"".
        PUT UNFORMATTED SKIP "EXIT".
        OUTPUT CLOSE.
        OS-COMMAND SILENT VALUE(OS-GETENV("DEVTMP") + "\Commande.bat").
    END.
END.

/* ----------------------------------------------------------------------- 
    Procédure de suppression d'un fichier 
   ----------------------------------------------------------------------- */
PROCEDURE SupprimeFichier:
    DEFINE INPUT PARAMETER cCheminSource       AS CHARACTER    NO-UNDO.
    
    IF SEARCH(cCheminSource) <> ? OR ENTRY(1,ENTRY(NUM-ENTRIES(cCheminSource,"\"),cCheminSource,"\"),".") = "*" THEN
    DO:
        OUTPUT TO VALUE(OS-GETENV("DEVTMP") + "\Commande.bat").
        PUT UNFORMATTED SKIP "DEL ~"" cCheminSource "~"".
        PUT UNFORMATTED SKIP "EXIT".
        OUTPUT CLOSE.
        OS-COMMAND SILENT VALUE(OS-GETENV("DEVTMP") + "\Commande.bat").
    END.
END.

/* ----------------------------------------------------------------------- 
    Procédure de Formattage d'une taille disque ou fichier donnée en octets
   ----------------------------------------------------------------------- */
FUNCTION FormatteTaille RETURNS CHARACTER(iTaille AS INT64):
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.
    
    IF iTaille >= 1000000000000 THEN DO:
        cRetour = STRING(iTaille / 1000000000000,">>9.999") + " To".        
    END.
    ELSE IF iTaille >= 1000000000 THEN DO:
        cRetour = STRING(iTaille / 1000000000,">>9.999") + " Go".        
    END.
    ELSE IF iTaille >= 1000000 THEN DO:
        cRetour = STRING(iTaille / 1000000,">>9.999") + " Mo".        
    END.
    ELSE IF iTaille >= 1000 THEN DO:
        cRetour = STRING(iTaille / 1000,">>9.999") + " Ko".        
    END.
    ELSE DO:
        cRetour = STRING(iTaille ,">>9.999") + " O".        
    END.
    
    RETURN cRetour.
    
END FUNCTION.

FUNCTION DonneErreurSysteme RETURNS CHARACTER(iNumeroErreur-in AS INTEGER):

    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO INIT "".

    CASE iNumeroErreur-in:
        WHEN 1 THEN cRetour = "Not owner".
        WHEN 2 THEN cRetour = "No such file or directory".
        WHEN 3 THEN cRetour = "Interrupted system call".
        WHEN 4 THEN cRetour = "I/O error".
        WHEN 5 THEN cRetour = "Bad file number".
        WHEN 6 THEN cRetour = "No more processes". 
        WHEN 7 THEN cRetour = "Not enough core memory".
        WHEN 8 THEN cRetour = "Permission denied". 
        WHEN 9 THEN cRetour = "Bad address". 
        WHEN 10 THEN cRetour = "File exists". 
        WHEN 11 THEN cRetour = "No such device". 
        WHEN 12 THEN cRetour = "Not a directory". 
        WHEN 13 THEN cRetour = "Is a directory".
        WHEN 14 THEN cRetour = "File table overflow".
        WHEN 15 THEN cRetour = "Too many open files". 
        WHEN 16 THEN cRetour = "File too large".
        WHEN 17 THEN cRetour = "No space left on device". 
        WHEN 18 THEN cRetour = "Directory not empty".
        WHEN 999 THEN cRetour = "Unmapped error (ABL default)". 
    END CASE.

    IF cRetour <> ""  THEN cRetour = "Erreur : " + STRING(iNumeroErreur-in,"999") + " - " + cRetour.

    RETURN(cRetour).

END FUNCTION.

FUNCTION CreChemin RETURNS CHARACTER (cChemin-IN AS CHARACTER,lMuet-IN AS LOGICAL):

	DEFINE VARIABLE cCheminPartiel  AS CHARACTER    NO-UNDO.  	
    DEFINE VARIABLE cRetour         AS CHARACTER    NO-UNDO INIT "".
    DEFINE VARIABLE ierreur         AS INTEGER      NO-UNDO INIT 0.
	DEFINE VARIABLE iBoucle         AS INTEGER      NO-UNDO.
	DEFINE VARIABLE cCarRepOS       AS CHARACTER    NO-UNDO INIT "\".
	
	IF OPSYS = "WIN32" THEN DO:
	    cCarRepOs = "\".
	END.
	ELSE DO:
	    cCarRepOs = "/".
	END.
	
	/* Parcours du chemin passé en parametre pour création */
	DO iBoucle = 1 TO NUM-ENTRIES(cChemin-IN,cCarRepOs):
        
        /* Composition du chemin partiel */
        cCheminPartiel = cCheminPartiel 
            + (IF cCheminPartiel <> "" THEN cCarRepOs ELSE "")
            + ENTRY(iBoucle,cChemin-IN,cCarRepOs).
        
        /* Si 1 ere entrée, on considère qu'il s'agit du disque */
        IF iBoucle = 1 THEN NEXT.
        
        /* Il faut avoir le premier / pour unix */
        IF NOT(OPSYS = "WIN32") AND NOT(cCheminPartiel BEGINS cCarRepOs) THEN 
            cCheminPartiel = cCarRepOs + cCheminPartiel.
        
        /* Sinon on crée l'arborescence */
        OS-CREATE-DIR VALUE(cCheminPartiel).
        ierreur = OS-ERROR.
        
        IF ierreur NE 0 THEN DO:
            cRetour = cRetour + CHR(10) + "Erreur système n°: " + STRING(ierreur) + " lors de la création du répertoire : " + cCheminPartiel.                
        END.
	END.

    /* Message si demandé */
    IF cRetour <> "" AND NOT(lMuet-IN) THEN DO:
        MESSAGE "Création de répertoires : " + cRetour
            VIEW-AS ALERT-BOX ERROR
            TITLE "CreChemin : Erreur...".
    END.
	  
	RETURN cRetour.
        
END FUNCTION.
 
/* Donne le chemin d'un fichier en fonction de l'OS utilisé (Dos/Linux) */
FUNCTION fctsyste_DonneCheminOS RETURNS CHARACTER(cChemin-in AS CHARACTER):
    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.
    
    IF OPSYS = "WIN32" THEN 
        cRetour = REPLACE(cChemin-in,"/","\").
    ELSE    
        cRetour = REPLACE(cChemin-in,"\","/").

    RETURN cRetour.
    
END FUNCTION.  
    