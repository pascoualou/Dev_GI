/*------------------------------------------------------------------------
    File        : tacheImmeuble.p
    Purpose     : 
    Author(s)   : kantena - 2017/12/18
    Notes       :
  ----------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2bien.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/glbsepar.i}
{tache/include/tache.i}

{immeubleEtLot/include/ascenseur.i}
{immeubleEtLot/include/cleMagnetique.i}
{immeubleEtLot/include/diagnostic.i}
{immeubleEtLot/include/digicode.i}
{immeubleEtLot/include/dommageOuvrage.i}
{immeubleEtLot/include/gardienLoge.i}
{immeubleEtLot/include/horairesOuverture.i}
{immeubleEtLot/include/immeubleAutre.i}
{immeubleEtLot/include/impotTaxeImmeuble.i}
{immeubleEtLot/include/mesureAdministrative.i}
{immeubleEtLot/include/plan.i}
{immeubleEtLot/include/reglementCopropriete.i}

{role/include/role.i}

function lControleHoraire returns logical private(input-output pcHeureMinute as character):
    /*------------------------------------------------------------------------------
    Purpose: controle le format d'une heure
    Notes  : doit être de la forme 'xx:xx' avec xx 0-9 ou vide et compris entre 0-23:0-59
    ------------------------------------------------------------------------------*/
    define variable viHeure  as integer no-undo.
    define variable viMinute as integer no-undo.

    if pcHeureMinute = "" then return true. // si aucun horaire n'est saisi
    assign
        viHeure  = integer(entry(1, pcHeureMinute, ':'))
        viMinute = integer(entry(2, pcHeureMinute, ':'))
    no-error.
    if error-status:error or viHeure > 23 or viMinute > 59
    then do:
        mError:createError({&error}, 211708).
        return false.
    end.
    pcHeureMinute = substitute('&1:&2', string(viHeure, '99'), string(viMinute, '99')).
    return true.

end function.

procedure setAscenseur:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beImmeuble.cls. ATTENTION, un seul iNumeroImmeuble
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContratConstruction as int64 no-undo.
    define input parameter table for ttAscenseur.
    define input parameter table for ttControleTechnique.

    define variable vhTache as handle no-undo.

    define buffer imble for imble.
    define buffer batim for batim.

    run tache/tache.p persistent set vhTache.
    run getTokenInstance in vhTache(mToken:JSessionId).
    
    empty temp-table ttTache.
    if piNumeroContratConstruction <> 0
    then for each ttAscenseur:
        create ttTache.
        assign
            ttTache.noita = ttAscenseur.iNumeroTache
            ttTache.tpcon = {&TYPECONTRAT-construction}
            ttTache.nocon = piNumeroContratConstruction
            ttTache.tptac = {&TYPETACHE-ascenseurs}
            ttTache.notac = ttAscenseur.iChronoTache
            ttTache.ntges = ttAscenseur.cCodeAscenseur
            ttTache.dtdeb = ttAscenseur.daDateDebut
            ttTache.tpfin = ttAscenseur.cCodeFournisseur
            ttTache.ntges = ttAscenseur.cNumeroSerie
            ttTache.tpges = ttAscenseur.cCodeBatiment
            ttTache.CRUD        = ttAscenseur.CRUD
            ttTache.dtTimestamp = ttAscenseur.dtTimestamp
            ttTache.rRowid      = ttAscenseur.rRowid
        .
    end.
    run setTache in vhTache(table ttTache by-reference).
    if not mError:erreur() then do:
        for each ttTache
            where ttTache.CRUD = 'D' or ttTache.CRUD = 'C':
            for first imble exclusive-lock
                where imble.noimm = ttAscenseur.iNumeroImmeuble:
                imble.nbasc = imble.nbasc + (if ttTache.CRUD = 'D' then -1 else 1).
            end.
            for first batim exclusive-lock
                where batim.noimm = ttAscenseur.iNumeroImmeuble
                  and batim.cdbat = ttAscenseur.cCodeBatiment:
                batim.nbasc = batim.nbasc + (if ttTache.CRUD = 'D' then -1 else 1).
            end.
        end.
        empty temp-table ttTache.
        for each ttControleTechnique:
            create ttTache.
            assign
                ttTache.noita = ttControleTechnique.iNumeroTache
                ttTache.tpcon = {&TYPECONTRAT-construction}
                ttTache.nocon = piNumeroContratConstruction
                ttTache.tptac = {&TYPETACHE-ctlTechniqueAscenseur}
                ttTache.notac = ttControleTechnique.iChronoTache
                ttTache.ntges = string(ttControleTechnique.iNUmeroLien)
                ttTache.tpfin = ttControleTechnique.cCodeFournisseur
                ttTache.pdreg = ttControleTechnique.cNomControlleur
                ttTache.dtdeb = ttControleTechnique.daDateControle
                ttTache.tpges = ttControleTechnique.cCodeResultat
                ttTache.pdges = if ttControleTechnique.lTravauxAEffectuer then {&oui} else ""
                ttTache.cdreg = if ttControleTechnique.lTravauxEffectues  then {&oui} else ""
                ttTache.dtfin = ttControleTechnique.daDateFinTravaux
                ttTache.dtree = ttControleTechnique.daDatePrevue
                ttTache.dtreg = ttControleTechnique.daDateEffective
                ttTache.ntreg = ttControleTechnique.cVisiteCodeResultat
                ttTache.lbdiv = ttControleTechnique.cCommentaire
                ttTache.utreg = string(ttControleTechnique.daDateProchainControle)
                ttTache.CRUD        = ttControleTechnique.CRUD
                ttTache.dtTimestamp = ttControleTechnique.dtTimestamp
                ttTache.rRowid      = ttControleTechnique.rRowid
           //   ttTache.utreg = string(ttControleTechnique.dDateProchain)
            .
        end.
        run setTache in vhTache(table ttTache by-reference).
    end.
    if valid-handle(vhTache) then run destroy in vhTache.

end procedure.

procedure setCleMagnetique:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContratConstruction as int64 no-undo.
    define input parameter table for ttCleMagnetique.
    define input parameter table for ttCleMagnetiqueDetail.

    define variable vhTache as handle no-undo.

    define buffer ttTache   for ttTache.
    define buffer vbttTache for ttTache.

    run tache/tache.p persistent set vhTache.
    run getTokenInstance in vhTache(mToken:JSessionId).
    for each ttCleMagnetique:
        empty temp-table ttTache.
        create ttTache.
        assign
            ttTache.tptac = {&TYPETACHE-cleMagnetiqueEntete}
            ttTache.noita = ttCleMagnetique.iNumeroCle
            ttTache.tpcon = {&TYPECONTRAT-construction}
            ttTache.nocon = piNumeroContratConstruction
            ttTache.tpfin = ttCleMagnetique.cLibelle1
            ttTache.ntges = ttCleMagnetique.cLibelle2
            ttTache.tpges = ttCleMagnetique.cCodeBatiment
            ttTache.cdhon = ttCleMagnetique.cCodeEntree
            ttTache.tphon = ttCleMagnetique.cCodeEscalier
            ttTache.pdges = ttCleMagnetique.cCodeFournisseur
            ttTache.duree = ttCleMagnetique.iNombreCle
            ttTache.CRUD        = ttCleMagnetique.CRUD
            ttTache.dtTimestamp = ttCleMagnetique.dtTimestamp
            ttTache.rRowid      = ttCleMagnetique.rRowid
        .
        run setTache in vhTache(table ttTache by-reference).
        for each ttCleMagnetiqueDetail
            where ttCleMagnetiqueDetail.iNumeroCle = ttCleMagnetique.iNumeroCle:
            create vbttTache.
            assign
                vbttTache.tptac = {&TYPETACHE-cleMagnetiqueDetails}
                vbttTache.noita = ttCleMagnetiqueDetail.iNumeroDetail
                vbttTache.tpcon = {&TYPECONTRAT-construction}
                vbttTache.nocon = piNumeroContratConstruction
                vbttTache.notac = ttCleMagnetiqueDetail.iChronoTache
                vbttTache.tpfin = string(ttCleMagnetiqueDetail.iNumeroLot)
                vbttTache.ntges = ttCleMagnetiqueDetail.cNumeroCompte
                vbttTache.dcreg = ttCleMagnetiqueDetail.cCodeTypeRole
                vbttTache.pdges = ttCleMagnetiqueDetail.iNumeroTiers
                vbttTache.utreg = ttCleMagnetiqueDetail.cNomTiers
                vbttTache.cdreg = string(ttCleMagnetiqueDetail.iNombrePieceRemise)
                vbttTache.ntreg = ttCleMagnetiqueDetail.cNumeroSerie
                vbttTache.pdreg = string(ttCleMagnetiqueDetail.dMontantCaution)
                vbttTache.dtdeb = ttCleMagnetiqueDetail.daDateRemise
                vbttTache.dtfin = ttCleMagnetiqueDetail.daDateRestitution
                vbttTache.lbdiv = ttCleMagnetiqueDetail.cCommentaire
                vbttTache.tpges = string(ttTache.noita)
                vbttTache.CRUD        = ttCleMagnetiqueDetail.CRUD
                vbttTache.dtTimestamp = ttCleMagnetiqueDetail.dtTimestamp
                vbttTache.rRowid      = ttCleMagnetiqueDetail.rRowid
            .
        end.
        delete ttTache.
        run setTache in vhTache(table ttTache by-reference).
    end.
    if valid-handle(vhTache) then run destroy in vhTache.
    
end procedure.

procedure setDiagnosticEtude:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beImmeuble.cls et beLot.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContratConstruction as int64   no-undo.
    define input parameter piNumeroBien                as integer no-undo. /* Numéro lot si privatif (si appelé par beLot.cls) */
    define input parameter table for ttDiagnosticEtude.

    define variable vhTache as handle no-undo.

    define buffer local for local.
    define buffer taint for taint.
    define buffer ttTache for ttTache.

    run tache/tache.p persistent set vhTache.
    run getTokenInstance in vhTache(mToken:JSessionId).

    empty temp-table ttTache.
    for each ttDiagnosticEtude:
        create ttTache.
        assign
            ttTache.noita         = ttdiagnosticEtude.iNumeroTache
            ttTache.tpcon         = {&TYPECONTRAT-construction}
            ttTache.nocon         = piNumeroContratConstruction
            ttTache.tptac         = ttdiagnosticEtude.cCodeTypeTache
            ttTache.notac         = ttdiagnosticEtude.iChronoTache
            ttTache.cdhon         = if ttdiagnosticEtude.cCodeOrganisme > "" then substitute("FOU,&1", ttdiagnosticEtude.cCodeOrganisme) else ""
            ttTache.utreg         = ttdiagnosticEtude.cLibelleOrganisme
            ttTache.DcReg         = ttdiagnosticEtude.cCodeDisposition
            ttTache.ntreg         = ttdiagnosticEtude.cCodeBatiment
            ttTache.dtdeb         = ttdiagnosticEtude.daDateRecherche
            ttTache.tpfin         = ttdiagnosticEtude.cCodeResultatRecherche
            ttTache.dtfin         = ttdiagnosticEtude.daDatePrevueDT
            ttTache.dtree         = ttdiagnosticEtude.daDateRealiseeDT
            ttTache.dtreg         = ttdiagnosticEtude.daDateControle
            ttTache.NtGes         = string(ttdiagnosticEtude.lControle, {&ouiNon})
            ttTache.tpGes         = string(ttdiagnosticEtude.lSurveillance, {&ouiNon})
            ttTache.PdGes         = string(ttdiagnosticEtude.lTravaux, {&ouiNon})
            ttTache.cdreg         = ttdiagnosticEtude.cCommentaire
            ttTache.etqenergie    = ttdiagnosticEtude.cEtiquetteEnergie
            ttTache.etqclimat     = ttdiagnosticEtude.cEtiquetteClimat
            ttTache.valetqenergie = ttdiagnosticEtude.iValeurEtiquetteEnergie
            ttTache.valetqclimat  = ttdiagnosticEtude.iValeurEtiquetteClimat
            ttTache.pdreg         = if ttdiagnosticEtude.lPrivatif then "TRUE" else "FALSE"
            ttTache.CRUD          = ttDiagnosticEtude.CRUD
            ttTache.dtTimestamp   = ttdiagnosticEtude.dtTimestamp
            ttTache.rRowid        = ttdiagnosticEtude.rRowid
        .
        run setTache in vhTache(table ttTache by-reference).
        if available ttTache and ttDiagnosticEtude.lPrivatif then do:
            if ttDiagnosticEtude.crud = 'D' then do:
                find first local no-lock
                    where local.noloc = piNumeroBien no-error.
                if available local
                then for first taint exclusive-lock
                    where taint.tpcon = {&TYPECONTRAT-construction}
                      and taint.nocon = piNumeroContratConstruction
                      and taint.tptac = ttdiagnosticEtude.cCodeTypeTache
                      and taint.notac = ttTache.notac
                      and taint.noidt = local.noloc
                      and taint.tpidt = {&TYPEBIEN-lot}:
                    delete taint.
                end.
            end.
            if ttDiagnosticEtude.crud = 'C' or ttDiagnosticEtude.crud = 'U' then do:
                find first local no-lock
                     where local.noloc = piNumeroBien no-error.
                if available local and not can-find(first taint no-lock
                                                    where taint.tpcon = {&TYPECONTRAT-construction}
                                                      and taint.nocon = piNumeroContratConstruction
                                                      and taint.tptac = ttdiagnosticEtude.cCodeTypeTache
                                                      and taint.notac = ttTache.notac
                                                      and taint.noidt = local.noloc
                                                      and taint.tpidt = {&TYPEBIEN-lot})
                then do:
                    create taint.
                    assign
                        taint.tpcon = {&TYPECONTRAT-construction}
                        taint.nocon = piNumeroContratConstruction
                        taint.tptac = ttdiagnosticEtude.cCodeTypeTache
                        taint.notac = ttTache.notac
                        taint.noidt = local.noloc
                        taint.tpidt = {&TYPEBIEN-lot}
                    .
                end.
            end.
        end.
        delete ttTache.
    end.
    if valid-handle(vhTache) then run destroy in vhTache.

end procedure.

procedure setDigicode:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContratConstruction as int64 no-undo.
    define input parameter table for ttDigicode.
    define input parameter table for ttDigicodeImmeuble.

    define variable vhTache as handle no-undo.
    
    run tache/tache.p persistent set vhTache.
    run getTokenInstance in vhTache(mToken:JSessionId).

    empty temp-table ttTache.
    for each ttDigicodeImmeuble:
        create ttTache.
        assign
            ttTache.CRUD  = ttDigicodeImmeuble.CRUD
            ttTache.noita = ttDigicodeImmeuble.iNumeroDigicode
            ttTache.tpcon = {&TYPECONTRAT-construction}
            ttTache.nocon = piNumeroContratConstruction
            ttTache.tptac = {&TYPETACHE-digicode}
            ttTache.notac = ttDigicodeImmeuble.iChronoTache
            ttTache.TpFin = ttDigicodeImmeuble.cCodeBatiment
            ttTache.CdHon = ttDigicodeImmeuble.cCodeEntree
            ttTache.tphon = ttDigicodeImmeuble.cCodeEscalier
            /* THK : Abandonné
            ttTache.PdGes = string(ttDigicodeImmeuble.lJourOuverture[1], "1/0")
                          + string(ttDigicodeImmeuble.lJourOuverture[2], "1/0")
                          + string(ttDigicodeImmeuble.lJourOuverture[3], "1/0")
                          + string(ttDigicodeImmeuble.lJourOuverture[4], "1/0")
                          + string(ttDigicodeImmeuble.lJourOuverture[5], "1/0")
                          + string(ttDigicodeImmeuble.lJourOuverture[6], "1/0")
                          + string(ttDigicodeImmeuble.lJourOuverture[7], "1/0")
            ttTache.CdReg = ttDigicodeImmeuble.cHeureDebut
            ttTache.NtReg = ttDigicodeImmeuble.cHeureFin
            */
            ttTache.dtTimestamp = ttDigicodeImmeuble.dtTimestamp
            ttTache.rRowid      = ttDigicodeImmeuble.rRowid
        .
    end.

    for each ttDigicode:
        find first ttTache
            where ttTache.CRUD  = ttDigicode.CRUD
              and ttTache.noita = ttDigicode.iNumeroDigicode
              and ttTache.tpcon = {&TYPECONTRAT-construction}
              and ttTache.nocon = piNumeroContratConstruction
              and ttTache.tptac = {&TYPETACHE-digicode}
              and ttTache.notac = ttDigicode.iChronoTache no-error.
        if not available ttTache
        then do:
            create ttTache.
            assign
                ttTache.CRUD   = ttDigicode.CRUD
                ttTache.noita  = ttDigicode.iNumeroDigicode
                ttTache.tpcon  = {&TYPECONTRAT-construction}
                ttTache.nocon  = piNumeroContratConstruction
                ttTache.tptac  = {&TYPETACHE-digicode}
                ttTache.notac  = ttDigicode.iChronoTache
                ttTache.dtTimestamp = ttDigicode.dtTimestamp
                ttTache.rRowid      = ttDigicode.rRowid
            .
        end.
        case ttDigicode.iExtent:
            when 1 then assign
                ttTache.lbdiv  = ttDigicode.cLibelleDigicode
                ttTache.ntges  = ttDigicode.cAncienDigicode
                ttTache.dtfin  = ttDigicode.daDateFin
                ttTache.tpges  = ttDigicode.cNouveauDigicode
                ttTache.dtdeb  = ttDigicode.daDateDebut
            .
            when 2 then assign
                ttTache.lbdiv2 = ttDigicode.cLibelleDigicode
                ttTache.utreg  = ttDigicode.cAncienDigicode
                ttTache.dtree  = ttDigicode.daDateFin
                ttTache.pdreg  = ttDigicode.cNouveauDigicode
                ttTache.dtreg  = ttDigicode.daDateDebut
        .
        end case.
    end.
    run setTache in vhTache(table ttTache by-reference).
    if valid-handle(vhTache) then run destroy in vhTache.

end procedure.

procedure setDommageOuvrage:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContratConstruction as int64 no-undo.
    define input parameter table for ttDommageOuvrage.
   
    define variable vhTache as handle no-undo.

    run tache/tache.p persistent set vhTache.
    run getTokenInstance in vhTache(mToken:JSessionId).

    empty temp-table ttTache.
    for each ttDommageOuvrage:
        create ttTache.
        assign
            ttTache.CRUD  = ttDommageOuvrage.CRUD
            ttTache.noita = ttDommageOuvrage.iNumeroTache
            ttTache.tpcon = {&TYPECONTRAT-construction}
            ttTache.nocon = piNumeroContratConstruction
            ttTache.tptac = {&TYPETACHE-dommageOuvrage}
            ttTache.notac = ttDommageOuvrage.iChronoTache
            ttTache.tpfin = ttDommageOuvrage.cPolice
            ttTache.tphon = ttDommageOuvrage.cGarantie
            ttTache.ntges = string(ttDommageOuvrage.iNumeroCompagnie)
            ttTache.tpges = string(ttDommageOuvrage.iNumeroCourtier)
            ttTache.pdges = ttDommageOuvrage.cCodeFournisseur
            ttTache.dtree = ttDommageOuvrage.daDateReception
            ttTache.dtdeb = ttDommageOuvrage.daDateDebut
            ttTache.dtfin = ttDommageOuvrage.daDateFin
            ttTache.cdhon = ttDommageOuvrage.cCommentaireTravaux
            ttTache.cdreg = ttDommageOuvrage.cCodetypeOuvrage
            ttTache.ntreg = ttDommageOuvrage.cCodeBatiment
            ttTache.dtTimestamp = ttDommageOuvrage.dtTimestamp
            ttTache.rRowid      = ttDommageOuvrage.rRowid
        .
    end.
    run setTache in vhTache(table ttTache by-reference).
    if valid-handle(vhTache) then run destroy in vhTache.

end procedure.

procedure setPlan:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beImmeuble.cls et beLot.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContratConstruction as int64   no-undo.
    define input parameter piNumeroBien                as integer no-undo. /* Numéro lot si privatif (si appelé par beLot.cls) */
    define input parameter table for ttPlan.

    define variable vhTache as handle no-undo.

    define buffer local for local.
    define buffer taint for taint.
    define buffer ttTache for ttTache.

    run tache/tache.p persistent set vhTache.
    run getTokenInstance in vhTache(mToken:JSessionId).

    empty temp-table ttTache.
    for each ttPlan:
        create ttTache.
        assign
            ttTache.noita = ttPlan.iNumeroPlan
            ttTache.tpcon = {&TYPECONTRAT-construction}
            ttTache.nocon = piNumeroContratConstruction
            ttTache.tptac = {&TYPETACHE-plan}
            ttTache.notac = ttPlan.iChronoTache
            ttTache.DcReg = ttPlan.cTypePlan
            ttTache.ntreg = ttPlan.cCodeBatiment
            ttTache.pdreg = if ttPlan.lPrivatif then "TRUE" else "FALSE"
            ttTache.utreg = ttPlan.cNomOrganisme
            ttTache.dtdeb = ttPlan.daDatePlan
            ttTache.cdreg = ttPlan.cCommentaire
            ttTache.CRUD        = ttPlan.CRUD
            ttTache.dtTimestamp = ttPlan.dtTimestamp
            ttTache.rRowid      = ttPlan.rRowid
        .
        run setTache in vhTache(table ttTache by-reference).
        if available ttTache and ttPlan.lprivatif then do:
            // Suppression des lots privatifs
            if ttPlan.crud = 'D' then do:
                find first local no-lock
                    where local.noloc = piNumeroBien no-error.
                if available local
                then for first taint exclusive-lock
                    where taint.tpcon = {&TYPECONTRAT-construction}
                      and taint.nocon = piNumeroContratConstruction
                      and taint.tptac = {&TYPETACHE-plan}
                      and taint.notac = ttTache.notac
                      and taint.noidt = local.noloc
                      and taint.tpidt = {&TYPEBIEN-lot}:
                    delete taint.
                end.
            end.
            // Création et modification des lots privatifs
            if ttPlan.crud = 'C' or ttPlan.crud = 'U' then do:
                find first local no-lock
                    where local.noloc = piNumeroBien no-error.
                if available local and not can-find(first taint no-lock
                    where taint.tpcon = {&TYPECONTRAT-construction}
                      and taint.nocon = piNumeroContratConstruction
                      and taint.tptac = {&TYPETACHE-plan}
                      and taint.notac = ttTache.notac
                      and taint.noidt = local.noloc
                      and taint.tpidt = {&TYPEBIEN-lot})
                then do:
                    create taint.
                    assign
                        taint.tpcon = {&TYPECONTRAT-construction}
                        taint.nocon = piNumeroContratConstruction
                        taint.tptac = {&TYPETACHE-plan}
                        taint.notac = ttTache.notac
                        taint.noidt = local.noloc
                        taint.tpidt = {&TYPEBIEN-lot}
                    .
                end.
            end.
        end.
        delete ttTache.
    end.
    if valid-handle(vhTache) then run destroy in vhTache.

end procedure.

procedure setLoges:
    /*------------------------------------------------------------------------------
    Purpose: TODO: controler le format de l'heure hh:mm (entre 00:00 et 24:00)
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input parameter table for ttLoge.
    define input parameter table for ttHorairesOuvSerie1.
    define input parameter table for ttHorairesOuvSerie2.

    define variable vhTache as handle no-undo.

    run tache/tache.p persistent set vhTache.
    run getTokenInstance in vhTache(mToken:JSessionId).

    empty temp-table ttTache.
    for each ttLoge:
        create ttTache.
        assign
            ttTache.CRUD        = ttLoge.CRUD
            ttTache.notac       = 1
            ttTache.noita       = ttLoge.iNumeroTache
            ttTache.nocon       = ttLoge.iNumeroContrat
            ttTache.tpcon       = ttLoge.cTypeContrat
            ttTache.tptac       = ttLoge.cTypeTache
            ttTache.tpges       = if ttLoge.cNomTiersDepannage  <> ? then ttLoge.cNomTiersDepannage  else ""
            ttTache.cdreg       = if ttLoge.cCodeTiersDepannage <> ? then ttLoge.cCodeTiersDepannage else ""
            ttTache.lbdiv       = substitute('&1&2&2', ttLoge.cCommentaire, separ[1])      // ne pas enlever !!! legacy (3 entrées separ[1])
            ttTache.dcreg       = ttLoge.cCoordonneeContact1  + separ[1] + ttLoge.cCoordonneeContact2
            ttTache.lbdiv2      = ''  // ne pas enlever !!! legacy
            ttTache.lbdiv3      = ''  // ne pas enlever !!! legacy
            ttTache.dtTimestamp = ttLoge.dtTimestamp
            ttTache.rRowid      = ttLoge.rRowid
        .
        for first ttHorairesOuvSerie1
            where ttLoge.iNumeroLoge = ttHorairesOuvSerie1.iNumeroIdentifiant:
            if not lControleHoraire(input-output ttHorairesOuvSerie1.cHeureDebut1)
            or not lControleHoraire(input-output ttHorairesOuvSerie1.cHeureFin1)
            or not lControleHoraire(input-output ttHorairesOuvSerie1.cHeureDebut2)
            or not lControleHoraire(input-output ttHorairesOuvSerie1.cHeureFin2) then return.

            ttTache.tphon = ttHorairesOuvSerie1.cHeureDebut1 + separ[2] + ttHorairesOuvSerie1.cHeureFin1 + separ[1]
                          + ttHorairesOuvSerie1.cHeureDebut2 + separ[2] + ttHorairesOuvSerie1.cHeureFin2 + separ[1]
                          + string(ttHorairesOuvSerie1.lJourOuverture[1], '1/0')
                          + string(ttHorairesOuvSerie1.lJourOuverture[2], '1/0')
                          + string(ttHorairesOuvSerie1.lJourOuverture[3], '1/0')
                          + string(ttHorairesOuvSerie1.lJourOuverture[4], '1/0')
                          + string(ttHorairesOuvSerie1.lJourOuverture[5], '1/0')
                          + string(ttHorairesOuvSerie1.lJourOuverture[6], '1/0')
                          + string(ttHorairesOuvSerie1.lJourOuverture[7], '1/0').
        end.
        for first ttHorairesOuvSerie2
            where ttLoge.iNumeroLoge = ttHorairesOuvSerie2.iNumeroIdentifiant:
            if not lControleHoraire(input-output ttHorairesOuvSerie2.cHeureDebut1)
            or not lControleHoraire(input-output ttHorairesOuvSerie2.cHeureFin1)
            or not lControleHoraire(input-output ttHorairesOuvSerie2.cHeureDebut2)
            or not lControleHoraire(input-output ttHorairesOuvSerie2.cHeureFin2) then return.

            ttTache.ntges = ttHorairesOuvSerie2.cHeureDebut1 + separ[2] + ttHorairesOuvSerie2.cHeureFin1 + separ[1]
                          + ttHorairesOuvSerie2.cHeureDebut2 + separ[2] + ttHorairesOuvSerie2.cHeureFin2 + separ[1]
                          + string(ttHorairesOuvSerie2.lJourOuverture[1], '1/0')
                          + string(ttHorairesOuvSerie2.lJourOuverture[2], '1/0')
                          + string(ttHorairesOuvSerie2.lJourOuverture[3], '1/0')
                          + string(ttHorairesOuvSerie2.lJourOuverture[4], '1/0')
                          + string(ttHorairesOuvSerie2.lJourOuverture[5], '1/0')
                          + string(ttHorairesOuvSerie2.lJourOuverture[6], '1/0')
                          + string(ttHorairesOuvSerie2.lJourOuverture[7], '1/0').
        end.
    end.
    run setTache in vhTache(table ttTache by-reference).
    if valid-handle(vhTache) then run destroy in vhTache.
    
end procedure.

procedure setGardien:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContratConstruction as int64 no-undo.
    define input parameter table for ttGardien.
    define input parameter table for ttRole.
    define input parameter table for ttHorairesOuvSerie1.
    define input parameter table for ttHorairesOuvSerie2.

    define variable vhTache as handle no-undo.

    run tache/tache.p persistent set vhTache.
    run getTokenInstance in vhTache(mToken:JSessionId).

    empty temp-table ttTache.
    for each ttGardien:
        create ttTache.
        assign
            ttTache.CRUD        = ttGardien.CRUD
            ttTache.noita       = ttGardien.iNumeroTache
            ttTache.tpcon       = {&TYPECONTRAT-construction}
            ttTache.nocon       = piNumeroContratConstruction
            ttTache.tptac       = {&TYPETACHE-gardien}
            ttTache.notac       = ttGardien.iChronoTache
            ttTache.tpges       = ttGardien.cNomGardien when ttGardien.cNomGardien > ""
            ttTache.dcreg       = ttGardien.cCoordonneeContact1 + separ[1] + ttGardien.cCoordonneeContact2
            ttTache.dtTimestamp = ttGardien.dtTimestamp
            ttTache.rRowid      = ttGardien.rRowid
            ttTache.fgrev       = ttGardien.lPrincipal
            ttTache.tpfin       = ttGardien.cCodeBatiment
            ttTache.CdHon       = ttGardien.cCodeEntree
            ttTache.utreg       = ttGardien.cCodeEscalier
            tttache.lbdiv2      = ttGardien.cCommentaire
        .
        for first ttHorairesOuvSerie1
            where ttHorairesOuvSerie1.iNumeroIdentifiant = ttGardien.iNumeroTache:
            if not lControleHoraire(input-output ttHorairesOuvSerie1.cHeureDebut1)
            or not lControleHoraire(input-output ttHorairesOuvSerie1.cHeureFin1)
            or not lControleHoraire(input-output ttHorairesOuvSerie1.cHeureDebut2)
            or not lControleHoraire(input-output ttHorairesOuvSerie1.cHeureFin2)
            then return.

            ttTache.tphon = ttHorairesOuvSerie1.cHeureDebut1 + separ[2] + ttHorairesOuvSerie1.cHeureFin1 + separ[1]
                          + ttHorairesOuvSerie1.cHeureDebut2 + separ[2] + ttHorairesOuvSerie1.cHeureFin2 + separ[1]
                          + string(ttHorairesOuvSerie1.lJourOuverture[1], '1/0')
                          + string(ttHorairesOuvSerie1.lJourOuverture[2], '1/0')
                          + string(ttHorairesOuvSerie1.lJourOuverture[3], '1/0')
                          + string(ttHorairesOuvSerie1.lJourOuverture[4], '1/0')
                          + string(ttHorairesOuvSerie1.lJourOuverture[5], '1/0')
                          + string(ttHorairesOuvSerie1.lJourOuverture[6], '1/0')
                          + string(ttHorairesOuvSerie1.lJourOuverture[7], '1/0').
        end.
        for first ttHorairesOuvSerie2
            where ttHorairesOuvSerie2.iNumeroIdentifiant = ttGardien.iNumeroTache:
            if not lControleHoraire(input-output ttHorairesOuvSerie2.cHeureDebut1)
            or not lControleHoraire(input-output ttHorairesOuvSerie2.cHeureFin1)
            or not lControleHoraire(input-output ttHorairesOuvSerie2.cHeureDebut2)
            or not lControleHoraire(input-output ttHorairesOuvSerie2.cHeureFin2) then return.

            ttTache.ntges = ttHorairesOuvSerie2.cHeureDebut1 + separ[2] + ttHorairesOuvSerie2.cHeureFin1 + separ[1]
                          + ttHorairesOuvSerie2.cHeureDebut2 + separ[2] + ttHorairesOuvSerie2.cHeureFin2 + separ[1]
                          + string(ttHorairesOuvSerie2.lJourOuverture[1], '1/0')
                          + string(ttHorairesOuvSerie2.lJourOuverture[2], '1/0')
                          + string(ttHorairesOuvSerie2.lJourOuverture[3], '1/0')
                          + string(ttHorairesOuvSerie2.lJourOuverture[4], '1/0')
                          + string(ttHorairesOuvSerie2.lJourOuverture[5], '1/0')
                          + string(ttHorairesOuvSerie2.lJourOuverture[6], '1/0')
                          + string(ttHorairesOuvSerie2.lJourOuverture[7], '1/0').
        end.
        for first ttRole
            where ttRole.iNumeroIdentifiant = ttGardien.iNumeroTache:
            assign
                ttTache.tprol = ttRole.cCodeTypeRole
                ttTache.norol = ttRole.iNumeroRole
            .
        end.
    end.
    run setTache in vhTache(table ttTache by-reference).
    if valid-handle(vhTache) then run destroy in vhTache.

end procedure.

procedure setImpotTaxe:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContratConstruction as int64 no-undo.
    define input parameter table for ttImpotTaxe.

    define variable vhTache as handle no-undo.

    run tache/tache.p persistent set vhTache.
    run getTokenInstance in vhTache(mToken:JSessionId).

    empty temp-table ttTache.
    for each ttImpotTaxe:
        create ttTache.
        assign
            ttTache.CRUD        = ttImpotTaxe.CRUD
            ttTache.noita       = ttImpotTaxe.iNumeroTache
            ttTache.tpcon       = {&TYPECONTRAT-construction}
            ttTache.nocon       = piNumeroContratConstruction
            ttTache.tptac       = {&TYPETACHE-organismesSociaux}
            ttTache.notac       = ttImpotTaxe.iChronoTache
            ttTache.tpfin       = ttImpotTaxe.cCodeTypeOrganisme
            ttTache.ntges       = ttImpotTaxe.cNumeroOrganisme
            ttTache.dtTimestamp = ttImpotTaxe.dtTimestamp
            ttTache.rRowid      = ttImpotTaxe.rRowid
        .
    end.
    run setTache in vhTache(table ttTache by-reference).
    if valid-handle(vhTache) then run destroy in vhTache.

end procedure.

procedure setTravaux:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContratConstruction as int64 no-undo.
    define input parameter table for ttTravaux.
    define input parameter table for ttFournisseur.

    define variable vcListeFournisseur as character no-undo.
    define variable vhTache as handle no-undo.

    run tache/tache.p persistent set vhTache.
    run getTokenInstance in vhTache(mToken:JSessionId).

    empty temp-table ttTache.
    // Seul les travaux avec numéro de dossier à 0 sont éditables
    for each ttTravaux
        where ttTravaux.iNumeroDossier = 0:
        create ttTache.
        assign
            ttTache.CRUD  = ttTravaux.CRUD
            ttTache.noita = ttTravaux.iNumeroTache
            ttTache.tpcon = {&TYPECONTRAT-construction}
            ttTache.nocon = piNumeroContratConstruction
            ttTache.tptac = {&TYPETACHE-travauxXXXX3}
            ttTache.notac = ttTravaux.iChronoTache
            ttTache.dtdeb = ttTravaux.daDateAG
            ttTache.dtree = ttTravaux.daDateDebut
            ttTache.dtfin = ttTravaux.daDateFin
            ttTache.tpfin = ttTravaux.cTypeContrat
            ttTache.duree = ttTravaux.iNumeroContrat
            ttTache.TpGes = ttTravaux.cLibelleTravaux
            ttTache.NtGes = ttTravaux.cCodeTypeTravaux
            ttTache.MtReg = ttTravaux.dMontantRealise
            ttTache.pdges = ttTravaux.cCodeBatiment
            ttTache.cdreg = string(ttTravaux.iNumeroLien)
            ttTache.dtTimestamp = ttTravaux.dtTimestamp
            ttTache.rRowid      = ttTravaux.rRowid
        .
        for each ttFournisseur
            where ttFournisseur.iNumeroDossier = 0
              and ttFournisseur.iNumeroTache   = ttTravaux.iNumeroTache
            break by ttFournisseur.iNumeroTache:
            if first-of(ttFournisseur.iNumeroTache) then vcListeFournisseur = ''.
            vcListeFournisseur = substitute('&1&&&2#&3', vcListeFournisseur, ttFournisseur.iNumeroFournisseur, ttFournisseur.dMontantRealise).
            if last-of(ttFournisseur.iNumeroTache) then ttTache.cdhon = trim(vcListeFournisseur, '&').
        end.
    end.
    run setTache in vhTache(table ttTache by-reference).
    if valid-handle(vhTache) then run destroy in vhTache.

end procedure.

procedure setMesureAdministrative:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input parameter table for ttMesureAdministrative.
    define variable vcValeurReponse as character no-undo.

    define variable vhTache as handle no-undo.

    run tache/tache.p persistent set vhTache.
    run getTokenInstance in vhTache(mToken:JSessionId).

    empty temp-table ttTache.
    for first ttMesureAdministrative:
        create ttTache.
        assign
            ttTache.noita = ttMesureAdministrative.iNumeroTache
            ttTache.tpcon = ttMesureAdministrative.cTypeContrat
            ttTache.nocon = ttMesureAdministrative.iNumeroContrat
            ttTache.tptac = ttMesureAdministrative.cCodeTypeTache
            ttTache.notac = ttMesureAdministrative.iChronoTache
            ttTache.CRUD        = ttMesureAdministrative.CRUD
            ttTache.dtTimestamp = ttMesureAdministrative.dtTimestamp
            ttTache.rRowid      = ttMesureAdministrative.rRowid
        .
    end.

    for each ttMesureAdministrative:
        assign
            vcValeurReponse = if ttMesureAdministrative.lValeurReponse then {&oui} else {&non}
            vcValeurReponse = if ttMesureAdministrative.cCommentaire > ""
                              then substitute('&1&2&3', vcValeurReponse, separ[1], ttMesureAdministrative.cCommentaire)
                              else substitute('&1&2',   vcValeurReponse, separ[1])
            vcValeurReponse = if ttMesureAdministrative.daDateDebut <> ?
                              then substitute('&1&2&3', vcValeurReponse, separ[1], ttMesureAdministrative.daDateDebut)
                              else substitute('&1&2',   vcValeurReponse, separ[1])
            vcValeurReponse = if ttMesureAdministrative.daDateFin <> ?
                              then substitute('&1&2&3', vcValeurReponse, separ[1], ttMesureAdministrative.daDateFin)
                              else vcValeurReponse
        .
        case ttMesureAdministrative.cCodeReponse:
            when "CdPer" then ttTache.tpfin = vcValeurReponse.
            when "CdIns" then ttTache.ntges = vcValeurReponse.
            when "CdInj" then ttTache.tpges = vcValeurReponse.
            when "CdHis" then ttTache.dcreg = vcValeurReponse.
            when "CdHab" then ttTache.pdges = vcValeurReponse.
            when "CdRav" then ttTache.cdreg = vcValeurReponse.
            when "CdSau" then ttTache.ntreg = vcValeurReponse.
            when "CdCla" then ttTache.pdreg = vcValeurReponse.
        end case.
    end.
    run setTache in vhTache(table ttTache by-reference).
    if valid-handle(vhTache) then run destroy in vhTache.

end procedure.

procedure setReglementCopropriete:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContratConstruction as int64 no-undo.
    define input parameter table for ttReglementCopropriete.

    define variable vhTache as handle no-undo.

    run tache/tache.p persistent set vhTache.
    run getTokenInstance in vhTache(mToken:JSessionId).

    empty temp-table ttTache.
    for each ttReglementCopropriete:
        create ttTache.
        assign
            ttTache.noita = ttReglementCopropriete.iNumeroReglement
            ttTache.tpcon = {&TYPECONTRAT-construction}
            ttTache.nocon = piNumeroContratConstruction
            ttTache.tptac = {&TYPETACHE-reglement2copro}
            ttTache.notac = ttReglementCopropriete.iChronoTache
            ttTache.dtdeb = ttReglementCopropriete.daDateReglement
            ttTache.tpfin = ttReglementCopropriete.cLieuReglement
            ttTache.dtfin = ttReglementCopropriete.daDatePublication
            ttTache.ntges = ttReglementCopropriete.cNomBureau
            ttTache.tpges = string(ttReglementCopropriete.iNumeroNotaire)
            ttTache.pdges = ttReglementCopropriete.cVolume                  // npo #7791
            ttTache.pdreg = ttReglementCopropriete.cNumero                  // npo #7791
            ttTache.duree = ttReglementCopropriete.iTotalLot
            ttTache.cdreg = string(ttReglementCopropriete.iNombreLotsPrincipaux)
            ttTache.ntreg = ttReglementCopropriete.cCommentaire
            ttTache.CRUD        = ttReglementCopropriete.CRUD
            ttTache.dtTimestamp = ttReglementCopropriete.dtTimestamp
            ttTache.rRowid      = ttReglementCopropriete.rRowid
        .
    end.
    run setTache in vhTache(table ttTache by-reference).
    if valid-handle(vhTache) then run destroy in vhTache.

end procedure.
    