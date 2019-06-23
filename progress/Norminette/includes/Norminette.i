/*--------------------------------------------------------------------------*
| Programme        : Norminette.i                                           |
| Objet            : .                                                      |
|---------------------------------------------------------------------------|
| Date de cr‚ation : 24/06/2018                                             |
| Auteur(s)        : ..                                                     |
*---------------------------------------------------------------------------*

*---------------------------------------------------------------------------*
| Historique des modifications                                              |
|---------------------------------------------------------------------------|
|  Nø  |    Date    | Auteur |                  Objet                       |
|------+------------+--------+----------------------------------------------|
| .... | ../../.... |  ....  | .                                            |
*--------------------------------------------------------------------------*/


/*-------------------------------------------------------------------------*
 | DEFINITIONS                                                             |
 *-------------------------------------------------------------------------*/
/*-------------------------------------------------------------------------*
   Environnement standard GI développement
 *-------------------------------------------------------------------------*/
    {includes\i_environnement.i new global}

/*-------------------------------------------------------------------------*
   Variables globales
 *-------------------------------------------------------------------------*/
    define {1} shared variable gcRepertoireRessourcesPrivees    as character    no-undo.
    define {1} shared variable gcFichierPreferencesUtilisateur  as character    no-undo.
    define {1} shared variable gcFichierCriteresNorminette      as character    no-undo.
    define {1} shared variable gcCriteresIgnores                as character    no-undo.
    define {1} shared variable gcFichiersTraites                as character    no-undo.
    define {1} shared variable gcArretControlesDebut            as character    no-undo.
    define {1} shared variable gcArretControlesFin              as character    no-undo.
    define {1} shared variable gcFichierParametres              as character    no-undo.
    define {1} shared variable gcRepertoireProjet               as character    no-undo.
    define {1} shared variable gcLigne                          as character    no-undo.  
    define {1} shared variable gcListeVariablesInt64            as character    no-undo.  
    define {1} shared variable gcListePrefixesTablesTemporaires as character    no-undo.  
                                                                
    define {1} shared variable giMaxHistoriqueFichiers          as integer      no-undo.
    define {1} shared variable giMaxLignesCommentaire           as integer      no-undo.
    define {1} shared variable giMaxLignesProcedure             as integer      no-undo.
    define {1} shared variable giVersion                        as integer      no-undo.  
    define {1} shared variable giVersionUtilisateur             as integer      no-undo.  

    define {1} shared variable glEditionWord                    as logical      no-undo.
    define {1} shared variable glMenage                         as logical      no-undo.
    define {1} shared variable glConfirmation                   as logical      no-undo.
    define {1} shared variable glModeDebug                      as logical      no-undo.
    define {1} shared variable glPositionCritere                as logical      no-undo.
    define {1} shared variable glCouleursCritere                as logical      no-undo.  
    define {1} shared variable glModeDebugChargement            as logical      no-undo.  
    
    define stream gsEntree.
    define stream gsSortie.

/*-------------------------------------------------------------------------*
   Tables temporaires partagées
 *-------------------------------------------------------------------------*/

    define {1} shared temp-table gttCriteres
        field cType         as character
        field iOrdre        as integer
        field cLibelle      as character
        field lSelection    as logical
        field cCode         as character
        field cDetail       as character
        field cAide         as character
       .
        
    define {1} shared temp-table gttAnomalies no-undo
        field iLigne        as integer
        field iOrdre        as integer
        field cCodeLigne    as character
        field cBloc         as character
        field cAnomalie     as character
        field cAide         as character
        field cLibelleFiltre as character 
        field cCritere      as character
        index ix_iLigne     is primary iLigne iOrdre
        .
    
/*-------------------------------------------------------------------------*
 | MAIN BLOCK                                                              |
 *-------------------------------------------------------------------------*/
    
    /* Répertoires de l'application */
    gcNomApplication = "Norminette".
    gcRepertoireRessourcesPrivees = gcRepertoireApplication + "ressources\".
    
    gcRepertoireRessourcesUtilisateurs = gcRepertoireRessourcesPrivees + "Utilisateurs\" + gcUtilisateur.
    CreChemin(gcRepertoireRessourcesUtilisateurs,false).
    
    gcRepertoireRessourcesImages = gcRepertoireRessourcesPrivees + "Images\".
    CreChemin(gcRepertoireRessourcesImages,false).
    
    gcRepertoireRessourcesSons = gcRepertoireRessourcesPrivees + "Sons\".
    CreChemin(gcRepertoireRessourcesSons,false).
    
    gcRepertoireRessourcesDocumentations = gcRepertoireRessourcesPrivees + "Documentations\".
    CreChemin(gcRepertoireRessourcesDocumentations,false).   
    
    gcRepertoireRessourcesParametres = gcRepertoireRessourcesPrivees + "Paramètres\".
    CreChemin(gcRepertoireRessourcesParametres,false).
    gcFichierParametres = gcRepertoireRessourcesParametres + "Norminette-params.ini".
    gcFichierCriteresNorminette = gcRepertoireRessourcesParametres + "Norminette-criteres.csv".
    
    gcRepertoireRessourcesParametres = gcRepertoireRessourcesPrivees + "Utilisateurs\" + gcUtilisateur.
    CreChemin(gcRepertoireRessourcesUtilisateurs,false).
    gcFichierPreferencesUtilisateur = gcRepertoireRessourcesUtilisateurs + "\" + "Norminette.prefs".

/* -------------------------------------------------------------------------
   Formatte une date pour ecriture dans un fichier (éviter les ?)
   ----------------------------------------------------------------------- */
function gFormatteValeur returns character (cValeur-in AS character):
    define variable cRetour as character no-undo init "?".

    if cValeur-in <> ? then cRetour = cValeur-in.

    return cRetour.
    
end function.


procedure Forcage:
 /*-------------------------------------------------------------------------*
   Objet : Forcage de traitements
   Notes : Appelée si besoin depuis i_environnement.i
 *-------------------------------------------------------------------------*/
 
    IF gcRepertoireExecution MATCHES "*sources.dev*" THEN
        gcUtilisateur = gcUtilisateur + ".DEV".

end procedure.
    
/* -------------------------------------------------------------------------
   Procédure de Chargement des parametres de l'application
   ----------------------------------------------------------------------- */
procedure gChargeParametres:
    
    /* Chargement des parametres */
    input stream gsEntree from value(gcFichierParametres).
    repeat:
        import stream gsEntree unformatted gcLigne.
        if trim(gcLigne) = ""  then next.
        if trim(gcLigne) begins "#" then next.
        if entry(1,gcLigne,"=") = "VERSION" then giVersion = integer(entry(2,gcLigne,"=")).
        if entry(1,gcLigne,"=") = "REPERTOIRE_PROJET" then gcRepertoireProjet = entry(2,gcLigne,"=").
        if entry(1,gcLigne,"=") = "MAX_HISTORIQUE_FICHIERS" then giMaxHistoriqueFichiers = integer(entry(2,gcLigne,"=")).
        if entry(1,gcLigne,"=") = "MAX_LIGNES_COMMENTAIRE" then giMaxLignesCommentaire = integer(entry(2,gcLigne,"=")).
        if entry(1,gcLigne,"=") = "MAX_LIGNES_PROCEDURE" then giMaxLignesProcedure = integer(entry(2,gcLigne,"=")).
        if entry(1,gcLigne,"=") = "ARRET_CONTROLES_DEBUT" then gcArretControlesDebut = entry(2,gcLigne,"=").
        if entry(1,gcLigne,"=") = "ARRET_CONTROLES_FIN" then gcArretControlesFin = entry(2,gcLigne,"=").
        if entry(1,gcLigne,"=") = "LISTE_VARIABLES_INT64" then gcListeVariablesInt64 = entry(2,gcLigne,"=").
        if entry(1,gcLigne,"=") = "LISTE_PREFIXES_TABLES_TEMPORAIRES" then gcListePrefixesTablesTemporaires = entry(2,gcLigne,"=").
    end.
    input stream gsEntree close.

end procedure.
    
/* -------------------------------------------------------------------------
   Procédure de Chargement des préférences de l'utilisateur
   ----------------------------------------------------------------------- */
procedure gChargePreferencesUtilisateur:
    
    /* Assignation par défaut des variables */
    assign
        gcCriteresIgnores = ""
        glEditionWord = false
        glConfirmation = true
        glMenage = true
        glModeDebug = false
        glPositionCritere = false
        glCouleursCritere = true
        gcFichiersTraites = ""
        .
    if search(gcFichierPreferencesUtilisateur) <> ? then do:
        input stream gsEntree from value(gcFichierPreferencesUtilisateur).
        repeat:
            import stream gsEntree unformatted gcLigne.
            IF trim(gcLigne) = "" then next.
            IF trim(gcLigne) = "#" then next.
            IF entry(1,gcLigne,"=") = "VERSION" then giVersionUtilisateur = integer(entry(2,gcLigne,"=")).
            IF entry(1,gcLigne,"=") = "CRITERES_EXCLUS" then gcCriteresIgnores = entry(2,gcLigne,"=").
            IF entry(1,gcLigne,"=") = "EDITION_WORD" then glEditionWord = (entry(2,gcLigne,"=") = "OUI").
            IF entry(1,gcLigne,"=") = "CONFIRMATION_SORTIE" then glConfirmation = (entry(2,gcLigne,"=") = "OUI").
            IF entry(1,gcLigne,"=") = "MENAGE_SORTIE" then glMenage = (entry(2,gcLigne,"=") = "OUI").
            IF entry(1,gcLigne,"=") = "MODE_DEBUG" then glModeDebug = (entry(2,gcLigne,"=") = "OUI").
            IF entry(1,gcLigne,"=") = "MODE_DEBUG_CHARGEMENT" then glModeDebugChargement = (entry(2,gcLigne,"=") = "OUI").
            IF entry(1,gcLigne,"=") = "REPOSITIONNE_CRITERE" then glPositionCritere = (entry(2,gcLigne,"=") = "OUI").
            IF entry(1,gcLigne,"=") = "COULEURS_CRITERE" then glCouleursCritere = (entry(2,gcLigne,"=") = "OUI").
            IF entry(1,gcLigne,"=") = "FICHIERS_TRAITES" then do:
               gcFichiersTraites = gcFichiersTraites + (if gcFichiersTraites <> "" then "," else "") + entry(2,gcLigne,"=").
            end.
        end.
        input stream gsEntree close.
    end.

end procedure.

/* -------------------------------------------------------------------------
   Procédure de Sauvegarde des préférences de l'utilisateur
   ----------------------------------------------------------------------- */
procedure gSauvePreferencesUtilisateur:

    define variable viBoucle as integer no-undo.
    define variable vcTempo as character no-undo.

    do with frame frmFond:
        /* sauvegarde de la liste des critères non voulus par l'utilisateur et des autres préférences */
        output stream gsSortie to value(gcFichierPreferencesUtilisateur).
        put stream gsSortie unformatted "VERSION=" + string(giversionUtilisateur) skip.
        put stream gsSortie unformatted "CRITERES_EXCLUS=" + gcCriteresIgnores skip.
        put stream gsSortie unformatted "EDITION_WORD=" + string(glEditionWord,"OUI/NON") skip.
        put stream gsSortie unformatted "CONFIRMATION_SORTIE=" + string(glConfirmation,"OUI/NON") skip.
        put stream gsSortie unformatted "MENAGE_SORTIE=" + string(glMenage,"OUI/NON") skip.
        put stream gsSortie unformatted "MODE_DEBUG=" + string(glModeDebug,"OUI/NON") skip.
        put stream gsSortie unformatted "MODE_DEBUG_CHARGEMENT=" + string(glModeDebugChargement,"OUI/NON") skip.
        put stream gsSortie unformatted "REPOSITIONNE_CRITERE=" + string(glPositionCritere,"OUI/NON") skip.
        put stream gsSortie unformatted "COULEURS_CRITERE=" + string(glCouleursCritere,"OUI/NON") skip.
        
        do viBoucle = 1 to minimum(num-entries(gcFichiersTraites),giMaxHistoriqueFichiers):
            vcTempo = entry(viBoucle,gcFichiersTraites).
            if trim(vcTempo) <> "" then put stream gsSortie unformatted "FICHIERS_TRAITES=" + vcTempo skip.
        end.
        output stream gsSortie close.
    end.
end procedure.

/* -------------------------------------------------------------------------
   Procédure de chargement des critères de la norminette
   ----------------------------------------------------------------------- */
procedure gChargeCriteres:
    
    define variable vcRecherche as character no-undo.
    define variable vcLigne     as character no-undo.

    /* Chargement de la liste des critères */
    input stream gsEntree from value(gcFichierCriteresNorminette).
    repeat:
        import stream gsEntree unformatted vcLigne.
        if trim(vcLigne) = "" then next.
        /* Ne pas tenir compte des commentaires */
        if trim(vcLigne) begins "#" then next.
        /* Ne pas tenir compte des message d'erreur */
        if trim(vcLigne) begins "E" then next.
        
        /* ce critere fait-il partie des critères ignorés de l'utilisateur (sauf pour les catégories) ? */
        if entry(2,vcLigne,";") <> "0" then vcRecherche = entry(1,vcLigne,";") + entry(2,vcLigne,";").
        create gttcriteres.
        assign
            gttcriteres.cType = entry(1,vcLigne,";")
            gttcriteres.iOrdre = integer(entry(2,vcLigne,";"))
            gttcriteres.cLibelle = (if gttcriteres.iOrdre = 0 then fill(" ",45 - length(entry(3,vcLigne,";"))) else "") + entry(3,vcLigne,";")
            gttcriteres.lSelection = (if gttcriteres.iOrdre = 0 then false else (if lookup(vcRecherche,gcCriteresIgnores) > 0 then false else true))
            gttcriteres.cCode = entry(1,vcLigne,";") + entry(2,vcLigne,";")
            gttcriteres.cDetail = entry(4,vcLigne,";")
            gttcriteres.cAide = entry(5,vcLigne,";")
            .
    end.
    input stream gsEntree close.

end procedure.

/* -------------------------------------------------------------------------
   Procédure de déchargement des variables de l'application dans un fichier
   ----------------------------------------------------------------------- */
procedure gDechargeVariables:

    define variable cFichier as character no-undo.

    cFichier = loc_tmp + "Norminette-Variables.txt".

    output stream gsSortie to value(cFichier).

    put stream gsSortie unformatted fill("-",80) skip.
    put stream gsSortie unformatted "VARIABLES GLOBALES..." skip(1).
    put stream gsSortie unformatted "gcRepertoireRessourcesPrivees = " + gformatteValeur(gcRepertoireRessourcesPrivees) skip.
    put stream gsSortie unformatted "gcRepertoireRessources = " + gformatteValeur(gcRepertoireRessources) skip.
    put stream gsSortie unformatted "gcRepertoireRessourcesImages = " + gformatteValeur(gcRepertoireRessourcesImages) skip.
    put stream gsSortie unformatted "gcRepertoireRessourcesSons = " + gformatteValeur(gcRepertoireRessourcesSons) skip.
    put stream gsSortie unformatted "gcRepertoireRessourcesDocumentations = " + gformatteValeur(gcRepertoireRessourcesDocumentations) skip.
    put stream gsSortie unformatted "gcRepertoireRessourcesParametres = " + gformatteValeur(gcRepertoireRessourcesParametres) skip.
    put stream gsSortie unformatted "gcRepertoireRessourcesUtilisateurs = " + gformatteValeur(gcRepertoireRessourcesUtilisateurs) skip.
    put stream gsSortie unformatted "gcFichierPreferencesUtilisateur = " + gformatteValeur(gcFichierPreferencesUtilisateur) skip.
    put stream gsSortie unformatted "gcFichierCriteresNorminette = " + gformatteValeur(gcFichierCriteresNorminette) skip.
    put stream gsSortie unformatted "gcFichiersTraites = " + gformatteValeur(gcFichiersTraites) skip.
    put stream gsSortie unformatted "gcArretControlesDebut = " + gformatteValeur(gcArretControlesDebut) skip.
    put stream gsSortie unformatted "gcArretControlesFin = " + gformatteValeur(gcArretControlesFin) skip.
    put stream gsSortie unformatted "gcFichierParametres = " + gformatteValeur(gcFichierParametres) skip.
    put stream gsSortie unformatted "gcRepertoireProjet = " + gformatteValeur(gcRepertoireProjet) skip.
    put stream gsSortie unformatted "gcLigne = " + gformatteValeur(gcLigne) skip.
    put stream gsSortie unformatted "giMaxHistoriqueFichiers = " + gformatteValeur(string(giMaxHistoriqueFichiers)) skip.
    put stream gsSortie unformatted "giMaxLignesCommentaire = " + gformatteValeur(string(giMaxLignesCommentaire)) skip.
    put stream gsSortie unformatted "giMaxLignesProcedure = " + gformatteValeur(string(giMaxLignesProcedure)) skip.
    put stream gsSortie unformatted "glEditionWord = " + gformatteValeur(string(glEditionWord,"oui/non")) skip.
    put stream gsSortie unformatted "glMenage = " + gformatteValeur(string(glMenage,"oui/non")) skip.
    put stream gsSortie unformatted "glConfirmation = " + gformatteValeur(string(glConfirmation,"oui/non")) skip.
    put stream gsSortie unformatted "glModeDebug = " + gformatteValeur(string(glModeDebug,"oui/non")) skip.
    put stream gsSortie unformatted "glPositionCritere = " + gformatteValeur(string(glPositionCritere,"oui/non")) skip.
    put stream gsSortie unformatted "glCouleursCritere = " + gformatteValeur(string(glCouleursCritere,"oui/non")) skip.
    put stream gsSortie unformatted fill("-",80) skip.
    put stream gsSortie unformatted "VARIABLES GLOBALES OUTILGI..." skip(1).
    put stream gsSortie unformatted "ser_outils = " + gformatteValeur(ser_outils) skip.
    put stream gsSortie unformatted "ser_outadb = " + gformatteValeur(ser_outadb) skip.
    put stream gsSortie unformatted "ser_outgest = " + gformatteValeur(ser_outgest) skip.
    put stream gsSortie unformatted "ser_outcadb = " + gformatteValeur(ser_outcadb) skip.
    put stream gsSortie unformatted "ser_outtrans = " + gformatteValeur(ser_outtrans) skip.
    put stream gsSortie unformatted "ser_appli = " + gformatteValeur(ser_appli) skip.
    put stream gsSortie unformatted "ser_appdev = " + gformatteValeur(ser_appdev) skip.
    put stream gsSortie unformatted "ser_tmp = " + gformatteValeur(ser_tmp) skip.
    put stream gsSortie unformatted "ser_log = " + gformatteValeur(ser_log) skip.
    put stream gsSortie unformatted "ser_intf = " + gformatteValeur(ser_intf) skip.
    put stream gsSortie unformatted "ser_dat = " + gformatteValeur(ser_dat) skip.
    put stream gsSortie unformatted "loc_outils = " + gformatteValeur(loc_outils) skip.
    put stream gsSortie unformatted "loc_outadb = " + gformatteValeur(loc_outadb) skip.
    put stream gsSortie unformatted "loc_outgest = " + gformatteValeur(loc_outgest) skip.
    put stream gsSortie unformatted "loc_outcadb = " + gformatteValeur(loc_outcadb) skip.
    put stream gsSortie unformatted "loc_outtrans = " + gformatteValeur(loc_outtrans) skip.
    put stream gsSortie unformatted "loc_appli = " + gformatteValeur(loc_appli) skip.
    put stream gsSortie unformatted "loc_appdev = " + gformatteValeur(loc_appdev) skip.
    put stream gsSortie unformatted "loc_tmp = " + gformatteValeur(loc_tmp) skip. 
    put stream gsSortie unformatted "loc_log = " + gformatteValeur(loc_log) skip.
    put stream gsSortie unformatted "loc_intf = " + gformatteValeur(loc_intf) skip.
    put stream gsSortie unformatted "RpOriGi = " + gformatteValeur(RpOriGi) skip.
    put stream gsSortie unformatted "RpDesGi = " + gformatteValeur(RpDesGi) skip.
    put stream gsSortie unformatted "RpOriadb = " + gformatteValeur(RpOriadb) skip.
    put stream gsSortie unformatted "RpDesadb = " + gformatteValeur(RpDesadb) skip.
    put stream gsSortie unformatted "RpOriges = " + gformatteValeur(RpOriges) skip. 
    put stream gsSortie unformatted "RpDesges = " + gformatteValeur(RpDesges) skip.
    put stream gsSortie unformatted "RpOricad = " + gformatteValeur(RpOricad) skip.
    put stream gsSortie unformatted "RpDescad = " + gformatteValeur(RpDescad) skip.
    put stream gsSortie unformatted "RpOritrf = " + gformatteValeur(RpOritrf) skip.
    put stream gsSortie unformatted "RpDestrf = " + gformatteValeur(RpDestrf) skip. 
    output stream gsSortie close.
    os-command no-wait value(cFichier).
    
end procedure.
