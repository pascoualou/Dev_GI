/*-----------------------------------------------------------------------------
File        : tacheCleMagnetique.p
Purpose     : 
Author(s)   : kantena - 2018/09/26
Notes       :
derniere revue:
-----------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2bien.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/glbsepar.i}
{tache/include/tache.i}

{immeubleEtLot/include/cleMagnetique.i}

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

    run crud/tache_CRUD.p persistent set vhTache.
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
        delete ttTache no-error.
        run setTache in vhTache(table ttTache by-reference).
    end.
    run destroy in vhTache.

end procedure.
