/*---------------------------------------------------------------------------
 Application      : MENUDEV2
 Programme        : pretraitements.p
 Objet            : Actions à effectuer au tout debut du lancement
*---------------------------------------------------------------------------
 Date de création : 02/12/2014
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

{includes\i_environnement.i}
{menudev2\includes\menudev2.i}

/*-------------------------------------------------------------------------*
 | DEFINITIONS                                                             |
 *-------------------------------------------------------------------------*/

DEFINE INPUT PARAMETER cUtil-in AS CHARACTER NO-UNDO.

DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO.
DEFINE VARIABLE cFichier AS CHARACTER NO-UNDO.
DEFINE VARIABLE cFichierPhysique AS CHARACTER NO-UNDO.
DEFINE VARIABLE cidReference AS CHARACTER NO-UNDO.
DEFINE VARIABLE cRepertoire AS CHARACTER NO-UNDO.
DEFINE VARIABLE cTexte AS CHARACTER NO-UNDO.
DEFINE VARIABLE cLigneFichier AS CHARACTER NO-UNDO.
DEFINE VARIABLE cCommande AS CHARACTER NO-UNDO.

DEFINE STREAM sListe.
DEFINE STREAM sFichier.


/*-------------------------------------------------------------------------*
 | MAIN BLOCK                                                              |
 *-------------------------------------------------------------------------*/
 
/* renommage des prefs des bouton GI, GI-2 BATCH-CLIENT-SUIV */
FOR EACH    Prefs   EXCLUSIVE-LOCK
    WHERE   Prefs.cUtilisateur = cUtil-in
    AND     Prefs.cCode = "BATCH-CLIENT-2"
    :
    Prefs.cCode = "BATCH-CLIENT-SUIV".
END.

/* Chargement des blocs-notes dans la base */
cidReference = STRING(TODAY,"99/99/9999") + "-" + STRING(TIME,"hh:mm:ss").
cRepertoire = loc_outils + "\perso\" + gcUtilisateur.
IF SEARCH(cRepertoire + "\menudev2-bn-notes.txt") <> ? THEN DO:
    INPUT STREAM sListe FROM OS-DIR(cRepertoire).
    REPEAT:
        IMPORT STREAM sListe cLigne.
        IF cLigne = "." OR cLigne = ".." THEN NEXT.
        IF NOT(cligne BEGINS("Menudev2-")) THEN NEXT.
        IF NUM-ENTRIES(cLigne,"-") < 3 THEN NEXT.
        cFichierPhysique = cLigne.
        cFichier = ENTRY(3,cLigne,"-").
        cFichier = ENTRY(1,cFichier,".").
    
    
        /* creation du fichier dans la base */
        /* le fichier existe peut-etre déjà */
        FIND FIRST  fichiers    EXCLUSIVE-LOCK
            WHERE   fichiers.cUtilisateur = gcUtilisateur
            AND     fichiers.cTypeFichier = "NOTES"
            AND     fichiers.cIdentFichier = cFichier
            NO-ERROR.
        IF NOT(AVAILABLE(fichiers)) THEN DO:
            CREATE fichiers.
            ASSIGN
                fichiers.cUtilisateur = gcUtilisateur
                fichiers.cTypeFichier = "NOTES"
                fichiers.cIdentFichier = cFichier
                .
        END.
        
        ASSIGN
            fichiers.cCreateur = gcUtilisateur
            fichiers.cModifieur = gcUtilisateur
            fichiers.idModification = cidReference
            cTexte = ""
            .
    
        /* Ajout dans tous les cas d'un retour chariot à la fin du fichier */
        OUTPUT STREAM sFichier TO VALUE(cRepertoire + "\" + cFichierPhysique) APPEND.
        PUT STREAM sFichier UNFORMATTED " " SKIP.
        OUTPUT STREAM sFichier CLOSE.
    
        INPUT STREAM sFichier FROM VALUE(cRepertoire + "\" + cFichierPhysique).
        REPEAT:
            IMPORT STREAM sFichier UNFORMATTED cLigneFichier.
            cTexte = cTexte + CHR(10) + cLigneFichier.
        END.
        INPUT STREAM sFichier CLOSE.
        cTexte = SUBSTRING(cTexte,2).
    
        fichiers.texte = cTexte.
    
        /* renommage du fichier pour ne pas le prendre la prochaine fois */
        OS-RENAME VALUE(cRepertoire + "\" + cFichierPhysique) VALUE(cRepertoire + "\old-" + cFichierPhysique).
        
    END.
    INPUT STREAM sListe CLOSE.
END.

/* Suppression d'un éventuel arret silencieux parasite */
FOR EACH ordres EXCLUSIVE-LOCK
   WHERE ordres.cutilisateur = gcUtilisateur
   AND ordres.cAction = "INFOS"
   AND (ordres.cmessage = "<ARRET>" OR ordres.cmessage = "<REBOOT>")
   :
    DELETE ordres.
END.
/* Création de l'enregistrement bidon */
FIND FIRST ordres   NO-LOCK
    WHERE ordres.cutilisateur = gcUtilisateur
    AND ordres.cAction = "INFOS"
    AND ordres.cmessagedistribue = ">"
    NO-ERROR.
IF NOT(AVAILABLE(ordres)) THEN DO:
    CREATE ordres.
    ASSIGN
        ordres.cutilisateur = gcUtilisateur
        ordres.cAction = "INFOS"
        ordres.ldistribue = TRUE
        ordres.cmessagedistribue = ">"
        .
END.

RELEASE ordres.
RELEASE prefs.
RELEASE fichiers.

/*IF SEARCH(loc_outils + "\SaisieAutomatique.exe") = ? THEN*/
    OS-COPY VALUE(ser_outils + "\progress\Menudev2\Ressources\Scripts\general\SaisieAutomatique.exe") VALUE(loc_outils).

/*IF SEARCH(loc_outils + "\Disques.vbs") = ? THEN*/
    OS-COPY VALUE(ser_outils + "\progress\Menudev2\Ressources\Scripts\general\Disques.vbs") VALUE(loc_outils).


/* Suppression des .lk si demandé pour ceux qui n'attendrent pas que les serveurs s'arrettent
avant d'éteindre leur machine.... */
IF DonnePreference("PREF-SUPPRIME-LK") = "OUI" THEN DO:
    OS-COMMAND SILENT VALUE(ser_outils + "\progress\Menudev2\Ressources\Scripts\general\menage.bat" 
        + " " + SESSION:TEMP-DIRECTORY + "Menudev2.log" 
        + " " + DonnePreference("REPERTOIRE-BASES")).
END.

/* Bouton GI renommé en CLI pour standardisqtion */
IF DonnePreference("AIDE-BOUTON-GI") <> "" THEN DO:
    SauvePreference("AIDE-BOUTON-CLI",DonnePreference("AIDE-BOUTON-GI")).
    SauvePreference("AIDE-BOUTON-GI","").
END.

/* Préférence BTNPERSO renommée en BTNPERSO-1 pour standardisation */
IF DonnePreference("BTNPERSO") <> "" THEN DO:
    SauvePreference("BTNPERSO-1",DonnePreference("BTNPERSO")).
    SupprimePreference("BTNPERSO").
END.

/* Changement du caractere délimiteur des pseudo-variables dans la procedure gRemplaceVariables */
FOR EACH 	agenda	EXCLUSIVE-LOCK
	WHERE	agenda.cUtilisateur = cUtil-in
	AND     agenda.cLibelle = "Controle de la machine"
	AND 	agenda.cAction MATCHES "*[CONTROLE-OPTIONS]*"
	:
	agenda.cAction = REPLACE(agenda.cAction,"[CONTROLE-OPTIONS]","%CONTROLE-OPTIONS%").
END.

/* Initialisation du paramétrage des absences */
IF DonnePreference("PREFS-ABSENCES-JOURS") = "" THEN SauvePreference("PREFS-ABSENCES-JOURS","07").
IF DonnePreference("PREFS-ABSENCES-JOUR-PREVENIR") = "" THEN SauvePreference("PREFS-ABSENCES-JOUR-PREVENIR","OUI").
IF DonnePreference("PREFS-ABSENCES-FUTURES-PREVENIR") = "" THEN SauvePreference("PREFS-ABSENCES-FUTURES-PREVENIR","OUI").
IF DonnePreference("PREF-ABSENCES-PREVENIR-NOUVELLE") = "" THEN SauvePreference("PREF-ABSENCES-PREVENIR-NOUVELLE","OUI").
IF DonnePreference("PREF-ABSENCES-PREVENIR-NOUVELLE-DESUITE") = "" THEN SauvePreference("PREF-ABSENCES-PREVENIR-NOUVELLE-DESUITE","OUI").
IF DonnePreference("PREFS-ABSENCES-PAS-WE") = "" THEN SauvePreference("PREFS-ABSENCES-PAS-WE","OUI").
IF DonnePreference("PREFS-ABSENCES-PRESENTATION") = "" THEN SauvePreference("PREFS-ABSENCES-PRESENTATION","2").
IF DonnePreference("PREFS-ABSENCES-UNE-PAR-LIGNE") = "" THEN SauvePreference("PREFS-ABSENCES-UNE-PAR-LIGNE","OUI").
IF DonnePreference("PREFS-ABSENCES-PAS-AVERTISSEMENT-WE") = "" THEN SauvePreference("PREFS-ABSENCES-PAS-AVERTISSEMENT-WE","OUI").

/* Nouveaux boutons */
IF DonnePreference("PREF-BOUTON-PERSO-7-IMAGE") = "" THEN SauvePreference("PREF-BOUTON-PERSO-7-IMAGE","net.ico").
IF DonnePreference("PREF-BOUTON-PERSO-8-IMAGE") = "" THEN SauvePreference("PREF-BOUTON-PERSO-8-IMAGE","net.ico").

IF DonnePreference("PREF-BOUTON-PERSO-7-IMAGE-DEFAUT") = "" THEN SauvePreference("PREF-BOUTON-PERSO-7-IMAGE-DEFAUT","net.ico").
IF DonnePreference("PREF-BOUTON-PERSO-8-IMAGE-DEFAUT") = "" THEN SauvePreference("PREF-BOUTON-PERSO-8-IMAGE-DEFAUT","net.ico").

IF DonnePreference("PREF-COMPRESSION") = "" THEN SauvePreference("PREF-COMPRESSION","5").
IF DonnePreference("PREF-BASESLOCALES") = "" THEN SauvePreference("PREF-BASESLOCALES","OUI").
  
IF (DonnePreference("FILTRE-UTILISATEUR") = ? OR DonnePreference("FILTRE-UTILISATEUR") = "") THEN SauvePreference("FILTRE-UTILISATEUR","-").
/* Mise en majuscule des codes activite */
FOR EACH    activite    EXCLUSIVE-LOCK
    WHERE   activite.cUtilisateur = cUtil-in
    AND     activite.dDate < DATE(04,07,2018)
    :
    activite.cCodeActivite = CAPS(activite.cCodeActivite).
END.

if DonnePreference("PREFS-VERSION-PROGRESS-DEMARRAGE") = "" then SauvePreference("PREFS-VERSION-PROGRESS-DEMARRAGE","OUI").

if DonnePreference("PREFS-BASES-FICHIERS-NOUVELLE-GESTION") = "" THEN DO:
    RUN VALUE(gcRepertoireExecution + "\CreFichiersInfos.p") (gcUtilisateur).
END.

/* Modification de l'ident du fichier BASE mis en base de données */
IF DonnePreference("PREFS-BASES-FICHIERS-MODIF-IDENT") = "" then DO:
    FOR EACH    fichiers    
        WHERE   fichiers.cUtilisateur = gcUtilisateur
        AND     fichiers.cTypeFichier = "BASES"
        AND     fichiers.cIdentFichier = "bases.txt"
        :
        fichiers.cIdentFichier = "bases".
    END.
    SauvePreference("PREFS-BASES-FICHIERS-MODIF-IDENT","OUI").
END.

IF DonnePreference("BATCH-DEV") = "" THEN SauvePreference("BATCH-DEV","H:\dev\outils\progress\Menudev2\Ressources\Scripts\session\Lancement.bat DEV H:\dev\outils\progress\Menudev2\Ressources\Scripts\session\LanceAppliGI.bat").

OS-COPY VALUE(loc_outils + "\menudev.fav") VALUE(gcRepertoireRessourcesPrivees + "Utilisateurs\" + gcUtilisateur + "\" + gcUtilisateur + "-Favoris.mdev2").

cCommande = "del " + loc_outils + "\menudev.fav*".
OS-COMMAND SILENT VALUE(cCommande).

cCommande = "mkdir " + gcRepertoireRessourcesPrivees + "Utilisateurs\" + gcUtilisateur + "\Favoris".
OS-COMMAND SILENT VALUE(cCommande).

cCommande = "move " + gcRepertoireRessourcesPrivees + "Utilisateurs\" + gcUtilisateur + "\racc\*.* "
                    + gcRepertoireRessourcesPrivees + "Utilisateurs\" + gcUtilisateur + "\Favoris".
OS-COMMAND SILENT VALUE(cCommande).

cCommande = "rmdir " + gcRepertoireRessourcesPrivees + "Utilisateurs\" + gcUtilisateur + "\racc".
OS-COMMAND SILENT VALUE(cCommande).

/* Paramètres des serveurs */
IF DonnePreference("PREFS-SERVEURS-STANDARD") = "" THEN SauvePreference("PREFS-SERVEURS-STANDARD","-L 20000 -n 50 -B 600 -Ma 7 -Mn 7 -Mi 2").
IF DonnePreference("PREFS-SERVEURS-SADB") = "" THEN SauvePreference("PREFS-SERVEURS-SADB","-L 100000 -n 50 -B 600 -Ma 7 -Mn 7 -Mi 2").
IF DonnePreference("PREFS-SERVEURS-COMPTA") = "" THEN SauvePreference("PREFS-SERVEURS-COMPTA","-L 100000 -n 50 -B 600 -Ma 7 -Mn 7 -Mi 2").
IF DonnePreference("PREFS-SERVEURS-INTER") = "" THEN SauvePreference("PREFS-SERVEURS-INTER","-L 50000 -n 50 -B 600 -Ma 7 -Mn 7 -Mi 2").

/* Bascule V10-V11 */
IF SEARCH("c:\pfgi\cnxt_v10.pf") = ? THEN DO:
    OS-COPY VALUE("c:\pfgi\cnxtests.pf") VALUE("c:\pfgi\cnxt_v10.pf").
END.
