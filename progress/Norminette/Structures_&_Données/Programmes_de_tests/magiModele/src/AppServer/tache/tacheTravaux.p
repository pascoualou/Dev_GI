/*-----------------------------------------------------------------------------
File        : tacheTravaux.p
Purpose     : 
Author(s)   : kantena - 2018/09/26
Notes       :
derniere revue:
-----------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/glbsepar.i}
{tache/include/tache.i}
{immeubleEtLot/include/immeubleAutre.i}

procedure setTravaux:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContratConstruction as int64 no-undo.
    define input parameter table for ttTravaux.
    define input parameter table for ttFournisseur.

    define variable vcListeFournisseur as character no-undo.
    define variable vhTache            as handle    no-undo.

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
            ttTache.tptac = {&TYPETACHE-travauxImmeubleSaisieManuelle}
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
    if can-find(first ttTache) then do:
        run crud/tache_CRUD.p persistent set vhTache.
        run getTokenInstance in vhTache(mToken:JSessionId).
        run setTache in vhTache(table ttTache by-reference).
        run destroy in vhTache.
    end.
end procedure.

