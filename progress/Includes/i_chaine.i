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
/* -------------------------------------------------------------------------
   Centre une chaine de caractères en fonction de la taille du champs 
   ----------------------------------------------------------------------- */
FUNCTION CentreChaine RETURNS CHARACTER(cChaine AS CHARACTER, iLongueur AS INTEGER):
    DEFINE VARIABLE cRetour AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE iVide1  AS INTEGER      NO-UNDO.
    DEFINE VARIABLE iVide2  AS INTEGER      NO-UNDO.
    DEFINE VARIABLE iTaille AS INTEGER      NO-UNDO.
    
    iTaille = LENGTH(cChaine,"CHARACTER").
    
    /* Le Cadre est vide*/
    IF iLongueur = 0 THEN Message "Erreur : le cadre est égal à 0.".
        
    /* La chaine est plus grande que le cadre*/
    IF iTaille > iLongueur THEN DO:
        cRetour = SUBSTRING(cChaine,1,iLongueur,"CHARACTER").
    END.
    ELSE DO:
        /* La Chaine est vide*/
        IF iTaille = 0 THEN DO:
            cRetour = FILL(" ",iLongueur).
        END.
        ELSE DO:
            iVide1 = (iLongueur / 2) - (iTaille / 2).
            iVide2 = IF (2 * iVide1) + iTaille <> iLongueur THEN iVide1 - 1 ELSE iVide1.
            cRetour = FILL(" ",iVide1) + cChaine + FILL(" ",iVide2).
        END.
    END.
    
    RETURN cRetour.
END.

/* -------------------------------------------------------------------------
   Formate une chaine de caractères à une certaine valeur
   ----------------------------------------------------------------------- */
FUNCTION FormateChaine RETURNS CHARACTER(INPUT cChaine AS CHARACTER, INPUT iLongueur AS INTEGER):
    DEFINE VARIABLE cRetour AS CHARACTER    NO-UNDO.
    
    cRetour = STRING(cChaine,"X(" + STRING(iLongueur) + ")").
    
    RETURN cRetour.
END.

/* -------------------------------------------------------------------------
   Ajoute une chaine à une autre ssi la chaine à ajouter n'est pas vide
   ----------------------------------------------------------------------- */
FUNCTION AjouteSiNonVide RETURNS CHARACTER(INPUT cChaineAAjouter AS CHARACTER,INPUT cChaineOrigine AS CHARACTER,INPUT cLibelle AS CHARACTER):

    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.
    
    /* Par défaut, le retour = l'origine */
    cRetour = cChaineOrigine.
    
    IF cChaineAAjouter <> "" AND cChaineAAjouter <> ? THEN DO:
        cRetour = cChaineOrigine + cLibelle + cChaineAAjouter.
    END.
    
    /* Gestion du retour */
    RETURN cRetour.

END FUNCTION.

/* -------------------------------------------------------------------------
   Ajoute une chaine à une autre ssi la chaine à ajouter n'est pas à Zero
   ----------------------------------------------------------------------- */
FUNCTION AjouteSiNonZero RETURNS CHARACTER(INPUT cChaineAAjouter AS CHARACTER,INPUT cChaineOrigine AS CHARACTER,INPUT cLibelle AS CHARACTER):

    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.
    
    /* Par défaut, le retour = l'origine */
    cRetour = cChaineOrigine.
    
    IF cChaineAAjouter <> ? AND dec(cChaineAAjouter) <> 0 THEN DO:
        cRetour = cChaineOrigine + cLibelle + cChaineAAjouter.
    END.
    
    /* Gestion du retour */
    RETURN cRetour.

END FUNCTION.
