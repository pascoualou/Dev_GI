/*-----------------------------------------------------------------------------
File        : tacheAscenseur.p
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

{immeubleEtLot/include/ascenseur.i}

procedure setAscenseur:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beImmeuble.cls. ATTENTION, un seul iNumeroImmeuble
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContratConstruction as int64 no-undo.
    define input parameter table for ttAscenseur.
    define input parameter table for ttControleTechnique.

    define variable vhTache as handle no-undo.
    define variable vcNumeroTacheAscenseur as character no-undo.
    define buffer imble for imble.
    define buffer batim for batim.

    run crud/tache_CRUD.p persistent set vhTache.
    run getTokenInstance in vhTache(mToken:JSessionId).

    if piNumeroContratConstruction <> 0
    then for each ttAscenseur:
        empty temp-table ttTache.
        create ttTache.
        assign
            ttTache.noita       = ttAscenseur.iNumeroTache
            ttTache.tpcon       = {&TYPECONTRAT-construction}
            ttTache.nocon       = piNumeroContratConstruction
            ttTache.tptac       = {&TYPETACHE-ascenseurs}
            ttTache.notac       = ttAscenseur.iChronoTache
            ttTache.ntges       = ttAscenseur.cCodeAscenseur
            ttTache.dtdeb       = ttAscenseur.daDateDebut
            ttTache.tpfin       = ttAscenseur.cCodeFournisseur
            ttTache.ntges       = ttAscenseur.cNumeroSerie
            ttTache.tpges       = ttAscenseur.cCodeBatiment
            ttTache.CRUD        = ttAscenseur.CRUD
            ttTache.dtTimestamp = ttAscenseur.dtTimestamp
            ttTache.rRowid      = ttAscenseur.rRowid
        .
        run setTache in vhTache(table ttTache by-reference).
        if not mError:erreur() then do:
             if ttAscenseur.CRUD = 'D' or ttAscenseur.CRUD = 'C'
             then do:
                for first imble exclusive-lock
                    where imble.noimm = ttAscenseur.iNumeroImmeuble:
                    imble.nbasc = imble.nbasc + (if ttAscenseur.CRUD = 'D' then -1 else 1).
                end.
                for first batim exclusive-lock
                    where batim.noimm = ttAscenseur.iNumeroImmeuble
                      and batim.cdbat = ttAscenseur.cCodeBatiment:
                    batim.nbasc = batim.nbasc + (if ttAscenseur.CRUD = 'D' then -1 else 1).
                end.
            end.
            for first ttTache:
                vcNumeroTacheAscenseur = string(ttTache.noita).
            end.    
            empty temp-table ttTache.
            for each ttControleTechnique
                where ttControleTechnique.iNumeroLigne = ttAscenseur.iNumeroLigne:
                create ttTache.
                assign
                    ttTache.noita = ttControleTechnique.iNumeroTache
                    ttTache.tpcon = {&TYPECONTRAT-construction}
                    ttTache.nocon = piNumeroContratConstruction
                    ttTache.tptac = {&TYPETACHE-ctlTechniqueAscenseur}
                    ttTache.notac = ttControleTechnique.iChronoTache
                    ttTache.ntges = vcNumeroTacheAscenseur
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
    end.
    run destroy in vhTache.

end procedure.

