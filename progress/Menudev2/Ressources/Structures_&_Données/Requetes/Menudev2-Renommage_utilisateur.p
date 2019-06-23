/* Moulinette de changement de nom d'un utilisateur de menudev2 */

/* Requête générée par menudev2 */
CURRENT-WINDOW:WIDTH = 300.

DEFINE VARIABLE cAncienNom AS CHARACTER NO-UNDO.
DEFINE VARIABLE cNouveauNom AS CHARACTER NO-UNDO.
DEFINE VARIABLE lNouveau AS LOGICAL NO-UNDO.

cAncienNom = "PPL".
cNouveauNom = "PPL.DEV".
lNouveau = FALSE.

FOR EACH    ALARMES
    :
    IF ALARMES.cUtilisateur  = cAncienNom THEN ALARMES.cUtilisateur  = cNouveauNom.
    IF alarmes.cIdentAlarme BEGINS cAncienNom + "-" THEN alarmes.cIdentAlarme = REPLACE(alarmes.cIdentAlarme,cAncienNom + "-",cNouveauNom + "-").
    IF alarmes.cIdent BEGINS cAncienNom + "-" THEN alarmes.cIdent = REPLACE(alarmes.cIdent,cAncienNom + "-",cNouveauNom + "-").
END.

FOR EACH    detail
    :
    IF detail.iddet1  = cAncienNom THEN detail.iddet1  = cNouveauNom.
    IF detail.iddet1 BEGINS cAncienNom + "|" THEN detail.iddet1 = REPLACE(detail.iddet1,cAncienNom + "|",cNouveauNom + "|").
END.

FOR EACH    FICHIERS
    :
    IF FICHIERS.cUtilisateur  = cAncienNom THEN FICHIERS.cUtilisateur  = cNouveauNom.
    IF FICHIERS.cModifieur  = cAncienNom THEN FICHIERS.cModifieur  = cNouveauNom.
    IF FICHIERS.cCreateur BEGINS cAncienNom + "-" THEN FICHIERS.cCreateur = REPLACE(FICHIERS.cCreateur,cAncienNom + "-",cNouveauNom + "-").
    IF FICHIERS.idcreation MATCHES "*-" + cAncienNom THEN FICHIERS.idcreation = REPLACE(FICHIERS.idcreation,"-" + cAncienNom,"-" + cNouveauNom).
END.

FOR EACH    JOURNAL
    WHERE   JOURNAL.cUtilisateur   = cAncienNom
    :
    JOURNAL.cUtilisateur   = cNouveauNom.
END.

FOR EACH    MEMO
    WHERE   MEMO.cUtilisateur   = cAncienNom
    :
    MEMO.cUtilisateur   = cNouveauNom.
END.

FOR EACH    ABSENCES
    WHERE   ABSENCES.cUtilisateur = cAncienNom
    :
    ABSENCES.cUtilisateur = cNouveauNom.
END.

FOR EACH    activite
    WHERE   activite.cUtilisateur = cAncienNom
    :
    activite.cUtilisateur = cNouveauNom.
END.

FOR EACH    AFAIRE_ACTION
    WHERE   AFAIRE_ACTION.cUtilisateur = cAncienNom
    :
    AFAIRE_ACTION.cUtilisateur = cNouveauNom.
END.

FOR EACH    AFAIRE_LIEN
    WHERE   AFAIRE_LIEN.cUtilisateur = cAncienNom
    :
    AFAIRE_LIEN.cUtilisateur = cNouveauNom.
END.

FOR EACH    AFAIRE_LISTE
    WHERE   AFAIRE_LISTE.cUtilisateur  = cAncienNom
    :
    AFAIRE_LISTE.cUtilisateur  = cNouveauNom.
END.

FOR EACH    AFAIRE_PJ
    WHERE   AFAIRE_PJ.cUtilisateur  = cAncienNom
    :
    AFAIRE_PJ.cUtilisateur  = cNouveauNom.
END.

FOR EACH    AFAIRE_PROJET
    WHERE   AFAIRE_PROJET.cUtilisateur  = cAncienNom
    :
    AFAIRE_PROJET.cUtilisateur  = cNouveauNom.
END.

FOR EACH    AGENDA
    :
    IF AGENDA.cUtilisateur  = cAncienNom THEN AGENDA.cUtilisateur  = cNouveauNom.
    IF AGENDA.cident BEGINS cAncienNom + "-" THEN AGENDA.cident = REPLACE(AGENDA.cident,cAncienNom + "-",cNouveauNom + "-").
END.


/* A NE FAIRE QUE S'IL S'AGIT D'UN NOUVEAU NOM. SI LE NOM EXISTE DéJà IL RISQUE D'Y AVOIR DOUBLON OU PB D'INDEX */
IF lNouveau THEN DO:
    
    FOR EACH    UTILISATEURS
        WHERE   UTILISATEURS.cUtilisateur    = cAncienNom
        :
        UTILISATEURS.cUtilisateur    = cNouveauNom.
    END.

    FOR EACH    ORDRES
        :
        IF ORDRES.cUtilisateur  = cAncienNom THEN ORDRES.cUtilisateur  = cNouveauNom.
        IF ORDRES.filler  = cAncienNom THEN ORDRES.filler  = cNouveauNom.
    END.

    FOR EACH    PREFS
        :
    IF PREFS.cUtilisateur  = cAncienNom THEN PREFS.cUtilisateur  = cNouveauNom.
    IF PREFS.cCode MATCHES "*-" + cAncienNom + "-*" THEN PREFS.cCode = REPLACE(PREFS.cCode,"-" + cAncienNom + "-","-" + cNouveauNom + "-").
    END.

END.
