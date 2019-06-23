/*---------------------------------------------------------------------------
 Application      : MENUDEV2
 Programme        : CreFichierInfos.p
 Objet            : Création des fichiers _infos.md2
*---------------------------------------------------------------------------
 Date de création : 07/10/2018
 Auteur(s)        : PL
 Dossier analyse  : 
*---------------------------------------------------------------------------
 Entrée :
 Sortie :
 Appel  :
*---------------------------------------------------------------------------
 Modifications :
 ....   ../../....    ....  

*--------------------------------------------------------------------------*/

{includes\i_environnement.i NEW}
{menudev2\includes\menudev2.i NEW}

/*-------------------------------------------------------------------------*
 | DEFINITIONS                                                             |
 *-------------------------------------------------------------------------*/

DEFINE INPUT PARAMETER cUtil-in AS CHARACTER NO-UNDO.

DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO.
DEFINE VARIABLE cRepertoireBases AS CHARACTER NO-UNDO.
DEFINE VARIABLE cFichierBases AS CHARACTER NO-UNDO.

DEFINE VARIABLE cVersion AS CHARACTER NO-UNDO.
DEFINE VARIABLE cDate AS CHARACTER NO-UNDO.
DEFINE VARIABLE cTypeVersion AS CHARACTER NO-UNDO.
DEFINE VARIABLE cProgress AS CHARACTER NO-UNDO.
DEFINE VARIABLE cCommentaire AS CHARACTER NO-UNDO.
DEFINE VARIABLE cAuto AS CHARACTER NO-UNDO.

DEFINE STREAM sListe.
DEFINE STREAM sEntree.
DEFINE STREAM sSortie.

/*-------------------------------------------------------------------------*
 | MAIN BLOCK                                                              |
 *-------------------------------------------------------------------------*/
 
    /* Récupération du répertoire des bases de l'utilisateur */
    gcUtilisateur = cUtil-in.
    cFichierBases = loc_tmp + "\bases.lst".
    cRepertoireBases = DonnePreference("REPERTOIRE-BASES").
    IF cRepertoireBases = "" THEN RETURN.
    OS-COMMAND SILENT VALUE("dir /b /a:d " + cRepertoireBases + " > " + cFichierBases).
    
    /* Ouverture du fichier */
    INPUT STREAM sListe FROM VALUE(loc_tmp + "\bases.lst").

    REPEAT:
        IMPORT STREAM sListe UNFORMATTED cLigne.
        IF cLigne = "" OR cLigne = "00000" THEN NEXT.
        
        /* Récupération de la version */
        RUN LitFichier("_Version.txt", cLigne, OUTPUT cVersion).
        RUN LitFichier("_date.txt", cLigne, OUTPUT cDate).
        RUN LitFichier("_repertoire.txt", cLigne, OUTPUT ctypeVersion).
        RUN LitFichier("_Progress.txt", cLigne, OUTPUT cProgress).
        RUN LitFichier("_Commentaire.txt", cLigne, OUTPUT cCommentaire).
        cAuto = (IF SEARCH(cRepertoireBases + "\" + cLigne + "\" + "_Auto.txt") <> ? THEN "OUI" ELSE "NON").
        
        RUN EcritFichier(cLigne).
    END.

    /* Fermeture du fichier */
    INPUT STREAM sListe CLOSE.
    
    SauvePreference("PREFS-BASES-FICHIERS-NOUVELLE-GESTION","OUI").
    
PROCEDURE LitFichier:
    DEFINE INPUT PARAMETER cFichier-in AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER cReference-in AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER cValeur-ou AS CHARACTER NO-UNDO.
    
    DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFichierALire AS CHARACTER NO-UNDO.

    cFichierALire = cRepertoireBases + "\" + cReference-in + "\" + cFichier-in.
    
    IF SEARCH(cFichierALire) <> ? THEN DO:
        INPUT STREAM sEntree FROM VALUE(cFichierALire).
        REPEAT:
            IMPORT STREAM sEntree UNFORMATTED cLigne.
            IF cLigne = "" THEN NEXT.
            cValeur-ou = cLigne.
        END.
        INPUT STREAM sEntree CLOSE.
    END.
        
END PROCEDURE.
    
PROCEDURE EcritFichier:
    DEFINE INPUT PARAMETER cReference-in AS CHARACTER NO-UNDO.

    /* Génération du fichier complet */
    OUTPUT STREAM sSortie TO VALUE(cRepertoireBases + "\" + cReference-in + "\_infos.mdev2").
    
    PUT STREAM sSortie UNFORMATTED "Version=" + cVersion SKIP.
    PUT STREAM sSortie UNFORMATTED "Date=" + cDate SKIP.
    PUT STREAM sSortie UNFORMATTED "TypeVersion=" + ctypeVersion SKIP.
    PUT STREAM sSortie UNFORMATTED "VersionProgress=" + cProgress SKIP.
    PUT STREAM sSortie UNFORMATTED "Commentaire=" + cCommentaire SKIP.
    PUT STREAM sSortie UNFORMATTED "Auto=" + cAuto SKIP.
    
    OUTPUT STREAM sSortie CLOSE.

END PROCEDURE.
    
PROCEDURE Forcage:
END PROCEDURE.