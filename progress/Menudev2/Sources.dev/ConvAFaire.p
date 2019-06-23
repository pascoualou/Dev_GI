/* Reprise des listes et actions de l'ancienne version des "A Faire" */

/* ------------------------ ENVIRONNEMENT -----------------------------*/

{includes\i_environnement.i}
{includes\i_dialogue.i}
{includes\i_fichier.i}
{menudev2\includes\menudev2.i}
{ prodict/user/uservar.i NEW }
{ prodict/dictvar.i NEW }

FUNCTION DonneNomCompletFichier RETURNS CHARACTER  ( cAction-in AS CHARACTER ) FORWARD.

    DEFINE INPUT PARAMETER  cUtilisateur-in AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER  lMuet-in AS LOGICAL NO-UNDO.

/* ----------------------------- VARIABLES --------------------------- */

    DEFINE VARIABLE iNumeroListeEncours AS INTEGER NO-UNDO.
    DEFINE VARIABLE iOrdreListeEncours AS INTEGER NO-UNDO.
    DEFINE VARIABLE iNumeroActionEncours AS INTEGER NO-UNDO.
    DEFINE VARIABLE iOrdreActionEncours AS INTEGER NO-UNDO.
    DEFINE VARIABLE cFichierCommentaire AS CHARACTER NO-UNDO.

    DEFINE BUFFER lmemo FOR memo.
    DEFINE BUFFER amemo FOR memo.
    DEFINE BUFFER pmemo FOR memo.

/* -------------------------------- MAIN -------------------------------- */

    IF DonnePreferenceUtilisateur(cUtilisateur-in,"PREF-AFAIRE-CONVERSION-FAITE") = "OUI" THEN DO:
        MESSAGE "Attention, les listes et actions saisie au nouveau format depuis la conversion précédente pour cet utilisateur seront supprimées !"
            + CHR(10) + "Confirmez-vous la conversion ?"
            VIEW-AS ALERT-BOX QUESTION
            UPDATE lReponse1 AS LOGICAL.
        IF NOT(lReponse1) THEN RETURN.
    END.

    /* Suppression de l'existant */
    FOR EACH    AFaire_Liste
        WHERE   AFaire_Liste.cUtilisateur = cUtilisateur-in
        :
        DELETE AFaire_Liste.
    END.
    FOR EACH    AFaire_Action
        WHERE   AFaire_Action.cUtilisateur = cUtilisateur-in
        :
        DELETE AFaire_Action.
    END.
    FOR EACH    AFaire_Lien
        WHERE   AFaire_Lien.cUtilisateur = cUtilisateur-in
        :
        DELETE AFaire_Lien.
    END.
    FOR EACH    AFaire_PJ
        WHERE   AFaire_PJ.cUtilisateur = cUtilisateur-in
        :
        DELETE AFaire_PJ.
    END.
    FOR EACH    AFaire_Projet
        WHERE   AFaire_Projet.cUtilisateur = cUtilisateur-in
        :
        DELETE AFaire_Projet.
    END.
       
    /* Chargement des listes */
    iOrdreListeEncours = 0.
    FOR EACH    lmemo NO-LOCK
        WHERE   lmemo.cUtilisateur = cUtilisateur-in
        AND     lmemo.filler = "LISTE"
        BY SUBSTRING(lmemo.cValeur,1,32)
        :
        
        /* Recherche de la prochaine liste disponible */
        iNumeroListeEncours = 1.
        FIND LAST   AFaire_Liste NO-LOCK 
            WHERE   AFaire_Liste.cUtilisateur = cUtilisateur-in
            NO-ERROR. 
        IF AVAILABLE(AFaire_Liste) THEN iNumeroListeEncours = AFaire_Liste.iNumeroListe + 1.
        
        CREATE AFaire_Liste.
        iOrdreListeEncours = iOrdreListeEncours + 1.
        AFaire_Liste.cUtilisateur = cUtilisateur-in.
        AFaire_Liste.iNumeroListe = iNumeroListeEncours.
        AFaire_Liste.iOrdreListe = iOrdreListeEncours.
        AFaire_Liste.cLibelleListe = lmemo.cValeur.
        
        /* Projet */
        IF lmemo.lbdiv <> "" THEN DO:
            CREATE AFaire_Projet.
            AFaire_Projet.cUtilisateur = cUtilisateur-in.
            AFaire_Projet.cNomProjet = lmemo.lbdiv.
        END.
        
        /* Chargement des actions */
        iOrdreActionEncours = 0.
        FOR EACH    amemo NO-LOCK
            WHERE   amemo.cUtilisateur = cUtilisateur-in
            AND     amemo.filler = "LISTE-" + lmemo.cType
            BY amemo.iordre
            :
            /* Recherche de la prochaine action disponible */
            iNumeroActionEncours = 1.
            FIND LAST   AFaire_Action NO-LOCK 
                WHERE   AFaire_Action.cUtilisateur = cUtilisateur-in
                NO-ERROR. 
            IF AVAILABLE(AFaire_Action) THEN iNumeroActionEncours = AFaire_Action.iNumeroAction + 1.
        
            CREATE AFaire_Action.
            iOrdreActionEncours = iOrdreActionEncours + 1.
            AFaire_Action.cUtilisateur = cUtilisateur-in.
            AFaire_Action.iNumeroAction = iNumeroActionEncours.
            AFaire_Action.cLibelleAction = amemo.cValeur.
            AFaire_Action.lRappelHoraire = amemo.lAlerte.
            AFaire_Action.cEtatAction = amemo.cetat.
            
            /* Creation du lien liste-action */
            CREATE AFaire_Lien.
            AFaire_Lien.cUtilisateur = cUtilisateur-in.
            AFaire_Lien.iNumeroListe = iNumeroListeEncours.
            AFaire_Lien.iNumeroAction = iNumeroActionEncours.
            AFaire_Lien.iOrdreLien = iOrdreActionEncours.
            
            cFichierCommentaire = DonneNomCompletFichier(amemo.cValeur).
            
            /* Gestion des PJ */
            FOR EACH    pmemo NO-LOCK
                WHERE   pmemo.cUtilisateur = cUtilisateur-in
                AND     pmemo.filler BEGINS "LISTE-FICHIERS#" + lmemo.cType + "#" + amemo.ctype
                :
                CREATE AFaire_PJ.
                AFaire_PJ.cUtilisateur = cUtilisateur-in.
                AFaire_PJ.iNumeroAction = iNumeroActionEncours.
                AFaire_PJ.cNomPJ = pmemo.cValeur.
                AFaire_PJ.lRepertoire = ((num-entries(pmemo.filler,"#") > 3 AND ENTRY(4,pmemo.filler,"#") = "R")).
                AFaire_PJ.lCommentaireAction = (cFichierCommentaire = pmemo.cValeur).
            END.
        END.
        
    END.
    SauvePreference("PREF-AFAIRE-CONVERSION-FAITE","OUI").
    IF NOT(lMuet-in) THEN MESSAGE "Conversion au nouveau format Terminée" VIEW-AS ALERT-BOX INFORMATION.
    
    
    
FUNCTION DonneNomCompletFichier RETURNS CHARACTER  ( cAction-in AS CHARACTER ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.

    cTempo = REPLACE(cAction-in,"~"","'"). 
    DO iBoucle = 1 TO LENGTH(gcCaracteresInterdits):
        cTempo = REPLACE(cTempo,SUBSTRING(gcCaracteresInterdits,iBoucle,1),"_").
    END.
    cRetour = DonnePreference("PREF-REPERTOIRE-COMMENTAIRES") + "\C_" + cTempo + ".doc".


  RETURN cRetour.   /* Function return value. */

END FUNCTION.

