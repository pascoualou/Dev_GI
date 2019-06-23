/*--------------------------------------------------------------------------*
| Programme        : i_excel.i                                              |
| Objet            : procedures et fonctions pour l'utilisation de excel    |
|---------------------------------------------------------------------------|
| Date de création : 15/03/2015                                             |
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

DEFINE VARIABLE hApplicationExcel AS COM-HANDLE NO-UNDO.
DEFINE VARIABLE hDocumentExcel AS COM-HANDLE NO-UNDO.
DEFINE VARIABLE hDocumentMaitre AS COM-HANDLE NO-UNDO.
DEFINE VARIABLE hDocumentEsclave AS COM-HANDLE NO-UNDO.
DEFINE VARIABLE cFichierMacros AS CHARACTER NO-UNDO.
DEFINE VARIABLE cFichierSauvegarde AS CHARACTER NO-UNDO.

FUNCTION AfficheMessage RETURNS CHARACTER (cLibelleMessage-in AS CHARACTER) FORWARD.

/* ----------------------------------------------------------------------- 
    Affichage d'un message d'erreur
   ----------------------------------------------------------------------- */
FUNCTION AfficheErreur RETURNS LOGICAL (cEntete-in AS CHARACTER,lErreurSysteme AS LOGICAL):

    DEFINE VARIABLE cMessage AS CHARACTER NO-UNDO INIT "".
    DEFINE VARIABLE iBoucle AS INTEGER NO-UNDO.

    /* Récupération de l'erreur systeme si demandé */
    IF lErreurSysteme THEN DO:
        DO iBoucle = 1 TO ERROR-STATUS:NUM-MESSAGES:
            cMessage = cMessage 
                + (IF cMessage <> "" THEN CHR(10) ELSE "")
                + "Erreur " + string(ERROR-STATUS:GET-NUMBER(iBoucle))
                + " - " + ERROR-STATUS:GET-MESSAGE(iBoucle).
        END.
    END.

    /* Ajout de l'entete du message */
    cMessage = cEntete-in + (IF cMessage <> "" THEN CHR(10) + cMessage ELSE "").

    /* Affichage du message */
    MESSAGE cMessage VIEW-AS ALERT-BOX ERROR TITLE "Contrôle de Excel...".

    /* gestion du retour : toujours false car il s'agit d'une erreur */
    RETURN(FALSE).

END FUNCTION.

/* ----------------------------------------------------------------------- 
    Formattage d'une chaine en remplaçant les sauts de ligne
   ----------------------------------------------------------------------- */
FUNCTION FormatteChaine RETURNS CHARACTER (cChaine-in AS CHARACTER):

    DEFINE VARIABLE cRetour AS CHARACTER NO-UNDO INIT "".

    cRetour = cChaine-in.

    cRetour = REPLACE(cRetour,CHR(10),"%s").
    cRetour = REPLACE(cRetour,","," ; ").

    /* gestion du retour : toujours false car il s'agit d'une erreur */
    RETURN(cRetour).

END FUNCTION.

/* ----------------------------------------------------------------------- 
    fonction de gestion de word 
   ----------------------------------------------------------------------- */
FUNCTION Excel RETURNS LOGICAL (cAction-in AS CHARACTER,cParametres-in AS CHARACTER):

    DEFINE VARIABLE lRetour AS LOGICAL NO-UNDO INIT TRUE.
    DEFINE VARIABLE lCommandeConnue AS LOGICAL INIT FALSE.
    DEFINE VARIABLE iModeFenetre AS INTEGER NO-UNDO.
    DEFINE VARIABLE cTempo AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cNomDocument AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iBoucle AS INTEGER NO-UNDO.
    DEFINE VARIABLE cNomMacro AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cParametres AS CHARACTER NO-UNDO.
    DEFINE VARIABLE tbParametres AS CHARACTER EXTENT 5 NO-UNDO.
    DEFINE VARIABLE iNombreParametres AS INTEGER NO-UNDO.
	
    /* Ouverture de excel */
    IF cAction-in = "OUVRIR" THEN DO:
        lCommandeConnue = TRUE.
        CREATE "excel.Application" hApplicationExcel CONNECT NO-ERROR.
        IF ERROR-STATUS:ERROR THEN DO:
            CREATE "excel.Application" hApplicationExcel NO-ERROR.
            IF ERROR-STATUS:ERROR THEN lRetour = AfficheErreur("Excel (OUVRIR) : Impossible de lancer Excel",TRUE).
            ELSE lRetour = TRUE.
        END.
        ELSE lRetour = TRUE.
    END.
	
    /* Ici les actions ayant besoin d'un Excel actif */
    IF NOT(VALID-HANDLE(hApplicationExcel)) THEN DO:
        lRetour = ?.
    END.
    ELSE DO:

        /* ------------------------------------------------------------------------------------ */

        /* excel au premier plan */
        IF cAction-in = "PREMIER-PLAN" THEN DO:
            lCommandeConnue = TRUE.
            hApplicationExcel:MOVE-TO-TOP() NO-ERROR.        
            IF ERROR-STATUS:ERROR THEN lRetour = AfficheErreur("Excel (PREMIER-PLAN) : Impossible de fermer Excel",TRUE).
        END.

        /* ------------------------------------------------------------------------------------ */

        /* Fermeture de Excel */
        IF cAction-in = "FERMER" THEN DO:
            lCommandeConnue = TRUE.
            hApplicationExcel:QUIT NO-ERROR.        
            IF ERROR-STATUS:ERROR THEN lRetour = AfficheErreur("Excel (FERMER) : Impossible de fermer Excel",TRUE).
            RELEASE OBJECT hApplicationExcel NO-ERROR.
            IF ERROR-STATUS:ERROR THEN lRetour = AfficheErreur("Excel (FERMER/RELEASE OBJECT) : Impossible de supprimer l'objet Excel",TRUE).
        END.

        /* ------------------------------------------------------------------------------------ */

        /* Excel visible */
        IF cAction-in = "VISIBLE" THEN DO:
            lCommandeConnue = TRUE.
            hApplicationExcel:VISIBLE = TRUE NO-ERROR.        
            IF ERROR-STATUS:ERROR THEN lRetour = AfficheErreur("Excel (VISIBLE) : Erreur d'execution !!",TRUE).
        END.

        /* ------------------------------------------------------------------------------------ */

        /* Excel invisible */
        IF cAction-in = "INVISIBLE" THEN DO:
            lCommandeConnue = TRUE.
            hApplicationExcel:VISIBLE = FALSE NO-ERROR.        
            IF ERROR-STATUS:ERROR THEN lRetour = AfficheErreur("Excel (INVISIBLE) : Erreur d'execution !!",TRUE).
        END.

        /* ------------------------------------------------------------------------------------ */

        /* Excel activer */
        IF cAction-in = "ACTIVER" THEN DO:
            lCommandeConnue = TRUE.
            hApplicationExcel:ACTIVATE() NO-ERROR.        
            IF ERROR-STATUS:ERROR THEN lRetour = AfficheErreur("Excel (ACTIVER) : Erreur d'execution !!",TRUE).
        END.

        /* ------------------------------------------------------------------------------------ */

        /* Mode fenetre de Excel (Max/Min/Normal) */
        IF cAction-in = "FENETRE" THEN DO:
            lCommandeConnue = TRUE.
            iModeFenetre = -1.
            cTempo = ENTRY(1,cParametres-in).
            IF cTempo = "NORMAL" THEN iModeFenetre = 1.
            IF cTempo = "MAX" THEN iModeFenetre = 3.
            IF cTempo = "MIN" THEN iModeFenetre = 2.
            IF iModeFenetre = -1 THEN DO:
                lRetour = AfficheErreur("Excel (FENETRE) : Mode fenetre inconnu (" + cTempo + ") !!",FALSE).
            END.
            ELSE DO:
                hApplicationExcel:WINDOWSTATE = iModeFenetre NO-ERROR.        
                IF ERROR-STATUS:ERROR THEN lRetour = AfficheErreur("Excel (FENETRE) : Erreur d'execution !!",TRUE).
            END.
        END.

        /* ------------------------------------------------------------------------------------ */

        /* Execution d'une macro */
        IF cAction-in = "EXECUTER" THEN DO:
            lCommandeConnue = TRUE.
            cNomMacro = ENTRY(1,cParametres-in).
            /* Vérification de la saisie de la macro */
            IF cNomMacro = "" THEN DO:
                lRetour = AfficheErreur("Excel (DOCUMENT-EXECUTE) : Macro non spécifiée !!",FALSE).
            END.

            /* Récupération des éventuels paramètres */
            iNombreParametres = 0.
            IF NUM-ENTRIES(cParametres-in) >= 2 THEN DO:
                /* Vidage du tableau des parametres */
                DO iBoucle = 1 TO 5:
                    tbParametres[iBoucle] = "".
                END.

                cParametres = ENTRY(2,cParametres-in).
                iNombreParametres = NUM-ENTRIES(cParametres,"#").
                DO iBoucle = 1 TO iNombreParametres:
                    tbParametres[iBoucle] = ENTRY(iBoucle,cParametres,"#").
                END.
            END.

            IF iNombreParametres = 0 THEN 
                hApplicationExcel:RUN(cNomMacro) NO-ERROR.

            IF iNombreParametres = 1 THEN
                hApplicationExcel:RUN(cNomMacro,tbParametres[1]) NO-ERROR.

            IF iNombreParametres = 2 THEN
                hApplicationExcel:RUN(cNomMacro,tbParametres[1],tbParametres[2]) NO-ERROR.

            IF iNombreParametres = 3 THEN
                hApplicationExcel:RUN(cNomMacro,tbParametres[1],tbParametres[2],tbParametres[3]) NO-ERROR.

            IF iNombreParametres = 4 THEN
                hApplicationExcel:RUN(cNomMacro,tbParametres[1],tbParametres[2],tbParametres[3],tbParametres[4]) NO-ERROR.

            IF iNombreParametres = 5 THEN
                hApplicationExcel:RUN(cNomMacro,tbParametres[1],tbParametres[2],tbParametres[3],tbParametres[4],tbParametres[5]) NO-ERROR.

            IF ERROR-STATUS:ERROR THEN lRetour = AfficheErreur("Excel (DOCUMENT-EXECUTE/" + cNomMacro + ") : Erreur d'execution !!",TRUE).
            
            /* Récupération du handle de l'onglet en cours après macro */
            hDocumentEsclave = hApplicationExcel:ACTIVEWORKBOOK.
        END.

        /* ------------------------------------------------------------------------------------ */

        /* Ouverture d'un document */
        IF cAction-in = "DOCUMENT-OUVRIR" THEN DO:
            lCommandeConnue = TRUE.
            cNomDocument = ENTRY(1,cParametres-in).
            /* Vérification de l'existence du fichier */
            IF cNomDocument = "" THEN DO:
                lRetour = AfficheErreur("Excel (DOCUMENT-OUVRIR) : Document non spécifié !!",FALSE).
            END.
            ELSE DO:
                IF search(cNomDocument) = ? THEN DO:
                    lRetour = AfficheErreur("Excel (DOCUMENT-OUVRIR) : Document inconnu (" + cNomDocument + ") !!",FALSE).
                END.
                ELSE DO:
                    hApplicationExcel:Workbooks:OPEN(cNomDocument,,,,,,TRUE) NO-ERROR.   
                    IF ERROR-STATUS:ERROR THEN lRetour = AfficheErreur("Excel (DOCUMENT-OUVRIR) : Erreur d'execution !!",TRUE).
                    hDocumentExcel = hApplicationExcel:ACTIVEWORKBOOK. 
                    hDocumentMaitre = hDocumentExcel.   
                END.
            END.
        END.
        
        /* Ici les actions ayant besoin de excel Ouvert et d'un document ouvert */
        IF VALID-HANDLE(hDocumentExcel) THEN DO:

            /* ------------------------------------------------------------------------------------ */

            /* Fermeture d'un document */
            IF cAction-in = "DOCUMENT-FERMER" THEN DO:
                lCommandeConnue = TRUE.
                hDocumentExcel:CLOSE() NO-ERROR.
                IF ERROR-STATUS:ERROR THEN lRetour = AfficheErreur("Excel (DOCUMENT-FERMER) : Erreur d'execution !!",TRUE).
            END.

            /* ------------------------------------------------------------------------------------ */

            /* Enregistrement d'un document */
            IF cAction-in = "DOCUMENT-ENREGISTRER" THEN DO:
                lCommandeConnue = TRUE.
                hDocumentExcel:SAVE() NO-ERROR.
                IF ERROR-STATUS:ERROR THEN lRetour = AfficheErreur("Excel (DOCUMENT-ENREGISTRER) : Erreur d'execution !!",TRUE).
            END.

            /* ------------------------------------------------------------------------------------ */

            /* Enregistrement d'un document */
            IF cAction-in = "DOCUMENT-ENREGISTRER-SOUS" THEN DO:
                lCommandeConnue = TRUE.
                cNomDocument = ENTRY(1,cParametres-in).
                /* Vérification de la saisie */
                IF cNomDocument = "" THEN DO:
                    lRetour = AfficheErreur("Excel (DOCUMENT-ENREGISTRER-SOUS) : Document non spécifié !!",FALSE).
                END.
                ELSE DO:
                    hDocumentExcel:SAVEAS(cNomDocument,-4143,,,,,) NO-ERROR.
                    IF ERROR-STATUS:ERROR THEN lRetour = AfficheErreur("Excel (DOCUMENT-ENREGISTRER-SOUS) : Erreur d'execution !!",TRUE).
                END.
            END.
        END.
    END.

    IF lRetour <> ? AND NOT(lCommandeConnue) THEN DO:
        lRetour = AfficheErreur("Excel : Commande inconnue '" + cAction-in + "' !!",TRUE).
    END.
	
    /* Gestion du retour */
	RETURN lRetour.
END FUNCTION.

/* ----------------------------------------------------------------------- 
    Mise en forme complete d'un document Excel 
   ----------------------------------------------------------------------- */
FUNCTION MiseEnForme RETURNS LOGICAL (lVerbose-in AS logical, cFichierModele-in AS CHARACTER, cFichierSauvegarde-in AS CHARACTER, cFichierDonnees-in AS CHARACTER, cTitre-in AS CHARACTER):

    DEFINE VARIABLE lRetour AS LOGICAL NO-UNDO INIT TRUE.

    /* Vérification de la saisie */
    IF cFichierModele-in = "" THEN DO:
        lRetour = AfficheErreur("MiseEnForme : Nom du fichier modèle non spécifié !!",FALSE).
        RETURN(lRetour).
    END.
    IF search(cFichierModele-in) = ? THEN DO:
        lRetour = AfficheErreur("MiseEnForme : Le fichier modèle " + cFichierModele-in + " n'existe pas !!",FALSE).
        RETURN(lRetour).
    END.
    IF cFichierSauvegarde-in = "" THEN DO:
        lRetour = AfficheErreur("MiseEnForme : Nom du fichier de sauvegarde non spécifié !!",FALSE).
        RETURN(lRetour).
    END.
    IF cFichierDonnées-in = "" THEN DO:
        lRetour = AfficheErreur("MiseEnForme : Nom du fichier des données non spécifié !!",FALSE).
        RETURN(lRetour).
    END.
    IF search(cFichierDonnées-in) = ? THEN DO:
        lRetour = AfficheErreur("MiseEnForme : Le fichier des données " + cFichierDonnees-in + " n'existe pas !!",FALSE).
        RETURN(lRetour).
    END.

    /* Lancement de Excel si pas déja fait */
    IF lVerbose-in THEN AfficheMessage("Lancement de Excel si pas déja fait").
    IF lRetour AND NOT(VALID-HANDLE(hApplicationExcel)) THEN Excel("OUVRIR","").

    /* Rendre visible excel si besoin */
    IF lVerbose-in  THEN DO:
        IF lRetour THEN excel("VISIBLE","").
        IF lRetour THEN excel("FENETRE","NORMAL").
    END.

    /* Duplication du fichier */
    IF lVerbose-in THEN AfficheMessage("Copie du fichier " + cFichierModele-in + " en " + cFichierSauvegarde-in).
    OS-COPY VALUE(cFichierModele-in) VALUE(cFichierSauvegarde-in).

    /* Ouverture du modèle */
    IF lVerbose-in THEN AfficheMessage("Ouverture du modèle : " + cFichierSauvegarde-in).
    IF lRetour THEN excel("DOCUMENT-OUVRIR",cFichierSauvegarde-in).

    /*--> Execution du rattachement */
    IF lRetour THEN excel("VISIBLE","").
    IF lRetour THEN excel("FENETRE","MIN").
    IF lVerbose-in THEN AfficheMessage("MiseEnForme").
    IF lRetour THEN Excel("EXECUTER","MiseEnForme," + cFichierDonnees-in + "#" + cTitre-in).
    
    /* Fermeture du document maitre */
    hDocumentExcel = hDocumentMaitre.
    IF lVerbose-in THEN AfficheMessage("DOCUMENT-FERMER : hDocumentExcel / hDocumentEsclave / hDocumentMaitre = " + string(hDocumentExcel) + " / " + string(hDocumentEsclave) + " / " + string(hDocumentMaitre)).
    IF lRetour THEN excel("DOCUMENT-FERMER","").

    /* supprimer le fichier fermer pour ne pas avoir la demande de confirmation */
    OS-DELETE VALUE(cFichierSauvegarde-in).

    /* Sauvegarde du document esclave */
    hDocumentExcel = hDocumentEsclave.
    IF lVerbose-in THEN AfficheMessage("DOCUMENT-ENREGISTRER-SOUS : hDocumentExcel / hDocumentEsclave / hDocumentMaitre = " + string(hDocumentExcel) + " / " + string(hDocumentEsclave) + " / " + string(hDocumentMaitre)).
    IF lRetour THEN excel("DOCUMENT-ENREGISTRER-SOUS",cFichierSauvegarde-in). 

    /* Rendre visible et normal Excel */
    IF lRetour THEN excel("VISIBLE","").
    IF lRetour THEN excel("FENETRE","MAX").
    
    /* gestion du retour */
    lRetour = TRUE.
    RETURN(lRetour).

END FUNCTION.

FUNCTION AfficheMessage RETURNS CHARACTER (cLibelleMessage-in AS CHARACTER):

    MESSAGE "Excel.i : " + CHR(10) + cLibelleMessage-in
        VIEW-AS ALERT-BOX INFORMATION.

END FUNCTION.

