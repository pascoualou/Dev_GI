/*------------------------------------------------------------------------
File        : service.i
Purpose     :
Author(s)   : Kantena - 2018/06/12
Notes       :
derniere revue: 2018/06/18 - phm: KO
        les variables vcPied, vcEntete, vcLogo, viGestionnaire ne servent pas !?
        La procédure ne sert à rien !?
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}

function donneNumeroServiceContrat returns integer private (pcTypeContrat as character, piNumeroContrat as integer):
    /*------------------------------------------------------------------------------
    Purpose: Retourne le numero du service à partir d'un type et numero de contrat
    Notes  :
    todo : fonction dupliquée dans lot.p
    ------------------------------------------------------------------------------*/
    define variable vcTypePrincipal   as character no-undo.
    define variable viNumeroPrincipal as integer   no-undo.
    define variable viNumeroService   as integer   no-undo.

    define buffer ctctt for ctctt.

    if pcTypeContrat = {&TYPECONTRAT-mandat2Gerance} or pcTypeContrat = {&TYPECONTRAT-mandat2Syndic}
    then assign
        vcTypePrincipal   = pcTypeContrat
        viNumeroPrincipal = piNumeroContrat
    .
    else do:
        /* Recherche du type de contrat maitre */
        find first ctctt no-lock
            where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}  /* Rattaché à la copro */
              and ctctt.tpct2 = pcTypeContrat
              and ctctt.noct2 = piNumeroContrat no-error.
        if not available ctctt
        then find first ctctt no-lock
            where ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}  /* Rattaché à la gérance */
              and ctctt.tpct2 = pcTypeContrat
              and ctctt.noct2 = piNumeroContrat no-error.
        if available ctctt
        then assign              /* Mémorisation du contrat principal */
            vcTypePrincipal   = ctctt.tpct1
            viNumeroPrincipal = ctctt.noct1
        .
    end.
    /* Recherche du lien entre le contrat "Service de gestion"  et le contrat principal */
    for last ctctt no-lock
        where ctctt.tpct1 = {&TYPECONTRAT-serviceGestion}
          and ctctt.tpct2 = vcTypePrincipal
          and ctctt.noct2 = viNumeroPrincipal:
        viNumeroService = ctctt.noct1.
    end.
    return viNumeroService.

end function.

procedure service private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeMandat   as character no-undo.
    define input parameter piNumeroMandat as int64     no-undo.

    define output parameter piGestionnaire as integer   no-undo.
    define output parameter pcLogo         as character no-undo.
    define output parameter pcEntete       as character no-undo.
    define output parameter pcPied         as character no-undo.

    define buffer tbent for tbent.
    define buffer ctctt for ctctt.
    define buffer ctrat for ctrat.
    define buffer tache for tache.

    /* NP pour PL 0112/0057 */
    /* Il faut commencer par rechercher les info du cabinet au cas ou pas de gestionnaire */
    for first tbent no-lock
        where tbent.cdent = "00003"
          and tbent.iden1 = "00001": /* Pied */
        pcPied = tbent.iden2.
    end.
    for first tbent no-lock
        where tbent.cdent = "00003"
          and tbent.iden1 = "00002": /* Entete */
        pcEntete = tbent.iden2.
    end.
    for first tbent no-lock
        where tbent.cdent = "00003"
          and tbent.iden1 = "00003": /* logo */
        pcLogo = tbent.iden2.
    end.
    /* Recherche du Gestionnaire */
    for first ctctt no-lock
        where ctctt.tpct1 = {&TYPECONTRAT-serviceGestion}
          and ctctt.tpct2 = pcTypeMandat
          and ctctt.noct2 = piNumeroMandat
      , first ctrat no-lock
        where ctrat.tpcon = ctctt.tpct1
          and ctrat.nocon = ctctt.noct1:
        piGestionnaire = ctrat.norol.
        /* Recherche du Sigle du Service */
        for first tache no-lock
            where tache.tpcon = ctrat.tpcon
              and tache.nocon = ctrat.nocon
              and tache.tptac = {&TYPETACHE-Sigle}:
            if num-entries(tache.lbdiv, SEPAR[1]) = 3 
            then assign
                pcLogo      = entry(3, tache.lbdiv, SEPAR[1])
                pcEntete    = entry(2, tache.lbdiv, SEPAR[1])
                pcPied      = entry(1, tache.lbdiv, SEPAR[1])
            .
        end.
    end.
    /* Recherche du sigle du Mandat */
    for first tache no-lock
        where tache.tpcon = pcTypeMandat
          and tache.nocon = piNumeroMandat
          and tache.tptac = {&TYPETACHE-Sigle}:
        if num-entries(tache.lbdiv, SEPAR[1]) = 3
        then assign
            pcLogo   = entry(3, tache.lbdiv, SEPAR[1])
            pcEntete = entry(2, tache.lbdiv, SEPAR[1])
            pcPied   = entry(1, tache.lbdiv, SEPAR[1])
        .
    end.
/*    MLog("Service.i - Recherche Sigle/Entete/Pied/Logo : "*/
/*        + "%s NoLogUse = " + STRING(NoLogUse)             */
/*        + "%s NoEntUse = " + STRING(NoEntUse)             */
/*        + "%s NoPieUse = " + STRING(NoPieUse)             */
/*        ).                                                */

end procedure.

