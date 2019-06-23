/*-----------------------------------------------------------------------------
File        : tacheVacanceLocative.p
Purpose     : Bail - Tache Vacance Locative
Author(s)   : npo  -  2018/03/19
Notes       : a partir de  adb\src\tach\prmobcar.p
derniere revue: 2018/05/24 - phm: OK
-----------------------------------------------------------------------------*/
{preprocesseur/categorie2bail.i}
{preprocesseur/type2bareme.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}

using parametre.syspg.syspg.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{adblib/include/cttac.i}
{application/include/combo.i}
{application/include/error.i}
{application/include/glbsepar.i}
{bail/include/outilbail.i}
{tache/include/tacheVacanceLocative.i}

function getBaremeParVacance returns integer():
    /*------------------------------------------------------------------------
    Purpose :
    Notes   : Attention, loadBaremes doit être lancé avant!
    ------------------------------------------------------------------------*/
    define variable viNumeroVacanceLocative as integer no-undo.
    for first ttBaremeVacanceLocative: viNumeroVacanceLocative = ttBaremeVacanceLocative.iNumeroContrat. end.
    for first ttBaremeVacanceLocative
        where ttBaremeVacanceLocative.dTauxCotisation <> 0
           or ttBaremeVacanceLocative.dTauxHonoraire <> 0
           or ttBaremeVacanceLocative.iNumeroBareme = viNumeroVacanceLocative:
        return ttBaremeVacanceLocative.iNumeroBareme.
    end.
    return 0.
end function.

function isCalculAPartirDateApplication returns character(piNumeroVacanceLocative as integer):
    /*------------------------------------------------------------------------
    Purpose : détermine s'il faut gérer la date d'application pour démarrer le
    Notes   : calcul de la vacance locative
    ------------------------------------------------------------------------*/
    define buffer garan for garan.

    for first garan no-lock
        where garan.tpctt = {&TYPECONTRAT-VacanceLocative}
          and garan.noctt = piNumeroVacanceLocative
          and garan.tpbar = ""
          and garan.nobar = 0:
        return (if garan.cddebcal > "" then garan.cddebcal else "00002").
    end.
    return ''.
end function.

function donneDateApplicationMinimum returns date(piNumeroContrat as int64, piMsQttNxtCLo-Deb as integer):
    /*------------------------------------------------------------------------
    Purpose : recherche la date d'application minimum en fonction du prochain
    Notes   : traitement de garantie loyer
    ------------------------------------------------------------------------*/
    define variable vDateApplicationMin as date no-undo.

    define buffer aquit for aquit.
    define buffer equit for equit.

    {&_proparse_ prolint-nowarn(use-index)}
    for each aquit no-lock
        where aquit.noloc  = piNumeroContrat
          and aquit.msqtt >= piMsQttNxtCLo-Deb
          and aquit.fgfac  = no
        use-index ix_aquit10:    // sinon ix_aquit08
        vDateApplicationMin = aquit.dtdeb.
    end.
    if vDateApplicationMin = ?
    then for first equit no-lock
        where equit.noloc  = piNumeroContrat
          and equit.msqtt >= piMsQttNxtCLo-Deb:
        vDateApplicationMin = equit.dtdeb.
    end.
    return vDateApplicationMin.
end function.

function donneMoisQuittTraitementVacance returns integer(piNumeroContrat as int64, pdaDateApplication as date):
    /*------------------------------------------------------------------------
    Purpose : calcul du mois de quitt de traitement de la garantie
    Notes   :
    ------------------------------------------------------------------------*/
    define variable viMoisQuitt         as integer   no-undo.
    define variable vhProcBareme        as handle    no-undo.
    define variable viNombreMoisPeriode as integer   no-undo.
    define variable vcListe1erMois      as character no-undo.
    define variable vcListeDerMois      as character no-undo.
    define variable viMoisMin           as integer   no-undo.
    define variable viMoisMax           as integer   no-undo.
    define variable voCollection        as class collection no-undo.

    define buffer aquit for aquit.
    define buffer equit for equit.

    for first aquit no-lock
        where aquit.noloc = piNumeroContrat
          and aquit.dtdeb <= pdaDateApplication
          and aquit.dtfin >= pdaDateApplication
          and aquit.fgfac = no:
        viMoisQuitt = aquit.msqtt.
    end.
    if viMoisQuitt = 0
    then for first equit no-lock
        where equit.noloc = piNumeroContrat
          and equit.dtdeb <= pdaDateApplication
          and equit.dtfin >= pdaDateApplication:
        viMoisQuitt = equit.msqtt.
    end.
    if viMoisQuitt <> 0 then do:
        voCollection = new collection().
        run parametre/cabinet/gerance/outilGarantieLoyer.p persistent set vhProcBareme.
        run getTokenInstance in vhProcbareme(mToken:JSessionId).
        run infosPeriodeGarantieLoyer in vhProcBareme(voCollection:getCharacter('cCodePeriodeCarence'), viMoisQuitt
                                                    , output viNombreMoisPeriode, output vcListe1erMois, output vcListeDerMois, output viMoisMin, output viMoisMax).
        run destroy in vhProcBareme.
        viMoisQuitt = viMoisMax.
    end.
    return viMoisQuitt.
end function.

function libelleNomAssureur return character(pcCompteAssureur as character):
    /*------------------------------------------------------------------------------
    Purpose: Récupération du libellé de l'assureur
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer ccptcol for ccptcol.
    define buffer ifour   for ifour.

    // Recherche de la fiche fournisseur
    for first ccptcol no-lock
        where ccptcol.soc-cd = integer(mtoken:cRefGerance)
          and ccptcol.tprole = 12
      , first ifour no-lock
            where ifour.soc-cd   = ccptcol.soc-cd
              and ifour.coll-cle = ccptcol.coll-cle
              and ifour.cpt-cd   = pcCompteAssureur:
        return replace(trim(ifour.nom), ",", ";").
    end.
    return ''.
end function.

procedure rechercheInfosContrat private:
    /*------------------------------------------------------------------------------
    Purpose: recherche tous les infos du contrat bail/prebail dont on a besoin
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroContrat as int64     no-undo.
    define input  parameter pcTypeContrat   as character no-undo.
    define output parameter poCollection    as class collection no-undo.

    define variable vdaDateDebutContrat    as date      no-undo.
    define variable vdaDateFinContrat      as date      no-undo.
    define variable vcCodeNatureContrat    as character no-undo.
    define variable vcCodeCategorieContrat as character no-undo.
    define variable vcTypeBareme           as character no-undo.
    define variable vlBailResilie          as logical   no-undo.
    define variable voSysPg                as class syspg no-undo.

    define buffer ctrat for ctrat.

    for first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat:
        assign
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
    if pcTypeContrat = {&TYPECONTRAT-bail} then vlBailResilie = isBailResilie(pcTypeContrat, piNumeroContrat).

    poCollection:set("daDateDebutContrat",    vdaDateDebutContrat).
    poCollection:set("daDateFinContrat",      vdaDateFinContrat).
    poCollection:set("cCodeNatureContrat",    vcCodeNatureContrat).
    poCollection:set("cCodeCategorieContrat", vcCodeCategorieContrat).
    poCollection:set("cTypeBareme",           vcTypeBareme).
    poCollection:set("lBailResilie",          vlBailResilie).

end procedure.

procedure donneInfosCarence private:
    /*------------------------------------------------------------------------
    Purpose : donne le nombre de mois de carence pour initier la date d'application
    Notes   :
    ------------------------------------------------------------------------*/
    define input  parameter piNumeroVacanceLocative as integer  no-undo.
    define output parameter poCollection            as class collection no-undo.

    define variable viNombreMoisCarence  as integer   no-undo.
    define variable vcCodePeriodeCarence as character no-undo.

    define buffer garan for garan.

    for first garan no-lock
        where garan.tpctt = {&TYPECONTRAT-VacanceLocative}
          and garan.noctt = piNumeroVacanceLocative
          and garan.tpbar = ""
          and garan.nobar = 0:
        assign
            viNombreMoisCarence  = integer(garan.cddev)
            vcCodePeriodeCarence = garan.cdper
        .
    end.
    poCollection = new collection().
    poCollection:set("iNombreMoisCarence",    viNombreMoisCarence).
    poCollection:set("cCodePeriodeCarence",   vcCodePeriodeCarence).
    //poCollection:set("cCodeNatureContrat",    vcCodeNatureContrat).

end procedure.

procedure getVacanceLocative:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroContrat as int64     no-undo.
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroVacance as integer   no-undo.
    define output parameter table for ttTacheVacanceLocative.
    define output parameter table for ttBaremeVacanceLocative.

    define variable voCollectionContrat       as class collection no-undo.
    define variable voCollectionQuitt         as class collection no-undo.
    define variable vhProcTransfert           as handle  no-undo.
    define variable viGlMoiQtt                as integer no-undo.
    define variable vdaDateDebutApplication   as date    no-undo.
    define variable viMoisMax                 as integer no-undo.
    define variable vdaDateApplicationMinimum as date    no-undo.

    define buffer tache for tache.

    empty temp-table ttTacheVacanceLocative.
    // Besoin infos contrat
    if not can-find(first ctrat no-lock
                    where ctrat.tpcon = pcTypeContrat
                      and ctrat.nocon = piNumeroContrat) then do:
        mError:createError({&error}, 100057).
        return.
    end.
    run rechercheInfosContrat(piNumeroContrat, pcTypeContrat, output voCollectionContrat).
    run loadBaremes(ttTacheVacanceLocative.iNumeroVacanceLocative, ttTacheVacanceLocative.cTypeBaremeVacance).
    for last tache no-lock
        where tache.tpcon = pcTypeContrat
          and tache.nocon = piNumeroContrat
          and tache.tptac = {&TYPETACHE-VacanceLocative}:
        create ttTacheVacanceLocative.
        outils:copyValidField(buffer tache:handle, buffer ttTacheVacanceLocative:handle).
        assign
            ttTacheVacanceLocative.cTypeBaremeVacance = voCollectionContrat:getCharacter('cTypeBareme')
            ttTacheVacanceLocative.lBailResilie       = voCollectionContrat:getLogical('lBailResilie')
        .
        // Pour gérer le 'value-changed de la combo 'Garantie' sinon GET classique
        if piNumeroVacance <> 0
        then assign
            ttTacheVacanceLocative.iNumeroVacanceLocative = piNumeroVacance
            ttTacheVacanceLocative.iNumeroBaremeVacance   = getBaremeParVacance()
        .
        // Affichage et accès à la date d'application pour l'IHM
        ttTacheVacanceLocative.lApplicationCalculVisible = (isCalculAPartirDateApplication(ttTacheVacanceLocative.iNumeroVacanceLocative) = "00001").
        if ttTacheVacanceLocative.lApplicationCalculVisible then do:
            run adblib/transfert/suiviTransfert_CRUD.p persistent set vhProcTransfert.
            run getTokenInstance in vhProcTransfert(mToken:JSessionId).
            voCollectionQuitt = new collection().
            voCollectionQuitt:set("cCodeTraitement", "QUIT").
            run calculTransfertAppelExterne in vhProcTransfert(input-output voCollectionQuitt).
            viGlMoiQtt = voCollectionQuitt:getInteger("GlMoiQtt").
            run destroy in vhProcTransfert.
            delete object voCollectionQuitt.
            ttTacheVacanceLocative.lApplicationCalculActive = (ttTacheVacanceLocative.iMois1erTransfertVacance = 0 or ttTacheVacanceLocative.iMois1erTransfertVacance >= viGlMoiQtt).
        end.
        else ttTacheVacanceLocative.lApplicationCalculActive = false.
    end.

    // 'ENTRY' dans la date d'application --> calcul automatique de la date
    if ttTacheVacanceLocative.lApplicationCalculActive and ttTacheVacanceLocative.daApplication = ?
    then do:
        run calculDateApplication(voCollectionContrat:getDate('daDateDebutContrat')
                                , output vdaDateDebutApplication, output viMoisMax, output vdaDateApplicationMinimum).
        ttTacheVacanceLocative.daApplication = vdaDateDebutApplication.
    end.
    delete object voCollectionContrat.

end procedure.

procedure loadBaremes private:
    /*------------------------------------------------------------------------------
    Purpose: Rechargement des baremes selon le numéro de garantie
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroVacanceLocative as integer   no-undo.
    define input parameter pcTypeBareme            as character no-undo.

    define buffer garan for garan.

    empty temp-table ttBaremeVacanceLocative.
    for each garan no-lock
        where garan.tpctt = {&TYPECONTRAT-VacanceLocative}
          and garan.noctt = piNumeroVacanceLocative
          and garan.tpbar = pcTypeBareme:
        create ttBaremeVacanceLocative.
        assign
            ttBaremeVacanceLocative.cTypeContrat       = garan.tpctt
            ttBaremeVacanceLocative.iNumeroContrat     = garan.noctt
            ttBaremeVacanceLocative.cTypeBareme        = garan.tpbar
            ttBaremeVacanceLocative.iNumeroBareme      = garan.nobar
            ttBaremeVacanceLocative.dMontantCotisation = garan.mtcot
            ttBaremeVacanceLocative.dTauxCotisation    = garan.txcot
            ttBaremeVacanceLocative.dTauxHonoraire     = garan.txhon
            ttBaremeVacanceLocative.dTauxResultant     = garan.txres
        .
    end.

end procedure.

procedure initComboVacanceLocative:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroContrat as int64     no-undo.
    define input  parameter pcTypeContrat   as character no-undo.
    define output parameter table for ttCombo.

    define variable voCollectionContrat as class collection no-undo.

    // Besoin infos contrat
    run rechercheInfosContrat(piNumeroContrat, pcTypeContrat, output voCollectionContrat).
    run chargeCombo(voCollectionContrat:getCharacter('cTypeBareme')).
    delete object voCollectionContrat.

end procedure.

procedure chargeCombo private:
    /*------------------------------------------------------------------------------
    Purpose: initie les combos Vacance et Bareme
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeBareme as character no-undo.

    define variable viNumeroItem as integer no-undo.
    define buffer garan for garan.

    empty temp-table ttCombo.
    // Combo Vacance Locative = Garantie
    for each garan no-lock
       where garan.tpctt = {&TYPECONTRAT-VacanceLocative}
         and garan.nobar = 0:
        create ttCombo.
        assign
            viNumeroItem      = viNumeroItem + 1
            ttCombo.iSeqId    = viNumeroItem
            ttCombo.cNomCombo = "CMBVACANCELOCATIVE"
            ttCombo.cCode     = string(garan.noctt, "99")
            ttCombo.cLibelle  = libelleNomAssureur(garan.cdass)
        .
    end.
    // Gestion Autres combo
    for last ttCombo:
        viNumeroItem = ttCombo.iSeqId.
    end.
    // Combo Barème par type 'HAB/COM'
    for each garan no-lock
        where garan.Tpctt = {&TYPECONTRAT-VacanceLocative}
          and garan.tpbar = pcTypeBareme
          and (garan.txcot <> 0 or garan.txhon <> 0)    // PBP 06/03/2002: recuperation du bareme si non nul
        by garan.noctt:
        create ttCombo.
        assign
            viNumeroItem      = viNumeroItem + 1
            ttCombo.iSeqId    = viNumeroItem
            ttCombo.cNomCombo = "CMBBAREMEVACANCE"
            ttCombo.cCode     = string(garan.nobar)
            ttCombo.cLibelle  = 'Barème ' + ttCombo.cCode
            ttCombo.cParent   = string(garan.noctt, "99")
        .
    end.

end procedure.

procedure chargeComboBaremeParVacance private:
    /*------------------------------------------------------------------------------
    Purpose: charge la combo Bareme en fonction de la garantie initiée et type de bail
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroVacanceLocative as integer   no-undo.
    define input parameter pcTypeBareme            as character no-undo.

    define variable viNumeroItem as integer no-undo.
    define buffer garan for garan.

    empty temp-table ttCombo.
    // Combo Barème
    for each garan no-lock
        where garan.Tpctt = {&TYPECONTRAT-VacanceLocative}
          and garan.noctt = piNumeroVacanceLocative
          and garan.tpbar = pcTypeBareme
        // PBP 06/03/2002: recuperation du bareme si non nul ou si celui du bail
          and (garan.txcot <> 0 or garan.txhon <> 0 or garan.nobar = piNumeroVacanceLocative):
        create ttCombo.
        assign
            viNumeroItem      = viNumeroItem + 1
            ttCombo.iSeqId    = viNumeroItem
            ttCombo.cNomCombo = "CMBBAREMEVACANCE"
            ttCombo.cCode     = string(garan.nobar)
            ttCombo.cLibelle  = 'Barème ' + ttCombo.cCode
        .
    end.

end procedure.

procedure initVacanceLocative:
    /*------------------------------------------------------------------------------
    Purpose: Initialisation tache vacance locative
    Notes  : service appelé par beBail.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroContrat as int64     no-undo.
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroVacance as integer   no-undo.
    define output parameter table for ttTacheVacanceLocative.
    define output parameter table for ttBaremeVacanceLocative.

    define variable voCollectionContrat       as class collection no-undo.
    define variable vdaDateDebutApplication   as date      no-undo.
    define variable viMoisMax                 as integer   no-undo.
    define variable vdaDateApplicationMinimum as date      no-undo.

    define buffer tache     for tache.
    define buffer vbttCombo for ttCombo.

    // Besoin infos contrat
    run rechercheInfosContrat(piNumeroContrat, pcTypeContrat, output voCollectionContrat).
    if can-find(first tache no-lock
                where tache.tpcon = pcTypeContrat
                  and tache.nocon = piNumeroContrat
                  and tache.tptac = {&TYPETACHE-VacanceLocative}) then do:
        mError:createError({&error}, 1000410).          // demande d'initialisation d'une tache existante
        return.
    end.

    empty temp-table ttTacheVacanceLocative.
    create ttTacheVacanceLocative.
    assign
        ttTacheVacanceLocative.iNumeroTache       = 0
        ttTacheVacanceLocative.cTypeContrat       = pcTypeContrat
        ttTacheVacanceLocative.iNumeroContrat     = piNumeroContrat
        ttTacheVacanceLocative.cTypeTache         = {&TYPETACHE-VacanceLocative}
        ttTacheVacanceLocative.iChronoTache       = 0
        ttTacheVacanceLocative.daActivation       = today
        ttTacheVacanceLocative.cTypeBaremeVacance = voCollectionContrat:getCharacter('cTypeBareme')
        ttTacheVacanceLocative.lBailResilie       = voCollectionContrat:getLogical('lBailResilie')
        ttTacheVacanceLocative.CRUD               = 'C'
    .
    // Pour gérer le 'value-changed de la combo 'Garantie' sinon INIT classique
    if piNumeroVacance <> 0
    then ttTacheVacanceLocative.iNumeroVacanceLocative = piNumeroVacance.
    else for last tache no-lock     // Ajout SY le 09/05/2007 : rechercher si paramétrage Assurances loyer du mandat
        where tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and tache.nocon = integer(truncate(piNumeroContrat / 100000, 0))
          and tache.tptac = {&TYPETACHE-AssurancesLoyer}:
        if voCollectionContrat:getCharacter('cCodeCategorieContrat') = {&CATEGORIE2BAIL-Habitation}
        then ttTacheVacanceLocative.iNumeroVacanceLocative = integer(tache.ntreg).    // Habitation
        else ttTacheVacanceLocative.iNumeroVacanceLocative = integer(tache.cdreg).    // Commercial
    end.
    // Affichage et accès à la date d'application pour l'IHM
    assign
        ttTacheVacanceLocative.lApplicationCalculVisible = (isCalculAPartirDateApplication(integer(ttTacheVacanceLocative.iNumeroVacanceLocative)) = "00001")
        ttTacheVacanceLocative.lApplicationCalculActive  = ttTacheVacanceLocative.lApplicationCalculVisible
    .
    run chargeCombo(ttTacheVacanceLocative.cTypeBaremeVacance).
    for first ttCombo
        where ttCombo.cNomCombo = "CMBVACANCELOCATIVE":
        if ttTacheVacanceLocative.iNumeroVacanceLocative = 0
        then ttTacheVacanceLocative.iNumeroVacanceLocative = integer(ttCombo.cCode).
        // Chargement des baremes
        run loadBaremes(ttTacheVacanceLocative.iNumeroVacanceLocative, ttTacheVacanceLocative.cTypeBaremeVacance).
        run chargeComboBaremeParVacance(ttTacheVacanceLocative.iNumeroVacanceLocative, ttTacheVacanceLocative.cTypeBaremeVacance).
        for first vbttCombo
            where vbttCombo.cNomCombo = "CMBBAREMEVACANCE":
            ttTacheVacanceLocative.iNumeroBaremeVacance = integer(vbttCombo.cCode).
        end.
        // NP 1109/0092 : Calcul date d'application initiale si option activée
        if ttTacheVacanceLocative.lApplicationCalculVisible then do:
            run calculDateApplication(voCollectionContrat:getDate('daDateDebutContrat')
                                    , output vdaDateDebutApplication, output viMoisMax, output vdaDateApplicationMinimum).
            ttTacheVacanceLocative.daApplication = vdaDateDebutApplication.
        end.
    end.

end procedure.

procedure calculDateApplication private:
    /*------------------------------------------------------------------------------
    Purpose: Calcul date d'application initiale si option activée
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pdaDateDebutContrat       as date    no-undo.
    define output parameter pdaDateDebutApplication   as date    no-undo.
    define output parameter piMoisMax                 as integer no-undo.
    define output parameter pdaDateApplicationMinimum as date    no-undo.

    define variable voCollectionCarence     as class collection no-undo.
    define variable voCollectionQuitt       as class collection no-undo.
    define variable vdaDateDebutApplication as date      no-undo.
    define variable vhProcBareme            as handle    no-undo.
    define variable vhProcTransfert         as handle    no-undo.
    define variable viNombreMoisPeriode     as integer   no-undo.
    define variable vcListe1erMois          as character no-undo.
    define variable vcListeDerMois          as character no-undo.
    define variable viMoisMin               as integer   no-undo.
    define variable viGlMoiMdf              as integer   no-undo.

    // Besoin infos carence
    run donneInfosCarence(ttTacheVacanceLocative.iNumeroVacanceLocative, output voCollectionCarence).
    // donne Date Fin de Carence
    vdaDateDebutApplication = add-interval(pdaDateDebutContrat, voCollectionCarence:getInteger('iNombreMoisCarence'), 'months').
    run adblib/transfert/suiviTransfert_CRUD.p persistent set vhProcTransfert.
    run getTokenInstance in vhProcTransfert(mToken:JSessionId).
    voCollectionQuitt = new collection().
    voCollectionQuitt:set("cCodeTraitement", "QUIT").
    run calculTransfertAppelExterne in vhProcTransfert(input-output voCollectionQuitt).
    viGlMoiMdf = voCollectionQuitt:getInteger("GlMoiMdf").
    run destroy in vhProcTransfert.
    delete object voCollectionQuitt.

    run parametre/cabinet/gerance/outilGarantieLoyer.p persistent set vhProcBareme.
    run getTokenInstance in vhProcbareme(mToken:JSessionId).
    run infosPeriodeGarantieLoyer in vhProcBareme(voCollectionCarence:getCharacter('cCodePeriodeCarence'), viGlMoiMdf
                                                , output viNombreMoisPeriode, output vcListe1erMois, output vcListeDerMois, output viMoisMin, output piMoisMax).
    run destroy in vhProcBareme.

    pdaDateApplicationMinimum = donneDateApplicationMinimum(ttTacheVacanceLocative.iNumeroContrat, viMoisMin).
    if vdaDateDebutApplication <> ? and pdaDateApplicationMinimum <> ? and vdaDateDebutApplication < pdaDateApplicationMinimum
    then vdaDateDebutApplication = pdaDateApplicationMinimum.
    pdaDateDebutApplication = vdaDateDebutApplication.

end procedure.

procedure setVacanceLocative:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTacheVacanceLocative.
    define input parameter table for ttBaremeVacanceLocative.
    define input parameter table for ttError.

    define buffer vbttTacheVacanceLocative for ttTacheVacanceLocative.

    find first ttTacheVacanceLocative
        where lookup(ttTacheVacanceLocative.CRUD, "C,U,D") > 0 no-error.
    if not available ttTacheVacanceLocative then return.

    if can-find(first tache no-lock
                where tache.tpcon = ttTacheVacanceLocative.cTypeContrat
                  and tache.nocon = ttTacheVacanceLocative.iNumeroContrat
                  and tache.tptac = {&TYPETACHE-VacanceLocative}) and ttTacheVacanceLocative.CRUD = "C" then do:
        mError:createError({&error}, 1000410).          // demande d'initialisation d'une tache existante
        return.
    end.
    if can-find(first vbttTacheVacanceLocative
                where lookup(vbttTacheVacanceLocative.CRUD, "C,U,D") > 0
                  and vbttTacheVacanceLocative.iNumeroTache <> ttTacheVacanceLocative.iNumeroTache)
    then do:
        mError:createError({&error}, 1000589).          // Vous ne pouvez traiter en maj qu'un enregistrement à la fois
        return.
    end.

    run verZonSai.
    if not mError:erreur() then run majTacheVacanceLocative(ttTacheVacanceLocative.iNumeroContrat, ttTacheVacanceLocative.cTypeContrat).

end procedure.

procedure verZonSai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable voCollectionContrat       as class collection no-undo.
    define variable vdaDateApplicationMinimum as date      no-undo.
    define variable vdaDateDebutApplication   as date      no-undo.
    define variable viMoisMax                 as integer   no-undo.

    // Recherche de tous les paramètres dont on a besoin
    run rechercheInfosContrat(ttTacheVacanceLocative.iNumeroContrat, ttTacheVacanceLocative.cTypeContrat, output voCollectionContrat).
    if not can-find(first ctrat no-lock
                    where ctrat.tpcon = ttTacheVacanceLocative.cTypeContrat
                      and ctrat.nocon = ttTacheVacanceLocative.iNumeroContrat) then mError:createError({&error}, 100057).
    else if ttTacheVacanceLocative.daActivation = ?                            then mError:createError({&error}, 100299).
    else if ttTacheVacanceLocative.iNumeroBaremeVacance = 0                    then mError:createError({&error}, 107724).  // Le barème est obligatoire ???
    else for first ttBaremeVacanceLocative
        where ttBaremeVacanceLocative.iNumeroContrat    = ttTacheVacanceLocative.iNumeroVacanceLocative
          and ttTacheVacanceLocative.cTypeBaremeVacance = ttBaremeVacanceLocative.cTypeBareme:
        if ttBaremeVacanceLocative.dMontantCotisation = 0 and ttBaremeVacanceLocative.dTauxCotisation = 0 and ttBaremeVacanceLocative.dTauxHonoraire = 0
        then mError:createError({&error}, 106985).  // Veuillez sélectionner un barème non nul
    end.
    if mError:erreur() then return.

    if ttTacheVacanceLocative.lApplicationCalculActive then do:
        if ttTacheVacanceLocative.daApplication = ? then mError:createError({&error}, 100299).
        else if ttTacheVacanceLocative.daApplication < voCollectionContrat:getDate('daDateDebutContrat')
        then mError:createErrorGestion({&error}, 1000621, string(voCollectionContrat:getDate('daDateDebutContrat'))).  // La date d'application doit être supérieure à la date de début du contrat (&1).
        else do:    // Controles par rapport au mois de quitt
            // Date d'application dans quitt futur sinon elle doit être dans une quittance prise en compte dans le prochain traitement de Garantie loyer
            run calculDateApplication(voCollectionContrat:getDate('daDateDebutContrat')
                                    , output vdaDateDebutApplication, output viMoisMax, output vdaDateApplicationMinimum).
            // Le calcul de la vacance locative ne peut pas commencer avant le &1 avec le traitement du quittancement de &2. Confirmez-vous quand même la date du &3 ?
            if vdaDateApplicationMinimum <> ? and ttTacheVacanceLocative.daApplication < vdaDateApplicationMinimum
            then outils:questionnaire(1000622, substitute('&1&2&3/&4&2&5',
                                                   string(vdaDateApplicationMinimum, '99/99/9999'),
                                                   separ[1],
                                                   string(viMoisMax modulo 100, "99"),
                                                   string(truncate(viMoisMax / 100, 0), "9999"),
                                                   string(ttTacheVacanceLocative.daApplication, '99/99/9999'))
                                     , table ttError by-reference).
        end.
    end.

end procedure.

procedure majTacheVacanceLocative private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.

    define variable vhProcTache as handle no-undo.
    define variable vhProcCttac as handle no-undo.
    define buffer cttac for cttac.

    empty temp-table ttCttac.
    if ttTacheVacanceLocative.lApplicationCalculActive
    then ttTacheVacanceLocative.iMoisQuittTraitementVacance = donneMoisQuittTraitementVacance(piNumeroContrat, ttTacheVacanceLocative.daApplication).
    run tache/tache.p persistent set vhProcTache.
    run getTokenInstance in vhProcTache(mToken:JSessionId).
    run setTache in vhProcTache(table ttTacheVacanceLocative by-reference).
    run destroy in vhProcTache.
    if mError:erreur() then return.

    if can-find(first tache no-lock
                where tache.tpcon = pcTypeContrat
                  and tache.nocon = piNumeroContrat
                  and tache.tptac = {&TYPETACHE-VacanceLocative})
    then do:
        if not can-find(first cttac no-lock
                        where cttac.tpcon = pcTypeContrat
                          and cttac.nocon = piNumeroContrat
                          and cttac.tptac = {&TYPETACHE-VacanceLocative})
        then do:
            create ttCttac.
            assign
                ttCttac.tpcon = pcTypeContrat
                ttCttac.nocon = piNumeroContrat
                ttCttac.tptac = {&TYPETACHE-VacanceLocative}
                ttCttac.CRUD  = "C"
            .
        end.
    end.
    else for first cttac no-lock
        where cttac.tpcon = pcTypeContrat
          and cttac.nocon = piNumeroContrat
          and cttac.tptac = {&TYPETACHE-VacanceLocative}:
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
    if can-find(first ttCttac) then do:
        run adblib/cttac_CRUD.p persistent set vhProcCttac.
        run getTokenInstance in vhProcCttac(mToken:JSessionId).
        run setCttac in vhProcCttac(table ttCttac by-reference).
        run destroy in vhProcCttac.
    end.

end procedure.
