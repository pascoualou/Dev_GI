/*------------------------------------------------------------------------
File        : bienContrat.p
Purpose     : bien d'un contrat
Author(s)   : GGA  -  2017/09/04
Notes       : reprise des pgms adb/cont/gesbie05.p
                               adb/cont/lotsmt00.p
derniere revue: 2018/04/18 - phm: KO
            pour déploiement, régler les todo
------------------------------------------------------------------------*/
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/referenceClient.i}

using parametre.pclie.parametrageFournisseurLoyer.
using parametre.syspg.syspg.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/glbsepar.i}
{mandat/include/bienMandat.i}
{adblib/include/intnt.i}
{adblib/include/unite.i}
{immeubleEtLot/include/cpuni.i}
{mandat/include/mandat.i}
{tache/include/tache.i}
{adblib/include/ctrat.i}

function lancementPgm return handle private(pcProgramme as character, pcProcedure as character, table-handle phTable ):
    /*------------------------------------------------------------------------------
    Purpose:   
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhProc as handle no-undo.

    run value(pcProgramme) persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run value(pcProcedure) in vhProc(table-handle phTable by-reference).
    run destroy in vhProc.

end function.

function getNumeroImmeuble return int64 private(piNumeroContrat as int64, pcTypeContrat as character):
    /*------------------------------------------------------------------------------
    Purpose: recherche immeuble du Contrat
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer intnt for intnt.

    for first intnt no-lock
         where intnt.tpcon = pcTypeContrat
           and intnt.nocon = piNumeroContrat
          and intnt.tpidt = {&TYPEBIEN-immeuble}:
        return intnt.noidt.
    end.
    mError:createError({&error}, 1000513). //pas d'immeuble pour ce contrat
    return 0.

end function.

function getNumeroMandatSyndic return integer private(piNumeroImmeuble as integer):
    /*------------------------------------------------------------------------------
    Purpose:   
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer intnt for intnt.
    define buffer ctrat for ctrat.
     
    for first intnt no-lock
        where intnt.tpidt = {&TYPEBIEN-immeuble}
          and intnt.noidt = piNumeroImmeuble
          and intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}
      , first ctrat no-lock
        where ctrat.tpcon = intnt.tpcon
          and ctrat.nocon = intnt.nocon
          and ctrat.dtree = ?:
        return ctrat.nocon.
    end.
    return 0.

end function.

function typeRolePrincipal return character private (pcNatureContrat as character):
    /*------------------------------------------------------------------------------
    Purpose: recherche type de role principal pour nature de contrat
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer sys_pg for sys_pg.

    for first sys_pg no-lock
        where sys_pg.tppar = "R_CR1"
          and sys_pg.zone1 = pcNatureContrat
          and sys_pg.zone7 = "P":
        return sys_pg.zone2.
    end.
    return ?.

end function.

function lotDisponible return logical private(
    pcNatureContrat as character, piNumeroContrat as int64, pcCodeModele as character, piNumeroRole as integer, piNumeroInterneLot as int64 ):
    /*------------------------------------------------------------------------------
    Purpose: recherche type de role principal pour nature de contrat
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable viNumeroRolePro   as integer   no-undo.
    define variable vcTypeMandatLot   as character no-undo.
    define variable viNumeroMandatLot as integer   no-undo.
    define variable vlPasse2          as logical   no-undo.
    define variable vlLotRattache     as logical   no-undo.

    define buffer intnt   for intnt.
    define buffer ctrat   for ctrat.
    define buffer vbctrat for ctrat.

    /* Ce n'est pas un lot du mandat */
    /* 12/12/2001: la gestion des lots en sous-location est spéciale  */
    if lookup(pcNatureContrat, substitute("&1,&2,&3,&4,&5",
                {&NATURECONTRAT-mandatLocation},
                {&NATURECONTRAT-mandatSousLocation},
                {&NATURECONTRAT-mandatLocationDelegue},
                {&NATURECONTRAT-mandatSousLocationDelegue},
                {&NATURECONTRAT-mandatLocationIndivision})) = 0
    then do:
        /* Mandat "Standard": est ce un lot du mandant, d'un autre mandant/Copropr., libre de l'immeuble ? */
boucle-rech01:
        for each intnt no-lock
            where intnt.tpidt  = {&TYPEBIEN-lot}
              and intnt.noidt  = piNumeroInterneLot
              and (intnt.tpcon = {&TYPECONTRAT-mandat2Gerance} or intnt.tpcon = {&TYPECONTRAT-titre2copro})
              and intnt.nbden  = 0
          , first ctrat no-lock
            where ctrat.tpcon = intnt.tpcon
              and ctrat.nocon = intnt.nocon:
            /*== Test si mandat de syndic n'est pas résilié ==*/
            if ctrat.tpcon = {&TYPECONTRAT-titre2copro}
            then for first vbctrat no-lock
                where vbctrat.tpcon = {&TYPECONTRAT-mandat2Syndic}
                  and vbctrat.nocon = int64(truncate(ctrat.nocon / 100000, 0)) // int(substring(string(ctrat.nocon,"9999999999"),1,5))
                  and vbctrat.dtree = ?:
                viNumeroRolePro = ctrat.norol.
            end.
            else assign
                viNumeroRolePro   = ctrat.norol
                vcTypeMandatLot   = ctrat.tpcon
                viNumeroMandatLot = ctrat.nocon
            .
            leave boucle-rech01.
        end.
        /* On considere que le lot est à l'immeuble si: Lot non rattaché à un autre mandat, même si proprio identique */
        if vcTypeMandatLot = {&TYPECONTRAT-mandat2Gerance} and viNumeroMandatLot <> 0 and viNumeroMandatLot <> piNumeroContrat
        then vlLotRattache = yes.
    end.
    else do:
        /* Mandat "Sous-location" ou Location (FLoyer).
           recherche si lot affecté a un mandat gérance "Standard" (ntcon < {NATURECONTRAT-mandatLocation}) */
boucle-rech02:
        for each intnt no-lock
            where intnt.tpidt = {&TYPEBIEN-lot}
              and intnt.noidt = piNumeroInterneLot
              and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
          , first ctrat no-lock
            where ctrat.tpcon = intnt.tpcon
              and ctrat.nocon = intnt.nocon
              and ctrat.ntcon < {&NATURECONTRAT-mandatLocation}:
            assign
                viNumeroRolePro   = ctrat.norol
                vcTypeMandatLot   = ctrat.tpcon
                viNumeroMandatLot = ctrat.nocon
                vlPasse2          = true
            .
            leave boucle-rech02.
        end.
        /* Si modele Eurostudiomme, il faut aussi verifier que le lot n'est pas rattaché à un autre mandat de meme nature */
        if pcCodeModele = "00003" or pcCodeModele = "00004" then do:
boucle-rech03:
            for each intnt no-lock
                where intnt.tpidt = {&TYPEBIEN-lot}
                  and intnt.noidt = piNumeroInterneLot
                  and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and intnt.nocon <> piNumeroContrat
              , first ctrat no-lock
                where ctrat.tpcon = intnt.tpcon
                  and ctrat.nocon = intnt.nocon
                  and ctrat.ntcon = pcNatureContrat:
                assign
                    viNumeroRolePro   = ctrat.norol
                    vcTypeMandatLot   = ctrat.tpcon
                    viNumeroMandatLot = ctrat.nocon
                    vlPasse2          = true
                .
                leave boucle-rech03.
            end.
            /* PL: 19/06/2012 : 0212/0155 Gestion sous-location déléguée
               Le lot ne peut pas être rattaché à 2 mandat de sous locations sur le même immeuble.
               Cas de la sous loc déléguée, ou il peut y avoir à la fois un mandat de sous-location et un mandat de sous location déléguée.
            */
            if pcNatureContrat = {&NATURECONTRAT-mandatSousLocation}
            or pcNatureContrat = {&NATURECONTRAT-mandatSousLocationDelegue} then do:
boucle-rech04:
                for each intnt no-lock
                    where intnt.tpidt = {&TYPEBIEN-lot}
                      and intnt.noidt = piNumeroInterneLot
                      and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
                      and intnt.nocon <> piNumeroContrat
                  , first ctrat no-lock
                    where ctrat.tpcon  = intnt.tpcon
                      and ctrat.nocon  = intnt.nocon
                      and (ctrat.ntcon = {&NATURECONTRAT-mandatSousLocation} or ctrat.ntcon = {&NATURECONTRAT-mandatSousLocationDelegue}):
                    assign
                        viNumeroRolePro   = ctrat.norol
                        vcTypeMandatLot   = ctrat.tpcon
                        viNumeroMandatLot = ctrat.nocon
                        vlPasse2          = true
                    .
                    leave boucle-rech04.
                end.
            end.
            /* Idem pour la location */
            if pcNatureContrat = {&NATURECONTRAT-mandatLocation}
            or pcNatureContrat = {&NATURECONTRAT-mandatLocationDelegue} then do:
boucle-rech05:
                for each intnt no-lock
                   where intnt.tpidt = {&TYPEBIEN-lot}
                     and intnt.noidt = piNumeroInterneLot
                     and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
                     and intnt.nocon <> piNumeroContrat
                , first ctrat no-lock
                  where ctrat.tpcon = intnt.tpcon
                    and ctrat.nocon = intnt.nocon
                    and (ctrat.ntcon = {&NATURECONTRAT-mandatLocation} or ctrat.ntcon = {&NATURECONTRAT-mandatLocationDelegue}):
                    assign
                        viNumeroRolePro   = ctrat.norol
                        vcTypeMandatLot   = ctrat.tpcon
                        viNumeroMandatLot = ctrat.nocon
                        vlPasse2          = true
                    .
                    leave boucle-rech05.
                end.
            end.
            /* Ajout Sy le 23/05/2007 */
            /* Si pec mandat Location ({&NATURECONTRAT-mandatLocation} ou 03093) et que le lot est rattaché en copro */
            /* il faut que le no copro soit égal au no propriétaire */
            if pcNatureContrat = {&NATURECONTRAT-mandatLocation}
            or pcNatureContrat = {&NATURECONTRAT-mandatLocationIndivision}
            or pcNatureContrat = {&NATURECONTRAT-mandatLocationDelegue} then do:
boucle-rech06:
                for each intnt no-lock
                    where intnt.tpidt = {&TYPEBIEN-lot}
                      and intnt.noidt = piNumeroInterneLot
                      and intnt.tpcon = {&TYPECONTRAT-titre2copro}
                      and intnt.nbden = 0
                  , first ctrat no-lock
                    where ctrat.tpcon = intnt.tpcon
                      and ctrat.nocon = intnt.nocon:
                    if ctrat.norol <> piNumeroRole
                    and can-find(first vbctrat no-lock    /*== Test si mandat de syndic n'est pas résilié ==*/
                                 where vbctrat.tpcon = {&TYPECONTRAT-mandat2Syndic}
                                   and vbctrat.nocon = int64(truncate(ctrat.nocon / 100000, 0))   // int(substring(string(ctrat.nocon,"9999999999"),1,5))
                                   and vbctrat.dtree = ?)
                    then do:
                        assign
                            viNumeroRolePro = ctrat.norol
                            vlPasse2        = true
                        .
                        leave boucle-rech06.
                    end.
                end.
            end.    /* lien copro actif du lot */
        end.
        /* Si modele Crédit Lyonnais, il faut aussi verifier que le lot n'est pas rattaché à un autre mandat de sous-location. */
        if (pcNatureContrat = {&NATURECONTRAT-mandatSousLocation}
         or pcNatureContrat = {&NATURECONTRAT-mandatSousLocationDelegue})
        and pcCodeModele = "00002" then do:
boucle-rech07:
            for each intnt no-lock
                where intnt.tpidt = {&TYPEBIEN-lot}
                  and intnt.noidt = piNumeroInterneLot
                  and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and intnt.nocon <> piNumeroContrat
              , first ctrat no-lock
                where ctrat.tpcon = intnt.tpcon
                  and ctrat.nocon = intnt.nocon
                  and ctrat.ntcon = pcNatureContrat:
                assign
                    viNumeroRolePro   = ctrat.norol
                    vcTypeMandatLot   = ctrat.tpcon
                    viNumeroMandatLot = ctrat.nocon
                    vlPasse2          = true
                .
                leave boucle-rech07.
            end.
        end.
    end.
    if viNumeroRolePro = 0 or (viNumeroRolePro = piNumeroRole and vlPasse2 = false and vlLotRattache = false)
    then return true.
    return false.

end function.

procedure getLot:
    /*------------------------------------------------------------------------------
    Purpose: affichage liste lot du mandat et liste lot disponible de l'immeuble 
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroContrat as int64     no-undo.
    define input  parameter pcTypeContrat   as character no-undo.
    define output parameter table for ttBienMandat.
    define output parameter table for ttLotDispo.

    define variable vinumeroImmeuble as int64 no-undo.
    define variable voParametrage    as class parametrageFournisseurLoyer no-undo.
    define buffer ctrat for ctrat.

    empty temp-table ttBienMandat.
    empty temp-table ttLotDispo.
    find first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat no-error.
    if not available ctrat
    then do:
        mError:createError({&error}, 100057).
        return.
    end.
    viNumeroImmeuble = getNumeroImmeuble(piNumeroContrat, pcTypeContrat).
    if mError:erreur() then return.

    voParametrage = new parametrageFournisseurLoyer().
    run listeLotMandat(vinumeroImmeuble, ctrat.tpcon, ctrat.nocon, ctrat.ntcon, ctrat.norol, voParametrage:getCodeModele()).
    delete object voParametrage.
    
end procedure.

procedure listeLotMandat private:
    /*------------------------------------------------------------------------------
    Purpose: liste des lots d'un mandat
    Notes  : a partir de adb/comm/majlstlo.i
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroImmeuble as int64     no-undo.
    define input parameter pcTypeContrat    as character no-undo.
    define input parameter piNumeroContrat  as int64     no-undo.
    define input parameter pcNatureContrat  as character no-undo.
    define input parameter piNumeroRole     as integer   no-undo.
    define input parameter pcCodeModele     as character no-undo.

    define buffer local   for local.
    define buffer cpuni   for cpuni.
    define buffer intnt   for intnt.

    /* Parcours des Lots de l'Immeuble. */
    for each local no-lock
        where local.noimm = piNumeroImmeuble:
        /* Test si c'est un lot du mandat */
        find first intnt no-lock
             where intnt.tpidt = {&TYPEBIEN-lot}
               and intnt.noidt = local.noloc
               and intnt.tpcon = pcTypeContrat
               and intnt.nocon = piNumeroContrat no-error.
        if available intnt
        then do:
            create ttBienMandat.
            assign
                ttBienMandat.cTypeContrat    = pcTypeContrat
                ttBienMandat.iNumeroContrat  = piNumeroContrat
                ttBienMandat.iNumeroImmeuble = piNumeroImmeuble
                ttBienMandat.iNumeroBien     = intnt.noidt
                ttBienMandat.iNumeroLot      = local.nolot
                ttBienMandat.cNatureLot      = local.ntlot
                ttBienMandat.iSfLot          = local.sfree
                ttBienMandat.cLibre          = ""
                ttBienMandat.cNatureContrat  = pcNatureContrat
                ttBienMandat.cCdModele       = pcCodeModele
                ttBienMandat.cLibNatureLot   = outilTraduction:getLibelleParam("NTLOT", local.ntlot)
                ttBienMandat.dtTimestamp     = datetime(intnt.dtmsy, intnt.hemsy)
                ttBienMandat.CRUD            = "R"
                ttBienMandat.rRowid          = rowid(intnt)
            .
            /* Test si le lot est libre ou non */
            for first cpuni no-lock
                where cpuni.NoMdt = piNumeroContrat
                  and cpuni.NoApp = 998
                  and cpuni.NoCmp = 10
                  and cpuni.NoLot = local.nolot:
                ttBienMandat.cLibre = if (local.fgdiv and cpuni.sflot = local.sfree) or not local.fgdiv
                                      then outilTraduction:getLibelle(101131) else "".
            end.
        end.
        else if lotDisponible (pcNatureContrat, piNumeroContrat, pcCodeModele, piNumeroRole, local.noloc)        
        then do:
            /* Lot libre de l'immeuble (ou lot du mandant en copro) */
            create ttLotDispo.
            assign
                ttLotDispo.cTypeContrat    = pcTypeContrat
                ttLotDispo.iNumeroContrat  = piNumeroContrat
                ttLotDispo.iNumeroImmeuble = piNumeroImmeuble
                ttLotDispo.iNumeroBien     = local.noloc
                ttLotDispo.iNumeroLot      = local.nolot
                ttLotDispo.cNatureLot      = local.ntlot
                ttLotDispo.cLibNatureLot   = outilTraduction:getLibelleParam("NTLOT", local.ntlot)
                ttLotDispo.iSfLot          = local.sfree
                ttLotDispo.cNatureContrat  = pcNatureContrat
                ttLotDispo.cCdModele       = pcCodeModele
                ttLotDispo.CRUD            = "R"
            .
        end.
    end.

end procedure.

procedure setLot:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttBienMandat.

    define variable vcTypeRole   as character no-undo.
    define variable viNumeroRole as integer   no-undo.

    define buffer ctrat  for ctrat.
    define buffer intnt  for intnt.

    find first ttBienMandat where lookup(ttBienMandat.CRUD, "C,D") > 0 no-error.
    if not available ttBienMandat then return. 
    find first ctrat no-lock
        where ctrat.tpcon = ttBienMandat.cTypeContrat
          and ctrat.nocon = ttBienMandat.iNumeroContrat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 100057).
        return.
    end.
    vcTypeRole = typeRolePrincipal (ctrat.ntcon).
    if vcTypeRole = ? or vcTypeRole = "" then do:
        mError:createError({&error}, 100173).
        return.
    end.
    if integer(mtoken:cRefPrincipale) = {&REFCLIENT-MANPOWER}
    then viNumeroRole = ctrat.norol.
    else do:
        find last intnt no-lock
            where intnt.tpcon = ctrat.tpcon
              and intnt.nocon = ctrat.nocon
              and intnt.tpidt = vcTypeRole no-error.
        if not available intnt then do:
            mError:createError({&error}, 100172).
            return.
        end.
        viNumeroRole = intnt.noidt.
    end.   

    run valLotMdt (buffer ctrat, viNumeroRole, vcTypeRole).
    if mError:erreur() then return.

    // mandat sans lot interdit sauf si mandat resilie. On peut mettre ce controle apres la maj car normalement ce test est fait pendant la saisie IHM (donc on ne devrait pas rencontrer ce cas)
    if not can-find(first intnt no-lock
                    where intnt.tpidt = {&TYPEBIEN-lot}
                      and intnt.tpcon = ctrat.tpcon
                      and intnt.nocon = ctrat.nocon)
    and ctrat.dtree = ?                   
    then do:
        mError:createError({&error}, 1000757). //mandat sans lot interdit sauf si ce mandat doit être résilié. La résiliation du mandat supprimera automatiquement les derniers lots
        return.        
    end.    

end procedure.

procedure valLotMdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ctrat for ctrat.
    define input parameter piNumeroRole as integer   no-undo.
    define input parameter pcTypeRole   as character no-undo.
    
    define variable viNumeroImmeuble     as int64     no-undo.
    define variable vcTypeRoleCopro      as character no-undo.
    define variable viNumeroRoleCopro    as integer   no-undo.
    define variable viNumeroMandatSyndic as integer   no-undo.
    define variable voParametrage    as class parametrageFournisseurLoyer no-undo.

    define buffer tache for tache.
    define buffer intnt for intnt.
    define buffer cpuni for cpuni.
    define buffer local for local.

    empty temp-table ttIntnt.
    empty temp-table ttUnite.
    empty temp-table ttCpuni.
    empty temp-table ttTache.
    empty temp-table ttCtrat.
    viNumeroImmeuble = getNumeroImmeuble(ctrat.nocon, ctrat.tpcon).
    if mError:erreur() then return.

    assign
        viNumeroMandatSyndic = getNumeroMandatSyndic (viNumeroImmeuble)
        voParametrage       = new parametrageFournisseurLoyer()
    .
    /* parcours des lots a rattacher au mandat  */
    for each ttBienMandat where ttBienMandat.CRUD = "C":
        /* verifier si le lot n'appartient pas deja au mandat */
        if can-find(first intnt no-lock
                    where intnt.tpidt = {&TYPEBIEN-lot}
                      and intnt.noidt = ttBienMandat.iNumeroBien
                      and intnt.tpcon = ttBienMandat.cTypeContrat
                      and intnt.nocon = ttBienMandat.iNumeroContrat) then do:
            mError:createError({&error}, 1000654, string(ttBienMandat.iNumeroLot)).         //lot &1 déjà rattaché au mandat
            return.
        end.
        find first local no-lock
             where local.noimm = viNumeroImmeuble
               and local.noloc = ttBienMandat.iNumeroBien no-error.
        if not available local then do:
            mError:createErrorGestion({&error}, 102093, substitute("&2&1&3", separ[1], ttBienMandat.iNumeroLot, viNumeroImmeuble)).         //lot %1 inconnu dans l'immeuble %2
            return.
        end.    
        if not lotDisponible(ctrat.ntcon, ctrat.nocon, voParametrage:getCodeModele(), ctrat.norol, local.noloc)  
        then do:
            mError:createError({&error}, 1000659).                 //lot &1 indisponible
            return.
        end.
        /* Création du lot dans intnt (rattachement lot au mandat) */
        create ttIntnt.
        assign
            ttintnt.tpidt = {&TYPEBIEN-lot}
            ttintnt.noidt = ttBienMandat.iNumeroBien
            ttintnt.tpcon = ttBienMandat.cTypeContrat
            ttintnt.nocon = ttBienMandat.iNumeroContrat
            ttIntnt.nbnum = 0
            ttIntnt.idsui = 0
            ttIntnt.nbden = 0
            ttIntnt.cdreg = ""
            ttIntnt.lbdiv = ""
            ttIntnt.CRUD  = 'C'
        .
        /* verifier si unite de location 998 existe pour le mandat */
        if not can-find(first unite no-lock
                        where unite.NoMdt = ttBienMandat.iNumeroContrat
                          and unite.NoApp = 998
                          and unite.NoAct = 0)
        and not can-find(first ttUnite
                         where ttUnite.NoMdt = ttBienMandat.iNumeroContrat
                           and ttUnite.NoApp = 998
                           and ttUnite.NoAct = 0) then do:
            create ttUnite.
            assign
                ttUnite.noman = piNumeroRole
                ttUnite.nomdt = ttBienMandat.iNumeroContrat
                ttUnite.noapp = 998
                ttUnite.noact = 0
                ttUnite.nocmp = 010
                ttUnite.cdcmp = "00004"
                ttUnite.dtdeb = ctrat.dtdeb
                ttUnite.noimm = ttBienMandat.iNumeroImmeuble
                ttUnite.norol = 0
                ttUnite.cdocc = "00002"
                ttUnite.CRUD  = "C"
            .
        end.
        /* rattachement du lot a unite de location 998 */
        create ttCpuni.
        assign
            ttCpuni.nomdt = ttBienMandat.iNumeroContrat
            ttCpuni.noapp = 998
            ttCpuni.nocmp = 010
            ttCpuni.noord = ?                                    //le numero d'ordre sera calcule dans cpuni_crud.p
            ttCpuni.noman = piNumeroRole
            ttCpuni.noimm = ttBienMandat.iNumeroImmeuble
            ttCpuni.nolot = ttBienMandat.iNumeroLot
            ttCpuni.cdori = ""
            ttCpuni.sflot = ttBienMandat.iSfLot
            ttCpuni.CRUD  = "C"
        .
        /* Récupération du n° de l'acte de propriété */
        /* Si mandat de type {&NATURECONTRAT-mandatLocation} ou {&NATURECONTRAT-mandatSousLocation}, ne pas mettre à jour l'acte de propriete: c'est le copro qui prime. */
        if integer(mtoken:cRefPrincipale) <> {&REFCLIENT-MANPOWER}
        and lookup(ctrat.ntcon, substitute("&1,&2,&3,&4,&5",
                        {&NATURECONTRAT-mandatLocation},
                        {&NATURECONTRAT-mandatSousLocation},
                        {&NATURECONTRAT-mandatLocationDelegue},
                        {&NATURECONTRAT-mandatSousLocationDelegue},
                        {&NATURECONTRAT-mandatLocationIndivision})) = 0
        then for last intnt no-lock
            where intnt.tpidt = {&TYPEBIEN-lot}
              and intnt.noidt = ttBienMandat.iNumeroBien
              and intnt.tpcon = {&TYPECONTRAT-acte2propriete}:
            run prcMajprop(intnt.nocon, pcTypeRole, piNumeroRole).
        end.
        /* Gérer le mandat Fournisseur de loyer ou sous location: Affectation auto. dans l'autre
           mandat du lot car ils vont par paire! !=> Un lot doit etre en fournisseur loyer et en sous location. */
        if voParametrage:getCodeModele() <> "00003" and voParametrage:getCodeModele() <> "00004"
        then run affecLotBis(ctrat.tpcon, ctrat.ntcon, voParametrage:getFournisseurLoyerDebut(), voParametrage:getCodeModele(), buffer ttBienMandat).
        /* RAZ date de fin dans tache garantie locative */
        for first tache no-lock
            where tache.tpcon = ttBienMandat.cTypeContrat
              and tache.nocon = ttBienMandat.iNumeroContrat
              and tache.tptac = {&TYPETACHE-garantieLocative}
              and tache.notac = ttBienMandat.iNumeroLot:
            create ttTache.
            assign
                ttTache.tpcon       = tache.tpcon
                ttTache.nocon       = tache.nocon
                ttTache.tptac       = tache.tptac
                ttTache.notac       = tache.notac
                ttTache.dtfin       = 01/01/0001
                ttTache.dtree       = 01/01/0001
                ttTache.tpfin       = ""
                ttTache.CRUD        = "U"
                ttTache.rRowid      = rowid(tache)
                ttTache.dtTimestamp = datetime(tache.dtmsy, tache.hemsy) 
            .
        end.
    end.
    /* parcours des lots a detacher au mandat  */
    for each ttBienMandat where ttBienMandat.CRUD = "D":
        /* verifier si le lot appartient au mandat */
        find first intnt no-lock
            where intnt.tpidt = {&TYPEBIEN-lot}
              and intnt.noidt = ttBienMandat.iNumeroBien
              and intnt.tpcon = ttBienMandat.cTypeContrat
              and intnt.nocon = ttBienMandat.iNumeroContrat no-error.
        if not available intnt then do:
            mError:createError({&error}, 1000655, string(ttBienMandat.iNumeroLot)).      //lot &1 non rattaché au mandat
            return.
        end.
        if ttBienMandat.cLibre <> outilTraduction:getLibelle(101131)
        then do:
            mError:createError({&error}, 1000758).      //Vous ne pouvez pas retirer du mandat un lot non libre
            return.            
        end.    
        if (ctrat.ntcon = {&NATURECONTRAT-mandatLocation} or ctrat.ntcon = {&NATURECONTRAT-mandatLocationIndivision} or ctrat.ntcon = {&NATURECONTRAT-mandatLocationDelegue}) 
        and voParametrage:getCodeModele() <> "00003" and voParametrage:getCodeModele() <> "00004"
        then do:
            mError:createError({&error}, 106108). //Vous ne pouvez pas retirer des lots au mandat des Fournisseurs de loyer de l'immeuble
            return.
        end.
        if ctrat.ntcon = {&NATURECONTRAT-mandatSousLocation} and voParametrage:getCodeModele() = "00001"
        then do:
            mError:createError({&error}, 106109).  //CAS RESIDE ETUDES - Vous ne pouvez pas retirer des lots au mandat de sous-location de l'immeuble
            return.
        end.
        /* suppression rattachement lot au mandat */
        create ttIntnt.
        assign
            ttintnt.tpidt       = intnt.tpidt
            ttintnt.noidt       = intnt.noidt
            ttintnt.tpcon       = intnt.tpcon
            ttintnt.nocon       = intnt.nocon
            ttIntnt.nbnum       = intnt.nbnum
            ttIntnt.idpre       = intnt.idpre
            ttIntnt.idsui       = intnt.idsui
            ttIntnt.rRowid      = ttBienMandat.rRowid
            ttIntnt.dtTimestamp = ttBienMandat.dtTimestamp
            ttIntnt.CRUD        = ttBienMandat.CRUD 
        .
        /* suppression lot dans unite location 998 */
        for last cpuni no-lock
            where cpuni.nomdt = ttBienMandat.iNumeroContrat
              and cpuni.noimm = ttBienMandat.iNumeroImmeuble
              and cpuni.nolot = ttBienMandat.iNumeroLot
              and cpuni.noapp = 998
              and cpuni.nocmp = 10:
            create ttCpuni.
            assign
                ttCpuni.nomdt       = cpuni.nomdt
                ttCpuni.noimm       = cpuni.noimm
                ttCpuni.nolot       = cpuni.nolot
                ttCpuni.noapp       = cpuni.noapp
                ttCpuni.nocmp       = cpuni.nocmp
                ttCpuni.noord       = cpuni.noord
                ttCpuni.dtTimestamp = datetime(cpuni.dtmsy, cpuni.hemsy)
                ttCpuni.CRUD        = 'D'
                ttCpuni.rRowid      = rowid(cpuni)
            .
        end.
        /* Récupération du n° de l'acte de propriétév*/
        /* Si mandat de type {&NATURECONTRAT-mandatLocation} ou {&NATURECONTRAT-mandatSousLocation}, ne pas mettre à jour l'acte de propriété: c'est le copro qui prime. */
        if integer(mtoken:cRefPrincipale) <> {&REFCLIENT-MANPOWER}
        and lookup(ctrat.ntcon, substitute("&1,&2,&3,&4,&5",
                        {&NATURECONTRAT-mandatLocation},
                        {&NATURECONTRAT-mandatSousLocation},
                        {&NATURECONTRAT-mandatLocationDelegue},
                        {&NATURECONTRAT-mandatSousLocationDelegue},
                        {&NATURECONTRAT-mandatLocationIndivision})) = 0
        then do:
            /* Modif 27/07/2000: Si immeuble de copro actif on remet le copropriétaire en cours */
            assign
                vcTypeRoleCopro   = ""
                viNumeroRoleCopro = 0
            .
            if viNumeroMandatSyndic <> 0 
            then for last intnt no-lock
                where intnt.tpcon = {&TYPECONTRAT-titre2copro} 
                  and intnt.tpidt = {&TYPEBIEN-lot}
                  and intnt.noidt = ttBienMandat.iNumeroBien
                  and intnt.nbden = 0:
                assign
                    vcTypeRoleCopro = {&TYPEROLE-coproprietaire}
                    viNumeroRoleCopro = integer(substring(string(intnt.nocon, "9999999999"), 6, 5, "character"))
                .
            end.
            for last intnt no-lock
                where intnt.tpidt = {&TYPEBIEN-lot}
                  and intnt.noidt = ttBienMandat.iNumeroBien
                  and intnt.tpcon = {&TYPECONTRAT-acte2propriete}:
                run prcMajprop(intnt.nocon, vcTypeRoleCopro, viNumeroRoleCopro).
            end.
        end.
        /* Maj date de fin dans tache garantie locative */
        for first tache no-lock
            where tache.tpcon = ttBienMandat.cTypeContrat
              and tache.nocon = ttBienMandat.iNumeroContrat
              and tache.tptac = {&TYPETACHE-garantieLocative}
              and tache.notac = ttBienMandat.iNumeroLot:
            create ttTache.
            assign
                ttTache.tpcon       = tache.tpcon
                ttTache.nocon       = tache.nocon
                ttTache.tptac       = tache.tptac
                ttTache.notac       = tache.notac
                ttTache.dtfin       = today
                ttTache.dtree       = today
                ttTache.tpfin       = ""
                ttTache.CRUD        = "U"
                ttTache.rRowid      = rowid(tache)
                ttTache.dtTimestamp = datetime(tache.dtmsy, tache.hemsy) 
            .
        end.
    end.
    lancementPgm ("adblib/intnt_CRUD.p",        "setIntnt", table ttIntnt by-reference).
    lancementPgm ("adblib/unite_CRUD.p",        "setUnite", table ttUnite by-reference).
    lancementPgm ("immeubleEtLot/cpuni_CRUD.p", "setCpuni", table ttCpuni by-reference).
    lancementPgm ("tache/tache.p",              "setTache", table ttTache by-reference).
    lancementPgm ("adblib/ctrat_CRUD.p",        "setCtrat", table ttCtrat by-reference).    //table remplie dans procedure PrcMajProp

end procedure.

procedure affecLotBis private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure pour affecter le lot au mandat location (NATURECONTRAT-mandatLocation fournisseur loyer)
             si on l'ajoute au mandat de sous-location (NATURECONTRAT-mandatSousLocation) et réciproquement
             Un lot doit etre en fournisseur loyer et en sous location.
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat           as character no-undo.
    define input parameter pcNatureContrat         as character no-undo.
    define input parameter piFournisseurLoyerDebut as integer   no-undo.
    define input parameter pcCodeModele            as character no-undo.
    define parameter buffer ttBienMandat for ttBienMandat. 

    define variable viNumeroMandat as int64   no-undo.
    define variable vdaDebut       as date    no-undo.

    define buffer vbctrat for ctrat.
    define buffer intnt   for intnt.

    if lookup(pcNatureContrat, substitute("&1,&2,&3,&4,&5",
                {&NATURECONTRAT-mandatLocation},
                {&NATURECONTRAT-mandatSousLocation},
                {&NATURECONTRAT-mandatLocationDelegue},
                {&NATURECONTRAT-mandatSousLocationDelegue},
                {&NATURECONTRAT-mandatLocationIndivision})) > 0
    then do:
        if pcNatureContrat = {&NATURECONTRAT-mandatSousLocation}
        then for first vbctrat no-lock                              // mandat sous-location (locataires) => recherche mandat des bailleurs
            where vbctrat.tpcon = pcTypeContrat
              and vbctrat.nocon = ttBienMandat.iNumeroImmeuble + piFournisseurLoyerDebut - 1:
            assign
                viNumeroMandat = vbctrat.nocon
                vdaDebut       = vbctrat.dtdeb
            .
        end.
        else do:
            /* mandat floy/location (bailleur)                                            */
            /*     => RESIDE ETUDE    : mandat sous-location = no immeuble                */
            /*        CREDIT LYONNAIS : recherche du 1er mandat de sous-loc de l'immeuble */
            if pcCodeModele = "00001"
            then for first vbctrat no-lock
                where vbctrat.tpcon = pcTypeContrat
                  and vbctrat.nocon = ttBienMandat.iNumeroImmeuble:
                assign
                    viNumeroMandat = vbctrat.nocon
                    vdaDebut       = vbctrat.dtdeb
                .
            end.
            else for first intnt no-lock
                where intnt.tpcon = pcTypeContrat
                  and intnt.nocon < piFournisseurLoyerDebut
                  and intnt.tpidt = {&TYPEBIEN-immeuble}
                  and intnt.noidt = ttBienMandat.iNumeroImmeuble
              , first vbctrat no-lock
                where vbctrat.tpcon = pcTypeContrat
                  and vbctrat.nocon = intnt.nocon:
                assign
                    viNumeroMandat = vbctrat.nocon
                    vdaDebut       = vbctrat.dtdeb
                .
            end.
        end.
        if viNumeroMandat > 0
        then run gesUlMdt(pcTypeContrat, viNumeroMandat, vdaDebut, buffer ttBienMandat).                 //Gestion du lot dans l'UL 998 selon mandat
    end.

end procedure.

procedure GesUlMdt private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure gestion du lot dans le mandat associé soit Fournisseur loyer soit sous location
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat          as character no-undo.    
    define input parameter piNumeroContratAssocie as int64     no-undo.
    define input parameter pdaDebutContratAssocie as date      no-undo. 
    define parameter buffer ttBienMandat for ttBienMandat. 
    
    define variable viNumeroMandantContratAssocie as integer no-undo.
    define buffer intnt for intnt.
    
    for first intnt no-lock
        where intnt.tpcon = pcTypeContrat
          and intnt.nocon = piNumeroContratAssocie
          and intnt.tpidt = {&TYPEROLE-mandant}:
        viNumeroMandantContratAssocie = intnt.noidt.
    end.
    //Test si le lot appartient deja au mandat    
    if can-find(first intnt no-lock
                where intnt.tpidt = {&TYPEBIEN-lot}
                  and intnt.noidt = ttBienMandat.iNumeroLot
                  and intnt.tpcon = pcTypeContrat
                  and intnt.nocon = piNumeroContratAssocie) then return.

    // Creation du lot dans Intnt
    create ttIntnt.
    assign
        ttIntnt.tpidt = {&TYPEBIEN-lot}
        ttIntnt.noidt = ttBienMandat.iNumeroLot
        ttIntnt.tpcon = pcTypeContrat
        ttIntnt.nocon = piNumeroContratAssocie
        ttIntnt.nbnum = 0
        ttIntnt.idsui = 0
        ttIntnt.nbden = 0
        ttIntnt.cdreg = ""
        ttIntnt.lbdiv = ""
        ttIntnt.CRUD  = 'C'
    .
    /* verifier si unite de location 998 existe pour le mandat */
    if not can-find(first unite no-lock
                    where unite.nomdt = piNumeroContratAssocie
                      and unite.noapp = 998
                      and unite.noact = 0)
    and not can-find(first ttUnite
                     where ttUnite.nomdt = piNumeroContratAssocie
                       and ttUnite.noapp = 998
                       and ttUnite.noact = 0) then do:
        create ttUnite.
        assign
            ttUnite.noman = viNumeroMandantContratAssocie
            ttUnite.nomdt = piNumeroContratAssocie
            ttUnite.noapp = 998
            ttUnite.noact = 0
            ttUnite.nocmp = 010
            ttUnite.cdcmp = "00004"
            ttUnite.dtdeb = pdaDebutContratAssocie
            ttUnite.noimm = ttBienMandat.iNumeroImmeuble
            ttUnite.norol = 0
            ttUnite.cdocc = "00002"
            ttUnite.CRUD  = "C"
        .
    end.
    /* rattachement du lot a unite de location 998 */
    create ttCpuni.
    assign
        ttCpuni.nomdt = piNumeroContratAssocie
        ttCpuni.noapp = 998
        ttCpuni.nocmp = 010
        ttCpuni.noord = ?                                    //le numero d'ordre sera calcule dans cpuni_crud.p
        ttCpuni.noman = viNumeroMandantContratAssocie
        ttCpuni.noimm = ttBienMandat.iNumeroImmeuble
        ttCpuni.nolot = ttBienMandat.iNumeroLot
        ttCpuni.cdori = ""
        ttCpuni.sflot = ttBienMandat.iSfLot
        ttCpuni.CRUD  = "C"
    .

end procedure.

procedure setImmeuble:
    /*------------------------------------------------------------------------------
    Purpose: rattachement immeuble a un contrat 
    Notes  : service externe
 
// gga todo a reprendre pour le dev mutation     
//      viNoImmSel = integer(DonneParametre("PEC-MANDAT-GERANCE-NOIMM")).         gga todo voir avec Pascal utilisation DonneParametre
//                                                                                mais important de reprendre cette partie (si immeuble par defaut pas d'appel selection immeuble)
// utilise pour la creation des mandats en mutation. dans ce cas l'immeuble du nouveau mandat = celui du mandat initiale
// et dans la pec l'ecran des immeubles n'apparait pas       
    ------------------------------------------------------------------------------*/
    define input parameter table for ttMandat.

    define buffer ctrat for ctrat.
    define buffer intnt for intnt.

    find first ttMandat where ttMandat.CRUD = "U" no-error.
    if not available ttMandat then return.

    empty temp-table ttIntnt.
    find first ctrat no-lock
        where ctrat.tpcon = ttMandat.cCodeTypeContrat
          and ctrat.nocon = ttMandat.iNumeroContrat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 100057).
        return.
    end.
    if ctrat.fgprov = no then do:
        mError:createError({&error}, 1000656).      //mise à jour immeuble seulement autorisé pour les contrats provisoires
        return.
    end.
    for first ctrat no-lock
        where ctrat.tpcon     = {&TYPECONTRAT-mutationGerance}
          and ctrat.nomdt-ach = ttMandat.iNumeroContrat:
        mError:createError({&error}, 1000657).      //mise à jour immeuble sur mandat rattaché à une mutation interdite
        return.
    end.
    if not can-find(first imble no-lock
                    where imble.noimm = ttMandat.iNumeroImmeuble)
    then do:
        mError:createError({&error}, 101630).       //cet immeuble n'existe pas
        return.
    end.
    find first intnt no-lock
         where intnt.tpcon = ttMandat.cCodeTypeContrat
           and intnt.nocon = ttMandat.iNumeroContrat
           and intnt.tpidt = {&TYPEBIEN-immeuble} no-error.
    if available intnt 
    then do: 
        if intnt.noidt = ttMandat.iNumeroImmeuble        //pas de changement immeuble, on ne fait rien 
        then return. 
        if can-find(first intnt no-lock
                    where intnt.tpcon = ttMandat.cCodeTypeContrat
                      and intnt.nocon = ttMandat.iNumeroContrat
                      and intnt.tpidt = {&TYPEBIEN-lot})
        then do:
            mError:createError({&error}, 1000722).         //Vous ne pouvez pas changer l'immeuble, au moins un lot est rattaché au mandat
            return.                                              
        end. 
        create ttIntnt.
        assign
            ttIntnt.tpidt       = {&TYPEBIEN-immeuble}
            ttIntnt.noidt       = intnt.noidt
            ttIntnt.tpcon       = intnt.tpcon
            ttIntnt.nocon       = intnt.nocon
            ttIntnt.nbnum       = intnt.nbnum
            ttIntnt.idpre       = intnt.idpre
            ttIntnt.idsui       = intnt.idsui
            ttIntnt.rRowid      = rowid(intnt)
            ttIntnt.dtTimestamp = datetime(intnt.dtmsy, intnt.hemsy) 
            ttIntnt.CRUD        = 'D'
        .
    end.
    create ttIntnt.
    assign
        ttIntnt.tpidt = {&TYPEBIEN-immeuble}
        ttIntnt.noidt = ttMandat.iNumeroImmeuble
        ttIntnt.tpcon = ttMandat.cCodeTypeContrat
        ttIntnt.nocon = ttMandat.iNumeroContrat
        ttIntnt.nbnum = 0
        ttIntnt.idsui = 0
        ttIntnt.nbden = 0
        ttIntnt.cdreg = ""
        ttIntnt.lbdiv = ""
        ttIntnt.CRUD  = 'C'
    .
    lancementPgm ("adblib/intnt_CRUD.p", "setIntnt", table ttIntnt by-reference).
    
end procedure.

procedure controleBien:
    /*------------------------------------------------------------------------------
    Purpose: controle bien
             immeuble doit etre rattache au contrat au moins un lot doit etre rattache au contrat 
    Notes  : service appelé par mandat.p
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.

    //appel recherche numero immeuble
    getNumeroImmeuble(piNumeroContrat, pcTypeContrat).
    if mError:erreur() then return.
    
    //recherche si au moins un lot rattache
    if not can-find(first intnt no-lock
                    where intnt.tpidt = {&TYPEBIEN-lot}
                      and intnt.tpcon = pcTypeContrat
                      and intnt.nocon = piNumeroContrat)
     then do:
        mError:createError({&error}, 1000653).                      //aucun lot n'est rattaché au contrat
        return.
     end.

end procedure.

procedure PrcMajprop private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de mise a jour du proprietaire dans l'acte (01035)
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContratProp as int64     no-undo.
    define input parameter pcTypeRole          as character no-undo.
    define input parameter piNumeroRole        as integer   no-undo.

    define variable vcNom      as character no-undo.
    define variable vcCivilite as character no-undo.

    define buffer ctrat for ctrat.
    
    for first ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-acte2propriete}
          and ctrat.nocon = piNumeroContratProp:
        if piNumeroRole <> 0 
        then assign
            vcNom      = outilFormatage:getNomTiers(pcTypeRole, piNumeroRole)
            vcCivilite = outilFormatage:getCiviliteNomTiers(pcTypeRole, piNumeroRole, no)
        .
        create ttCtrat.
        assign
            ttCtrat.CRUD        = "U"
            ttCtrat.dtTimestamp = datetime(ctrat.dtmsy, ctrat.hemsy) 
            ttCtrat.rRowid      = rowid(ctrat) 
            ttCtrat.tpcon       = ctrat.tpcon
            ttCtrat.nocon       = ctrat.nocon
            ttCtrat.tprol       = pcTypeRole
            ttCtrat.norol       = piNumeroRole
            ttCtrat.lbnom       = vcNom
            ttCtrat.lnom2       = vcCivilite
        .
    end.

end procedure.
