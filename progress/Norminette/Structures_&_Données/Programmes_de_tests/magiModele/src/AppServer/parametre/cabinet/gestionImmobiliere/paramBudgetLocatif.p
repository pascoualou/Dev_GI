/*------------------------------------------------------------------------
File        : paramBudgetLocatif.p
Purpose     : Paramétrage des budgets locatifs
Author(s)   : DMI 20180326
Notes       : à partir de adb/src/prmcl/pclbudlo.p
derniere revue: 2018/04/23 - phm. KO
          revoir les todo
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}
using parametre.pclie.parametrageBudgetLocatif.
using parametre.syspr.syspr.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{parametre/cabinet/gestionImmobiliere/include/modeleBudgetLocatif.i &nomtable=ttModeleBudgetaire &serialName=ttModeleBudgetaire}
{parametre/cabinet/gestionImmobiliere/include/paramBudgetLocatif.i &nomtable=ttParametreBudgetLocatif &serialName=ttParametreBudgetLocatif}
{bail/include/rubriqueQuitt.i &NomTable=ttRubriqueQuittExcBudget &SerialName=ttRubriqueQuittExcBudget}
{bail/include/rubriqueQuitt.i &NomTable=ttRubriqueQuittExcPresHT &SerialName=ttRubriqueQuittExcPresHT}
{compta/include/rubriqueAnalytique.i &NomTable=ttRubriqueAnaExcBudget &SerialName=ttRubriqueAnaExcBudget}
{compta/include/rubriqueAnalytique.i &NomTable=ttRubriqueAnaExcPresHT &SerialName=ttRubriqueAnaExcPresHT}
{adblib/include/cttac.i}
{application/include/combo.i}
{application/include/error.i}

define temp-table ttPresHTRubQuittExclue no-undo
    field tppar          as character initial "BUDL1"               serialize-hidden // uniquement pour le CRUD
    field zon01          as character initial "RUB"                 serialize-hidden // uniquement pour le CRUD
    field iNumeroModele  as integer   initial ?       label "zon07" format "999"
    field iCodeRubrique  as integer   initial ?       label "zon02" format "999"
    field lSelection     as logical   initial ?
    field dtTimestamp    as datetime
    field CRUD           as character
    field rRowid         as rowid
.
define temp-table ttPresHTRubAnaExclue no-undo
    field tppar             as character initial "BUDL1"               serialize-hidden // uniquement pour le CRUD
    field zon01             as character initial "ANA"                 serialize-hidden // uniquement pour le CRUD
    field iNumeroModele     as integer   initial ?       label "zon07" format "999"
    field iCodeRubrique     as integer   initial ?       label "zon02" format "999"
    field iCodeSousRubrique as integer   initial ?       label "zon03" format "999"
    field lSelection        as logical   initial ?
    field dtTimestamp       as datetime
    field CRUD              as character
    field rRowid            as rowid
.

procedure setCreationLien:
    /*------------------------------------------------------------------------------
    Purpose: Genere les liens cttac sur les mandats avec et sans indivision (genlietac)
    Notes  : Service externe appelé par beParametreGestionImmo.cls
    ------------------------------------------------------------------------------*/
    define input parameter table for ttError.

    define variable voBudgetLocatif as class parametrageBudgetLocatif no-undo.
    define variable vhCttac         as handle  no-undo.
    define variable vlBudgetLocatif as logical no-undo.
    define buffer ctrat for ctrat.

    empty temp-table ttCttac.
    assign
        voBudgetLocatif = new parametrageBudgetLocatif("000")      // Positionnement sur le paramètrage de base
        vlBudgetLocatif = voBudgetLocatif:isDbParameter and voBudgetLocatif:fgact = "YES"
    .
    delete object voBudgetLocatif.
    if not vlBudgetLocatif then return.

blocTransaction:
    do transaction:
        for first ctrat no-lock
            where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and can-find(first cttac no-lock
                               where cttac.tpcon = ctrat.tpcon
                                 and cttac.nocon = ctrat.nocon
                                 and cttac.tptac = {&TYPETACHE-budgetLocatif}):
            if outils:questionnaire(1000630, table ttError by-reference) <= 2 // 1000630 "Ouverture du module Budget Locatif déjà effectuée, Voulez-vous effectuer l'ouverture de la tâche Budget sur tous les mandats actifs ?").
                then undo blocTransaction, leave blocTransaction.
        end.
        for each ctrat no-lock
            where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and ctrat.dtree = ?              // Uniquement mandats actifs
              and not can-find(first cttac no-lock
                               where cttac.tpcon = ctrat.tpcon
                                 and cttac.nocon = ctrat.nocon
                                 and cttac.tptac = {&TYPETACHE-budgetLocatif}):
            create ttCttac.
            assign
                ttCttac.tpcon = ctrat.tpcon
                ttCttac.nocon = ctrat.nocon
                ttCttac.tptac = {&TYPETACHE-budgetLocatif}
                ttCttac.CRUD  = "C"
            .
        end.
        if can-find(first ttCttac) then do:
            run adblib/cttac_CRUD.p persistent set vhCttac.
            run getTokenInstance in vhCttac(mToken:JSessionId).
            run setCttac in vhCttac(table ttCttac by-reference).
            run destroy in vhCttac.
        end.
    end.
end procedure.

procedure initCombo:
    /*------------------------------------------------------------------------------
    Purpose: Chargement combo
    Notes  : Service externe appelé par beParametreGestionImmo.cls
    ------------------------------------------------------------------------------*/
    define output parameter table for ttCombo.

    define variable voSyspr            as class syspr no-undo.
    define variable vhProcModeleBudget as handle      no-undo.

    empty temp-table ttCombo.
    voSyspr = new syspr().
    // Modele budget
    voSyspr:creationttCombo("CMBMODELEBUDGET", string(0,"999"), "Modèle de base", output table ttCombo by-reference).
    run parametre/cabinet/gestionImmobiliere/modeleBudgetLocatif.p persistent set vhProcModeleBudget.
    run getTokenInstance in vhProcModeleBudget(mToken:JSessionId).
    run getModeleBudgetaire in vhProcModeleBudget(?, output table ttModeleBudgetaire).
    run destroy in vhProcModeleBudget.
    for each ttModeleBudgetaire:
        voSyspr:creationttCombo("CMBMODELEBUDGET", string(ttModeleBudgetaire.iNumeroModele,"999"), ttModeleBudgetaire.cLibelleModele, output table ttCombo by-reference).
    end.
    // Reprise du solde
    voSyspr:creationttCombo("CMBREPRISESOLDE", ""   , "", output table ttCombo by-reference).
    voSyspr:creationttCombo("CMBREPRISESOLDE", "P"  , "P"  , output table ttCombo by-reference).
    voSyspr:creationttCombo("CMBREPRISESOLDE", "M"  , "M"  , output table ttCombo by-reference).
    voSyspr:creationttCombo("CMBREPRISESOLDE", "M+P", "M+P", output table ttCombo by-reference).
    voSyspr:creationttCombo("CMBREPRISESOLDE", outilTraduction:getLibelle(110233), outilTraduction:getLibelle(110233), output table ttCombo by-reference). // 110233 Simulation CRG
    delete object voSyspr.
    error-status:error = false no-error.  // reset error-status
    return.

end procedure.

procedure getParametrageBudgetLocatif:
    /*------------------------------------------------------------------------------
    Purpose: chargement du paramétrage budget locatif
    Notes  : Service externe appelé par beParametreGestionImmo.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piModeleBudgetaire as integer no-undo.
    define output parameter table for ttParametreBudgetLocatif.
    define output parameter table for ttRubriqueQuittExcPresHT.
    define output parameter table for ttRubriqueAnaExcPresHT.
    define output parameter table for ttRubriqueQuittExcBudget.
    define output parameter table for ttRubriqueAnaExcBudget.

    define variable voBudgetLocatif     as class parametrageBudgetLocatif no-undo.
    define variable viRubrique          as integer   no-undo.
    define variable viSousRubrique      as integer   no-undo.
    define variable viI1                as integer   no-undo.
    define variable vcRubSsRub          as character no-undo.
    define variable vlBudgetLocatif     as logical   no-undo.
    define variable vhProcRubriqueQuitt as handle    no-undo.
    define variable vhProcRubriqueAna   as handle    no-undo.
    define variable vhProcPclie         as handle    no-undo.

    assign
        voBudgetLocatif = new parametrageBudgetLocatif("000")        // Positionnement sur le paramètrage de base
        vlBudgetLocatif = voBudgetLocatif:isDbParameter and voBudgetLocatif:fgact = "YES"
    .
    delete object voBudgetLocatif.
    if not vlBudgetLocatif then do:
        merror:createError({&error}, 1000620). //  1000620 "Le module optionel Budget locatif n'est pas activé"
        return.
    end.

    empty temp-table ttParametreBudgetLocatif.
    run adblib/pclie_CRUD.p persistent set vhProcPclie.
    run getTokenInstance in vhProcPclie(mToken:JSessionId).
    run getPclieZon07 in vhProcPclie("BUDLO", string(piModeleBudgetaire,"999"), table ttParametreBudgetLocatif by-reference).
    run destroy in vhProcPclie.

    for first ttParametreBudgetLocatif:
        // Extraction de la liste des rubriques analytiques à exclure du budget
        empty temp-table ttRubriqueAnaExcBudget.
        run compta/rubriqueAnalytique.p persistent set vhProcRubriqueAna.
        run getTokenInstance       in vhProcRubriqueAna(mToken:JSessionId).
        run getRubriqueAnalytique  in vhProcRubriqueAna({&TYPECONTRAT-mandat2Gerance}, "", "", output table ttRubriqueAnaExcBudget).
        run destroy in vhProcRubriqueAna.
boucle:
        do viI1 =  1 to num-entries(ttParametreBudgetLocatif.cListeExclusionAnalytique):
            assign
                vcRubSsRub     = entry(viI1, ttParametreBudgetLocatif.cListeExclusionAnalytique)
                viRubrique     = integer(entry(1, vcRubSsRub, "-"))
                viSousRubrique = integer(entry(2, vcRubSsRub, "-"))
            no-error.
            if error-status:error then next boucle.

            for first ttRubriqueAnaExcBudget
                where ttRubriqueAnaExcBudget.iCodeRubrique     = viRubrique
                  and ttRubriqueAnaExcBudget.iCodeSousRubrique = viSousRubrique:
                ttRubriqueAnaExcBudget.lSelection = true.
            end.
        end.
        // Extraction de la liste des rubriques de quittancement à exclure du budget
        empty temp-table ttRubriqueQuittExcBudget.
        run bail/quittancement/rubriqueQuitt.p persistent set vhProcRubriqueQuitt.
        run getTokenInstance          in vhProcRubriqueQuitt (mToken:JSessionId).
        run getListeRubriqueAutorisee in vhProcRubriqueQuitt ("", "", output table ttRubriqueQuittExcBudget).
        run destroy in vhProcRubriqueQuitt.
boucle:
        do viI1 =  1 to num-entries(ttParametreBudgetLocatif.cListeExclusionQuittancement) :
            assign
                viRubrique = integer(entry(viI1, ttParametreBudgetLocatif.cListeExclusionQuittancement))
            no-error.
            if error-status:error then next boucle.

            for first ttRubriqueQuittExcBudget
                where ttRubriqueQuittExcBudget.iCodeRubrique = viRubrique:
                ttRubriqueQuittExcBudget.lSelection = true.
            end.
        end.
        // Extraction de la liste des rubriques quittancement TVA exclues de la présentation HT
        empty temp-table ttRubriqueQuittExcPresHT.
        run bail/quittancement/rubriqueQuitt.p persistent set vhProcRubriqueQuitt.
        run getTokenInstance          in vhProcRubriqueQuitt (mToken:JSessionId).
        run getListeRubriqueAutorisee in vhProcRubriqueQuitt ("00001:00003", "00000:00001:00002:00003:00004:00005:00006:00007", output table ttRubriqueQuittExcPresHT).
        run destroy in vhProcRubriqueQuitt.

        run adblib/pclie_CRUD.p persistent set vhProcPclie.
        run getTokenInstance in vhProcPclie(mToken:JSessionId).
        run getPclieZon01Zon07 in vhProcPclie("BUDL1", "RUB", string(ttParametreBudgetLocatif.iNumeroModele,"999"), table ttPresHTRubQuittExclue by-reference).
        run destroy in vhProcPclie.
        for each ttPresHTRubQuittExclue
          , first ttRubriqueQuittExcPresHt
            where ttRubriqueQuittExcPresht.iCodeRubrique = ttPresHTRubQuittExclue.iCodeRubrique:
            ttRubriqueQuittExcPresHt.lSelection = true.
        end.
        // Extraction de la liste des rubriques analytiques TVA exclues de la présentation HT
        empty temp-table ttRubriqueAnaExcPresHT.
        run compta/rubriqueAnalytique.p persistent set vhProcRubriqueAna.
        run getTokenInstance       in vhProcRubriqueAna (mToken:JSessionId).
        run getRubriqueAnalytique  in vhProcRubriqueAna ({&TYPECONTRAT-mandat2Gerance}, "", "", output table ttRubriqueAnaExcPresHT).
        run destroy in vhProcRubriqueAna.

        empty temp-table ttPresHTRubAnaExclue.
        run adblib/pclie_CRUD.p persistent set vhProcPclie.
        run getTokenInstance in vhProcPclie(mToken:JSessionId).
        run getPclieZon01Zon07 in vhProcPclie("BUDL1", "ANA", string(ttParametreBudgetLocatif.iNumeroModele,"999"), table ttPresHTRubAnaExclue by-reference).
        run destroy in vhProcPclie.
        for each ttPresHTRubAnaExclue
          , first ttRubriqueAnaExcPresHT
            where ttRubriqueAnaExcPresHT.iCodeRubrique     = ttPresHTRubAnaExclue.iCodeRubrique
              and ttRubriqueAnaExcPresHT.iCodeSousRubrique = ttPresHTRubAnaExclue.iCodeSousRubrique:
            ttRubriqueAnaExcPresHT.lSelection = true.
        end.
    end.
    error-status:error = false no-error.  // reset error-status
    return.

end procedure.

procedure setParametrageBudgetLocatif:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttParametreBudgetLocatif.
    define input parameter table for ttRubriqueQuittExcPresHT.
    define input parameter table for ttRubriqueAnaExcPresHT.
    define input parameter table for ttRubriqueQuittExcBudget.
    define input parameter table for ttRubriqueAnaExcBudget.

    define variable vhProcPclie as handle no-undo.

blocTransaction:
    do transaction:
        {&_proparse_ prolint-nowarn(allfinds)}
        find ttParametreBudgetLocatif
            where lookup(ttParametreBudgetLocatif.CRUD, "C,U,D") > 0 no-error. // find unique
        if ambiguous ttParametreBudgetLocatif then do:
            mError:createError({&error}, 1000628, "ttParametreBudgetLocatif"). // 1000628 "Plusieurs enregistrements de [&1], mise à jour impossible"
            undo blocTransaction, leave blocTransaction.
        end.
        if not available ttParametreBudgetLocatif then leave blocTransaction.

        if ttParametreBudgetLocatif.iNumeroModele = 0 and ttParametreBudgetLocatif.CRUD = "D" then do:
            mError:createError({&error}, 1000629). // 1000629 "La suppression du paramètrage du modèle de base est interdite !"
            undo blocTransaction, leave blocTransaction.
        end.
        // Liste des analytiques exclues du budget
        ttParametreBudgetLocatif.cListeExclusionAnalytique = "".
        for each ttRubriqueAnaExcBudget where ttRubriqueAnaExcBudget.lSelection:
            ttParametreBudgetLocatif.cListeExclusionAnalytique = substitute("&1,&2-&3"
                                                                          , ttParametreBudgetLocatif.cListeExclusionAnalytique
                                                                          , string(ttRubriqueAnaExcBudget.iCodeRubrique,"999")
                                                                          , string(ttRubriqueAnaExcBudget.iCodeSousRubrique,"999")).
        end.
        assign
            ttParametreBudgetLocatif.cListeExclusionAnalytique    = trim(ttParametreBudgetLocatif.cListeExclusionAnalytique,",")
            ttParametreBudgetLocatif.cListeExclusionQuittancement = ""            // liste rubriques quittancement exclues du budget
        .
        for each ttRubriqueQuittExcBudget where ttRubriqueQuittExcBudget.lSelection :
            ttParametreBudgetLocatif.cListeExclusionQuittancement = substitute("&1,&2"
                                                                             , ttParametreBudgetLocatif.cListeExclusionQuittancement
                                                                             , string(ttRubriqueQuittExcBudget.iCodeRubrique,"999")).
        end.
        ttParametreBudgetLocatif.cListeExclusionQuittancement = trim(ttParametreBudgetLocatif.cListeExclusionQuittancement,",").
        // Maj Rubrique quittancement exclue de la présentation HT
        empty temp-table ttPresHTRubQuittExclue.
        run adblib/pclie_CRUD.p persistent set vhProcPclie.
        run getTokenInstance in vhProcPclie(mToken:JSessionId).
        run getPclieZon01Zon07 in vhProcPclie("BUDL1", "RUB", string(ttParametreBudgetLocatif.iNumeroModele,"999"), table ttPresHTRubQuittExclue by-reference).
        if ttParametreBudgetLocatif.crud = "D"
        then for each ttPresHTRubQuittExclue where ttPresHTRubQuittExclue.iNumeroModele = ttParametreBudgetLocatif.iNumeroModele :
            ttPresHTRubQuittExclue.crud = "D".
        end.
        else for each ttRubriqueQuittExcPresHT where ttRubriqueQuittExcPresHT.crud = "U":
            find first ttPresHTRubQuittExclue
                 where ttPresHTRubQuittExclue.iCodeRubrique = ttRubriqueQuittExcPresHT.iCodeRubrique
                   and ttPresHTRubQuittExclue.iNumeroModele = ttParametreBudgetLocatif.iNumeroModele no-error.
            if not available ttPresHTRubQuittExclue and ttRubriqueQuittExcPresHT.lSelection then do:
                create ttPresHTRubQuittExclue.
                assign
                    ttPresHTRubQuittExclue.iNumeroModele  = ttParametreBudgetLocatif.iNumeroModele
                    ttPresHTRubQuittExclue.iCodeRubrique  = ttRubriqueQuittExcPresHT.iCodeRubrique
                    ttPresHTRubQuittExclue.CRUD           = "C"
                .
            end.
            else if available ttPresHTRubQuittExclue and ttRubriqueQuittExcPresHT.lSelection <> true
            then assign ttPresHTRubQuittExclue.CRUD   = "D".
        end.
        run setPclie in vhProcPclie(table ttPresHTRubQuittExclue by-reference).
        run destroy in vhProcPclie.
        // Maj Rubrique analytique exclue de la présentation HT
        empty temp-table ttPresHTRubAnaExclue.
        run adblib/pclie_CRUD.p persistent set vhProcPclie.
        run getTokenInstance in vhProcPclie(mToken:JSessionId).
        run getPclieZon01Zon07 in vhProcPclie("BUDL1", "ANA", string(ttParametreBudgetLocatif.iNumeroModele,"999"), table ttPresHTRubAnaExclue by-reference).
        if ttParametreBudgetLocatif.crud = "D"
        then for each ttPresHTRubAnaExclue
            where ttPresHTRubAnaExclue.iNumeroModele = ttParametreBudgetLocatif.iNumeroModele:
            ttPresHTRubAnaExclue.crud = "D".
        end.
        else for each ttRubriqueAnaExcPresHT where ttRubriqueAnaExcPresHT.crud = "U":
            find first ttPresHTRubAnaExclue
                 where ttPresHTRubAnaExclue.iCodeRubrique     = ttRubriqueAnaExcPresHT.iCodeRubrique
                   and ttPresHTRubAnaExclue.iCodeSousRubrique = ttRubriqueAnaExcPresHT.iCodeSousRubrique
                   and ttPresHTRubAnaExclue.iNumeroModele     = ttParametreBudgetLocatif.iNumeroModele no-error.
            if not available ttPresHTRubAnaExclue and ttRubriqueAnaExcPresHT.lSelection then do:
                create ttPresHTRubAnaExclue.
                assign
                    ttPresHTRubAnaExclue.iNumeroModele     = ttParametreBudgetLocatif.iNumeroModele
                    ttPresHTRubAnaExclue.iCodeRubrique     = ttRubriqueAnaExcPresHT.iCodeRubrique
                    ttPresHTRubAnaExclue.iCodeSousRubrique = ttRubriqueAnaExcPresHT.iCodeSousRubrique
                    ttPresHTRubAnaExclue.CRUD              = "C"
                .
            end.
            else if available ttPresHTRubAnaExclue and ttRubriqueAnaExcPresHT.lSelection <> true
            then assign ttPresHTRubAnaExclue.CRUD   = "D".
        end.
        run setPclie in vhProcPclie(table ttPresHTRubAnaExclue by-reference).
        run destroy in vhProcPclie.
        // Maj Parametrage budget
        run adblib/pclie_CRUD.p persistent set vhProcPclie.
        run getTokenInstance in vhProcPclie(mToken:JSessionId).
        run setPclie in vhProcPclie(table ttParametreBudgetLocatif by-reference).
        run destroy in vhProcPclie.
    end.
    error-status:error = false no-error.  // reset error-status
    return.
end procedure.
