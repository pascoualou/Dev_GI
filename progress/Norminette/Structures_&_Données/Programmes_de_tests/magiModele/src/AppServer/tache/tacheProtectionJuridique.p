/*-----------------------------------------------------------------------------
File        : tacheProtectionJuridique.p
Purpose     : Bail - Tache Protection Juridique
Author(s)   : SPo  -  04/19/2018
Notes       : a partir de  adb\src\tach\prmobpju.p
derniere revue: 2018/04/24 - phm: KO
derniers correctifs : 2018/04/24 SPo
-----------------------------------------------------------------------------*/
{preprocesseur/categorie2bail.i}
{preprocesseur/type2bareme.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}

using parametre.syspg.syspg.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{adblib/include/cttac.i}
{application/include/glbsepar.i}
{tache/include/tacheProtectionJuridique.i}

procedure rechercheInfosContrat private:
    /*------------------------------------------------------------------------------
    Purpose: recherche tous les infos du contrat bail/prebail dont on a besoin
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as int64     no-undo.
    define output parameter poCollection    as class collection no-undo.

    define variable vdaDateDebutContrat    as date      no-undo.
    define variable vdaDateFinContrat      as date      no-undo.
    define variable vcCodeNatureContrat    as character no-undo.
    define variable vcCodeCategorieContrat as character no-undo.
    define variable vcTypeBareme           as character no-undo.
    define variable vlBailExiste           as logical   no-undo.
    define variable voSysPg                as class syspg no-undo.

    define buffer ctrat for ctrat.

    for first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat:
        assign
            vlBailExiste = true
            vdaDateDebutContrat = if ctrat.dtini = ? then ctrat.dtdeb else ctrat.dtini
            vdaDateFinContrat   = ctrat.dtfin
            vcCodeNatureContrat = ctrat.ntcon
        .
    end.
    assign
        voSysPg      = new syspg()
        poCollection = new collection()
    .
    voSyspg:reloadZone2("R_CBA", vcCodeNatureContrat).
    assign
        vcCodeCategorieContrat = voSyspg:zone1
        vcTypeBareme           = if vcCodeCategorieContrat = {&CATEGORIE2BAIL-Habitation} then {&TYPEBAREME-Habitation} else {&TYPEBAREME-Commercial}
    .
    delete object voSysPg.
    poCollection:set("lBailExiste",           vlBailExiste).
    poCollection:set("daDateDebutContrat",    vdaDateDebutContrat).
    poCollection:set("daDateFinContrat",      vdaDateFinContrat).
    poCollection:set("cCodeNatureContrat",    vcCodeNatureContrat).
    poCollection:set("cCodeCategorieContrat", vcCodeCategorieContrat).
    poCollection:set("cTypeBareme",           vcTypeBareme).

end procedure.

procedure getProtectionJuridiqueBail:
    /*------------------------------------------------------------------------------
    Purpose: Lecture de la tâche protection Juridique du bail (tache facultative)
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat               as character no-undo.
    define input  parameter piNumeroContrat             as int64     no-undo.
    define output parameter table for ttTacheProtectionJuridique.

    define variable voCollectionContrat as class collection no-undo.
    define buffer tache for tache.

    empty temp-table ttTacheProtectionJuridique.
    // Besoin infos contrat
    if not can-find(first ctrat no-lock
                    where ctrat.tpcon = pcTypeContrat
                      and ctrat.nocon = piNumeroContrat) then do:
        mError:createError({&error}, 100057).
        return.
    end.
    run rechercheInfosContrat(pcTypeContrat, piNumeroContrat, output voCollectionContrat).
    for last tache no-lock
        where tache.tpcon = pcTypeContrat
          and tache.nocon = piNumeroContrat
          and tache.tptac = {&TYPETACHE-ProtectionJuridique}:
        create ttTacheProtectionJuridique.
        outils:copyValidField(buffer tache:handle, buffer ttTacheProtectionJuridique:handle).
        ttTacheProtectionJuridique.cTypeBareme = voCollectionContrat:getCharacter('cTypeBareme').
    end.
    delete object voCollectionContrat.
end procedure.

procedure initProtectionJuridiqueBail:
    /*------------------------------------------------------------------------------
    Purpose: Initialisation tache Protection juridique
    Notes  : service appelé par beBail.cls
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as int64     no-undo.
    define output parameter table for ttTacheProtectionJuridique.

    define variable voCollectionContrat as class collection no-undo.
    define variable viNumeroPJuDefaut   as integer   no-undo.
    define buffer tache     for tache.

    empty temp-table ttTacheProtectionJuridique.
    if lookup(pcTypeContrat, substitute("&1,&2", {&TYPECONTRAT-bail}, {&TYPECONTRAT-preBail})) = 0 then do:
        mError:createError({&error}, 1000661, substitute('&2&1&3', separ[1], pcTypeContrat, outilTraduction:getLibelleProg ("O_TAE", {&TYPETACHE-ProtectionJuridique}))).   // le type de contrat &1 n'est pas autorisé pour la tâche &2
        return.
    end.
    if can-find(first tache no-lock
                where tache.tpcon = pcTypeContrat
                  and tache.nocon = piNumeroContrat
                  and tache.tptac = {&TYPETACHE-ProtectionJuridique}) then do:
        mError:createError({&error}, 1000410).          // demande d'initialisation d'une tache existante
        return.
    end.
    run rechercheInfosContrat(pcTypeContrat, piNumeroContrat, output voCollectionContrat).
    if voCollectionContrat:getLogical('lBailExiste') = false then do:
        mError:createError({&error}, 1000209, string(piNumeroContrat)).
        delete object voCollectionContrat.
        return.
    end.

    for last tache no-lock     // rechercher si paramétrage Assurances loyer du mandat
        where tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and tache.nocon = integer(truncate(piNumeroContrat / 100000, 0))
          and tache.tptac = {&TYPETACHE-AssurancesLoyer}:
        if voCollectionContrat:getCharacter('cCodeCategorieContrat') = {&CATEGORIE2BAIL-Habitation}
        then viNumeroPJuDefaut = integer(tache.dcreg).    // PJu Habitation
        else viNumeroPJuDefaut = integer(tache.pdreg).    // PJu Commercial
    end.

    create ttTacheProtectionJuridique.
    assign
        ttTacheProtectionJuridique.iNumeroTache               = 0
        ttTacheProtectionJuridique.cTypeContrat               = pcTypeContrat
        ttTacheProtectionJuridique.iNumeroContrat             = piNumeroContrat
        ttTacheProtectionJuridique.cTypeTache                 = {&TYPETACHE-ProtectionJuridique}
        ttTacheProtectionJuridique.iChronoTache               = 0
        ttTacheProtectionJuridique.daActivation               = today
        ttTacheProtectionJuridique.cTypeBareme                = voCollectionContrat:getCharacter('cTypeBareme')
        ttTacheProtectionJuridique.cNumeroProtectionJuridique = (if viNumeroPJuDefaut > 0 then string(viNumeroPJuDefaut)  else "0")
        ttTacheProtectionJuridique.CRUD                       = 'C'
    .
    delete object voCollectionContrat.
end procedure.

procedure setProtectionJuridiqueBail:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTacheProtectionJuridique.

    run ctrlAvantMaj.
    if mError:erreur() then return.
    run majTacheProtectionJuridique.
end procedure.

procedure ctrlAvantMaj private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable voCollectionContrat as class collection no-undo.
    define variable viNombreCreate      as integer   no-undo.
    define buffer garan for garan.

boucleCtrlAvantMaj:
    for each ttTacheProtectionJuridique
        where lookup(ttTacheProtectionJuridique.CRUD, "C,U") > 0:
        if ttTacheProtectionJuridique.CRUD = "C" then do:
            viNombreCreate = viNombreCreate + 1.
            // Il ne doit y avoir q'un seul enregistrement tache pour cette tache
            if can-find(first tache no-lock
                        where tache.tpcon = ttTacheProtectionJuridique.cTypeContrat
                          and tache.nocon = ttTacheProtectionJuridique.iNumeroContrat
                          and tache.tptac = {&TYPETACHE-ProtectionJuridique})
            then mError:createError({&error}, 1000410).                             // demande d'initialisation d'une tache existante
            else if viNombreCreate > 1 then mError:createError({&error}, 1000589).  // Vous ne pouvez traiter en maj qu'un enregistrement à la fois
        end.
        if mError:erreur() then leave boucleCtrlAvantMaj.

        // Recherche de tous les paramètres dont on a besoin
        run rechercheInfosContrat(ttTacheProtectionJuridique.cTypeContrat, ttTacheProtectionJuridique.iNumeroContrat, output voCollectionContrat).
        if voCollectionContrat:getLogical('lBailExiste') = false     // Le contrat doit exister
        then mError:createError({&error}, 1000209, string(ttTacheProtectionJuridique.iNumeroContrat)).
        else if ttTacheProtectionJuridique.iNumeroBareme = ? or ttTacheProtectionJuridique.iNumeroBareme = 0
        then mError:createError({&error}, 107724).                   // Le barème est obligatoire
        else if not can-find(first garan no-lock                     // Le numéro de barème doit exister
                             where garan.tpctt = {&TYPECONTRAT-ProtectionJuridique}
                               and garan.noctt = integer(ttTacheProtectionJuridique.cNumeroProtectionJuridique)
                               and garan.tpbar = ttTacheProtectionJuridique.cTypeBareme
                               and garan.nobar = ttTacheProtectionJuridique.iNumeroBareme)
        then mError:createError({&error}, 1000370, string(ttTacheProtectionJuridique.iNumeroBareme)).
        else if can-find(first garan no-lock                         // Le barème doit être non nul
                         where garan.tpctt = {&TYPECONTRAT-ProtectionJuridique}
                           and garan.noctt = integer(ttTacheProtectionJuridique.cNumeroProtectionJuridique)
                           and garan.tpbar = ttTacheProtectionJuridique.cTypeBareme
                           and garan.nobar = ttTacheProtectionJuridique.iNumeroBareme
                           and garan.mtcot = 0
                           and garan.txcot = 0
                           and garan.txhon = 0)
        then mError:createError({&error}, 106985).
        else if ttTacheProtectionJuridique.daActivation = ?         // mise à jour champ masqué
        then ttTacheProtectionJuridique.daActivation = today.
    end.
end procedure.

procedure majTacheProtectionJuridique private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhProcTache as handle no-undo.
    define variable vhProcCttac as handle no-undo.
    define buffer cttac for cttac.

    empty temp-table ttCttac.
    for each ttTacheProtectionJuridique
        where ttTacheProtectionJuridique.CRUD = "D"
      , each cttac no-lock
        where cttac.tpcon = ttTacheProtectionJuridique.cTypeContrat
          and cttac.nocon = ttTacheProtectionJuridique.iNumeroContrat
          and cttac.tptac = {&TYPETACHE-ProtectionJuridique}:
        create ttCttac.
        assign
            ttCttac.tpcon       = cttac.tpcon
            ttCttac.nocon       = cttac.nocon
            ttCttac.tptac       = cttac.tptac
            ttCttac.CRUD        = "D"
            ttCttac.rRowid      = rowid(cttac)
            ttCttac.dtTimestamp = datetime(cttac.dtmsy, cttac.hemsy)
        .
    end.
    for each ttTacheProtectionJuridique
        where lookup(ttTacheProtectionJuridique.CRUD, "C,U") > 0
        and not can-find(first cttac no-lock
                         where cttac.tpcon = ttTacheProtectionJuridique.cTypeContrat
                           and cttac.nocon = ttTacheProtectionJuridique.iNumeroContrat
                           and cttac.tptac = {&TYPETACHE-ProtectionJuridique}):
        create ttCttac.
        assign
            ttCttac.tpcon = ttTacheProtectionJuridique.cTypeContrat
            ttCttac.nocon = ttTacheProtectionJuridique.iNumeroContrat
            ttCttac.tptac = {&TYPETACHE-ProtectionJuridique}
            ttCttac.CRUD  = "C"
        .
    end.
    run tache/tache.p persistent set vhProcTache.
    run getTokenInstance in vhProcTache(mToken:JSessionId).
    run setTache in vhProcTache(table ttTacheProtectionJuridique by-reference).
    run destroy in vhProcTache.
    if not mError:erreur() and can-find(first ttCttac) then do:
        run adblib/cttac_CRUD.p persistent set vhProcCttac.
        run getTokenInstance in vhProcCttac(mToken:JSessionId).
        run setCttac in vhProcCttac(table ttCttac by-reference).
        run destroy in vhProcCttac.
    end.

end procedure.
