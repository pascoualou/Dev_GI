/*--------------------------------------------------------------------------*
| Programme        : i_word.i                                               |
| Objet            : procedures et fonctions pour l'utilisation de word     |
|---------------------------------------------------------------------------|
| Date de création : 26/02/2015                                             |
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

DEFINE VARIABLE hApplicationWord AS COM-HANDLE NO-UNDO.
DEFINE VARIABLE hDocumentWord AS COM-HANDLE NO-UNDO.
DEFINE VARIABLE cFichierMacros AS CHARACTER NO-UNDO.
DEFINE VARIABLE cFichierSauvegarde AS CHARACTER NO-UNDO.

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
    MESSAGE cMessage VIEW-AS ALERT-BOX ERROR TITLE "Contrôle de Word...".

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
FUNCTION Word RETURNS LOGICAL (cAction-in AS CHARACTER,cParametres-in AS CHARACTER):

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
	
    /* Ouverture de word */
    IF cAction-in = "OUVRIR" THEN DO:
        lCommandeConnue = TRUE.
        CREATE "word.Application" hApplicationWord CONNECT NO-ERROR.
        IF ERROR-STATUS:ERROR THEN DO:
            CREATE "word.Application" hApplicationWord NO-ERROR.
            IF ERROR-STATUS:ERROR THEN lRetour = AfficheErreur("Word (OUVRIR) : Impossible de lancer Word",TRUE).
            ELSE lRetour = TRUE.
        END.
        ELSE lRetour = TRUE.
    END.
	
    /* Ici les actions ayant besoin d'un Word actif */
    IF NOT(VALID-HANDLE(hApplicationWord)) THEN DO:
        lRetour = ?.
    END.
    ELSE DO:

        /* ------------------------------------------------------------------------------------ */

        /* word au premier plan */
        IF cAction-in = "PREMIER-PLAN" THEN DO:
            lCommandeConnue = TRUE.
            hApplicationWord:MOVE-TO-TOP() NO-ERROR.        
            IF ERROR-STATUS:ERROR THEN lRetour = AfficheErreur("Word (PREMIER-PLAN) : Impossible de fermer Word",TRUE).
        END.

        /* ------------------------------------------------------------------------------------ */

        /* Fermeture de word */
        IF cAction-in = "FERMER" THEN DO:
            lCommandeConnue = TRUE.
            hApplicationWord:QUIT(0) NO-ERROR.        
            IF ERROR-STATUS:ERROR THEN lRetour = AfficheErreur("Word (FERMER) : Impossible de fermer Word",TRUE).
            RELEASE OBJECT hApplicationWord NO-ERROR.
            IF ERROR-STATUS:ERROR THEN lRetour = AfficheErreur("Word (FERMER/RELEASE OBJECT) : Impossible de supprimer l'objet Word",TRUE).
        END.

        /* ------------------------------------------------------------------------------------ */

        /* word visible */
        IF cAction-in = "VISIBLE" THEN DO:
            lCommandeConnue = TRUE.
            hApplicationWord:VISIBLE = TRUE NO-ERROR.        
            IF ERROR-STATUS:ERROR THEN lRetour = AfficheErreur("Word (VISIBLE) : Erreur d'execution !!",TRUE).
        END.

        /* ------------------------------------------------------------------------------------ */

        /* word invisible */
        IF cAction-in = "INVISIBLE" THEN DO:
            lCommandeConnue = TRUE.
            hApplicationWord:VISIBLE = FALSE NO-ERROR.        
            IF ERROR-STATUS:ERROR THEN lRetour = AfficheErreur("Word (INVISIBLE) : Erreur d'execution !!",TRUE).
        END.

        /* ------------------------------------------------------------------------------------ */

        /* word activer */
        IF cAction-in = "ACTIVER" THEN DO:
            lCommandeConnue = TRUE.
            hApplicationWord:ACTIVATE() NO-ERROR.        
            IF ERROR-STATUS:ERROR THEN lRetour = AfficheErreur("Word (ACTIVER) : Erreur d'execution !!",TRUE).
        END.

        /* ------------------------------------------------------------------------------------ */

        /* Mode fenetre de word (Max/Min/Normal) */
        IF cAction-in = "FENETRE" THEN DO:
            lCommandeConnue = TRUE.
            iModeFenetre = -1.
            cTempo = ENTRY(1,cParametres-in).
            IF cTempo = "NORMAL" THEN iModeFenetre = 0.
            IF cTempo = "MAX" THEN iModeFenetre = 1.
            IF cTempo = "MIN" THEN iModeFenetre = 2.
            IF iModeFenetre = -1 THEN DO:
                lRetour = AfficheErreur("Word (FENETRE) : Mode fenetre inconnu (" + cTempo + ") !!",FALSE).
            END.
            ELSE DO:
                hApplicationWord:WINDOWSTATE = iModeFenetre NO-ERROR.        
                IF ERROR-STATUS:ERROR THEN lRetour = AfficheErreur("Word (FENETRE) : Erreur d'execution !!",TRUE).
            END.
        END.

        /* ------------------------------------------------------------------------------------ */

        /* Execution d'une macro */
        IF cAction-in = "EXECUTER" THEN DO:
            lCommandeConnue = TRUE.
            cNomMacro = ENTRY(1,cParametres-in).
            /* Vérification de la saisie de la macro */
            IF cNomMacro = "" THEN DO:
                lRetour = AfficheErreur("Word (DOCUMENT-EXECUTE) : Macro non spécifiée !!",FALSE).
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
                hApplicationWord:RUN(cNomMacro) NO-ERROR.

            IF iNombreParametres = 1 THEN
                hApplicationWord:RUN(cNomMacro,tbParametres[1]) NO-ERROR.

            IF iNombreParametres = 2 THEN
                hApplicationWord:RUN(cNomMacro,tbParametres[1],tbParametres[2]) NO-ERROR.

            IF iNombreParametres = 3 THEN
                hApplicationWord:RUN(cNomMacro,tbParametres[1],tbParametres[2],tbParametres[3]) NO-ERROR.

            IF iNombreParametres = 4 THEN
                hApplicationWord:RUN(cNomMacro,tbParametres[1],tbParametres[2],tbParametres[3],tbParametres[4]) NO-ERROR.

            IF iNombreParametres = 5 THEN
                hApplicationWord:RUN(cNomMacro,tbParametres[1],tbParametres[2],tbParametres[3],tbParametres[4],tbParametres[5]) NO-ERROR.

            IF ERROR-STATUS:ERROR THEN lRetour = AfficheErreur("Word (DOCUMENT-EXECUTE/" + cNomMacro + ") : Erreur d'execution !!",TRUE).
        END.

        /* ------------------------------------------------------------------------------------ */

        /* Ouverture d'un document */
        IF cAction-in = "DOCUMENT-OUVRIR" THEN DO:
            lCommandeConnue = TRUE.
            cNomDocument = ENTRY(1,cParametres-in).
            /* Vérification de l'existence du fichier */
            IF cNomDocument = "" THEN DO:
                lRetour = AfficheErreur("Word (DOCUMENT-OUVRIR) : Document non spécifié !!",FALSE).
            END.
            ELSE DO:
                IF search(cNomDocument) = ? THEN DO:
                    lRetour = AfficheErreur("Word (DOCUMENT-OUVRIR) : Document inconnu (" + cNomDocument + ") !!",FALSE).
                END.
                ELSE DO:
                    hDocumentWord = hApplicationWord:DOCUMENTS:OPEN(cNomDocument) NO-ERROR.        
                    IF ERROR-STATUS:ERROR THEN lRetour = AfficheErreur("Word (DOCUMENT-OUVRIR) : Erreur d'execution !!",TRUE).
                END.
            END.
        END.
        
        /* Ici les action ayant besoin de word Ouvert et d'un document ouvert */
        IF VALID-HANDLE(hDocumentWord) THEN DO:

            /* ------------------------------------------------------------------------------------ */

            /* Fermeture d'un document */
            IF cAction-in = "DOCUMENT-FERMER" THEN DO:
                lCommandeConnue = TRUE.
                hDocumentWord:CLOSE() NO-ERROR.
                IF ERROR-STATUS:ERROR THEN lRetour = AfficheErreur("Word (DOCUMENT-FERMER) : Erreur d'execution !!",TRUE).
            END.

            /* ------------------------------------------------------------------------------------ */

            /* Enregistrement d'un document */
            IF cAction-in = "DOCUMENT-ENREGISTRER" THEN DO:
                lCommandeConnue = TRUE.
                hDocumentWord:SAVE() NO-ERROR.
                IF ERROR-STATUS:ERROR THEN lRetour = AfficheErreur("Word (DOCUMENT-ENREGISTRER) : Erreur d'execution !!",TRUE).
            END.

            /* ------------------------------------------------------------------------------------ */

            /* Enregistrement d'un document */
            IF cAction-in = "DOCUMENT-ENREGISTRER-SOUS" THEN DO:
                lCommandeConnue = TRUE.
                cNomDocument = ENTRY(1,cParametres-in).
                /* Vérification de la saisie */
                IF cNomDocument = "" THEN DO:
                    lRetour = AfficheErreur("Word (DOCUMENT-ENREGISTRER-SOUS) : Document non spécifié !!",FALSE).
                END.
                ELSE DO:
                    /*hApplicationWord:DisplayAlerts = FALSE.*/
                    hDocumentWord:SAVEAS(cNomDocument) NO-ERROR.
                    IF ERROR-STATUS:ERROR THEN lRetour = AfficheErreur("Word (DOCUMENT-ENREGISTRER-SOUS) : Erreur d'execution !!",TRUE).
                    /*MESSAGE "fin de l'enregistrement" VIEW-AS ALERT-BOX.*/
                END.
            END.

            /* ------------------------------------------------------------------------------------ */

            /* Ajout du fichier de macros */
            IF cAction-in = "DOCUMENT-MACROS-AJOUTE" THEN DO:
                lCommandeConnue = TRUE.
                cFichierMacros = ENTRY(1,cParametres-in).
                /* Gestion du fichier macro par defaut si on envoi '*' */
                IF cFichierMacros = "*" THEN DO:
                    cFichierMacros = OS-GETENV("reseau") + "dev\outils\commdev\macros.bas".
                END.
                /* Vérification de l'existence du fichier */
                IF cFichierMacros = "" THEN DO:
                    lRetour = AfficheErreur("Word (DOCUMENT-MACROS-AJOUTE) : Document non spécifié !!",FALSE).
                END.
                ELSE DO:
                    IF search(cFichierMacros) = ? THEN DO:
                        lRetour = AfficheErreur("Word (DOCUMENT-MACROS-AJOUTE) : Document inconnu (" + cFichierMacros + ") !!",FALSE).
                    END.
                    ELSE DO:
                        /*--> On supprime le projet outilDEV s'il existe */
                        DO iBoucle = 1 TO hDocumentWord:VBPROJECT:VBCOMPONENTS:COUNT:
                            IF hDocumentWord:VBPROJECT:VBCOMPONENTS:ITEM(iBoucle):NAME BEGINS("MacrosDEV") THEN DO:
                                hDocumentWord:VBPROJECT:VBCOMPONENTS:REMOVE(hDocumentWord:VBPROJECT:VBCOMPONENTS:ITEM(iBoucle)).
                                /* On recommence au debut au cas il y serait plusieurs fois */
                                iBoucle = 1.
                            END.
                        END.               
                        /*--> Insertion des macros DEV */
                        hDocumentWord:VBPROJECT:VBCOMPONENTS:IMPORT(cFichierMacros).
                    END.
                END.
            END.

            /* ------------------------------------------------------------------------------------ */

            /* Ajout du fichier de macros */
            IF cAction-in = "DOCUMENT-MACROS-SUPPRIME" THEN DO:
                lCommandeConnue = TRUE.
                cFichierMacros = ENTRY(1,cParametres-in).
                /* Gestion du fichier macro par defaut si on envoi '*' */
                IF cFichierMacros = "*" THEN DO:
                    cFichierMacros = "MacrosDev".
                END.
                /*--> On supprime le projet MacrosDEV s'il existe */
                DO iBoucle = 1 TO hDocumentWord:VBPROJECT:VBCOMPONENTS:COUNT:
                    IF hDocumentWord:VBPROJECT:VBCOMPONENTS:ITEM(iBoucle):NAME BEGINS(cFichierMacros) THEN DO:
                        hDocumentWord:VBPROJECT:VBCOMPONENTS:REMOVE(hDocumentWord:VBPROJECT:VBCOMPONENTS:ITEM(iBoucle)).
                        /* On recommence au debut au cas il y serait plusieurs fois */
                        iBoucle = 1.
                    END.
                END.               
            END.
        END.
    END.

    IF lRetour <> ? AND NOT(lCommandeConnue) THEN DO:
        lRetour = AfficheErreur("Word : Commande inconnue '" + cAction-in + "' !!",TRUE).
    END.
	
    /* Gestion du retour */
	RETURN lRetour.
END FUNCTION.

/* ----------------------------------------------------------------------- 
    Fusion complete d'un document word 
   ----------------------------------------------------------------------- */
FUNCTION Fusion RETURNS LOGICAL (cFichierModele-in AS CHARACTER, cFichierSauvegarde-in AS CHARACTER, cFichierRemplacements-in AS CHARACTER):

    DEFINE VARIABLE lRetour AS LOGICAL NO-UNDO INIT TRUE.

    /* Vérification si word est ouvert*/
    IF NOT(VALID-HANDLE(hApplicationWord)) THEN DO:
        lRetour = AfficheErreur("Fusion : Word n'est pas lancé !!",FALSE).
        RETURN(lRetour).
    END.

    /* Vérification de la saisie */
    IF cFichierModele-in = "" THEN DO:
        lRetour = AfficheErreur("Fusion : Nom du fichier modèle non spécifié !!",FALSE).
        RETURN(lRetour).
    END.
    IF search(cFichierModele-in) = ? THEN DO:
        lRetour = AfficheErreur("Fusion : Le fichier modèle " + cFichierModele-in + " n'existe pas !!",FALSE).
        RETURN(lRetour).
    END.
    IF cFichierSauvegarde-in = "" THEN DO:
        lRetour = AfficheErreur("Fusion : Nom du fichier de sauvegarde non spécifié !!",FALSE).
        RETURN(lRetour).
    END.
    IF cFichierRemplacements-in = "" THEN DO:
        lRetour = AfficheErreur("Fusion : Nom du fichier des remplacements non spécifié !!",FALSE).
        RETURN(lRetour).
    END.
    IF search(cFichierRemplacements-in) = ? THEN DO:
        lRetour = AfficheErreur("Fusion : Le fichier des remplacements " + cFichierRemplacements-in + " n'existe pas !!",FALSE).
        RETURN(lRetour).
    END.

    /* Lancement de word */
    IF lRetour THEN word("OUVRIR","").

    /* Duplication du fichier */
    OS-COPY VALUE(cFichierModele-in) VALUE(cFichierSauvegarde-in).

    /* Ouverture du modèle */
    IF lRetour THEN word("DOCUMENT-OUVRIR",cFichierSauvegarde-in).

    /* Ajout du fichier des macros */
    IF lRetour THEN word("DOCUMENT-MACROS-AJOUTE","*").

    /*--> Execution du rattachement */
    IF lRetour THEN RUN Remplacements(cFichierRemplacements-in,OUTPUT lRetour).

    /* Sauvegarde */
    IF lRetour THEN Word("DOCUMENT-ENREGISTRER",""). 
    
    /* retrait des outils */
    IF lRetour THEN word("DOCUMENT-MACROS-SUPPRIME","*").

    /*--> Fermeture modele */
    IF lRetour THEN Word("DOCUMENT-FERMER",""). 

    /* Ouverture du fichier fusionné */
    IF lRetour THEN word("DOCUMENT-OUVRIR",cFichierSauvegarde-in).
    
    /* gestion du retour */
    lRetour = TRUE.
    RETURN(lRetour).

END FUNCTION.

/* ----------------------------------------------------------------------- 
    Lancement du remplacement des champs dans le document word
   ----------------------------------------------------------------------- */
PROCEDURE Remplacements:
    DEFINE INPUT PARAMETER cFichierRemplacements-in AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER lRetour-ou AS LOGICAL NO-UNDO INIT TRUE.

    DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO.

    /* Ouverture du fichier de remplacement */
    INPUT FROM VALUE(cFichierRemplacements-in).

    /* Balayage du fichier de remplacement et appel de la macro de remplacement */
    REPEAT:
        IMPORT UNFORMATTED cLigne.
        IF lRetour-ou THEN lRetour-ou = Word("EXECUTER","RemplacerChamps," + cLigne). 
    END.

    INPUT CLOSE.
    
END PROCEDURE.


