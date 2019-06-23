/*------------------------------------------------------------------------
File        : assuranceImmeuble.p
Purpose     : gestion creation / suppression d'un contrat assurance immeuble
Author(s)   : GGA  -  2018/04/10
Notes       :
derniere revue: 2018/04/18 - phm: OK
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}

using parametre.syspg.syspg.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{mandat/include/roleMandat.i &nomtable=ttRoleContractant}
{mandat/include/roleMandat.i &nomtable=ttRoleCourtier}
{tache/include/tacheAssuranceImmeuble.i}
{application/include/error.i}
{adblib/include/ctctt.i}
{outils/include/lancementProgramme.i}    // function lancementPgm, suppressionPgmPersistent

procedure createAssurance:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContratPrincipal   as character no-undo.
    define input parameter piNumeroContratPrincipal as int64     no-undo.
    define input parameter table for ttRoleContractant.
    define input parameter table for ttObjetAssImm.
    define input parameter table for ttRoleCourtier.
    define input parameter table for ttBatimentAssImm.

    define variable vhObjetAssImm         as handle no-undo.
    define variable vhContractantContrat  as handle no-undo.
    define variable vhRoleAnnexeContrat   as handle no-undo.
    define variable vhtacheAssImmBatiment as handle no-undo.
    define variable vhCtctt               as handle no-undo.

    define buffer ctrat for ctrat.

    empty temp-table ttCtctt.
    /* on verifie si contrat principal existe */
    if not can-find(first ctrat no-lock
                    where ctrat.tpcon = pcTypeContratPrincipal
                      and ctrat.nocon = piNumeroContratPrincipal)
    then do:
        mError:createError({&error}, 100057).
        return.
    end.

    if can-find(first ttObjetAssImm     where ttObjetAssImm.iNumeroContrat <> 0)
    or can-find(first ttRoleContractant where ttRoleContractant.iNumeroContrat <> 0)
    or can-find(first ttRoleCourtier    where ttRoleCourtier.iNumeroContrat <> 0)
    or can-find(first ttBatimentAssImm  where ttBatimentAssImm.iNumeroContrat <> 0)
    then do:
        mError:createError({&error}, 1000637). //le numéro de contrat pour une création doit être 0
        return.
    end.

    find first ttObjetAssImm where ttObjetAssImm.CRUD = "C" no-error.
    if not available ttObjetAssImm
    then do:
        mError:createError({&error}, 1000638).        // enregistrement de demande de création du contrat inexistant
        return.
    end.

    /* creation contrat (maj objet) */
    run tache/assuranceImmeuble/objetAssImm.p persistent set vhObjetAssImm.
    run getTokenInstance in vhObjetAssImm(mToken:JSessionId).
    run createAssurance in vhObjetAssImm(table ttObjetAssImm by-reference).
    if mError:erreur() then return.

    /* on se repositionne sur enregistrement json objet du contrat pour recuperer le numero de contrat cree et on vient mettre ce numero sur tooutes les tables associes */
    for first ttObjetAssImm where ttObjetAssImm.CRUD = "C":
        for each ttRoleContractant:
            ttRoleContractant.iNumeroContrat = ttObjetAssImm.iNumeroContrat.
        end.
        for each ttRoleCourtier:
            ttRoleCourtier.iNumeroContrat = ttObjetAssImm.iNumeroContrat.
        end.
        for each ttBatimentAssImm:
            ttBatimentAssImm.iNumeroContrat = ttObjetAssImm.iNumeroContrat.
        end.
        /* creation lien contrat principal / contrat assurance */
        create ttCtctt.
        assign
            ttCtctt.tpct1 = pcTypeContratPrincipal
            ttCtctt.noct1 = piNumeroContratPrincipal
            ttCtctt.tpct2 = ttObjetAssImm.cTypeContrat
            ttCtctt.noct2 = ttObjetAssImm.iNumeroContrat
            ttCtctt.CRUD  = "C"
        .
        run adblib/ctctt_CRUD.p persistent set vhCtctt.
        run getTokenInstance in vhCtctt(mToken:JSessionId).
        run setCtctt in vhCtctt(table ttCtctt by-reference).
        if mError:erreur() then return.

        /* creation contractant si contractant par defaut parametre */
        run mandat/contractantContrat.p persistent set vhContractantContrat.
        run getTokenInstance in vhContractantContrat(mToken:JSessionId).
        run creationContrat in vhContractantContrat(ttObjetAssImm.cTypeContrat, ttObjetAssImm.iNumeroContrat).
        if mError:erreur() then return.

        /* maj contractant pour role principal (compagnie) */
        run mandat/contractantContrat.p persistent set vhContractantContrat.
        run getTokenInstance in vhContractantContrat(mToken:JSessionId).
        run setRoleContractant in vhContractantContrat(table ttRoleContractant by-reference).
        if mError:erreur() then return.

        /* maj courtier */
        run mandat/roleAnnexeContrat.p persistent set vhRoleAnnexeContrat.
        run getTokenInstance in vhRoleAnnexeContrat(mToken:JSessionId).
        run setRoleAnnexe in vhRoleAnnexeContrat(table ttRoleCourtier by-reference).
        if mError:erreur() then return.

        /* maj batiment */
        run tache/assuranceImmeuble/tacheAssImmBatiment.p persistent set vhtacheAssImmBatiment.
        run getTokenInstance in vhtacheAssImmBatiment(mToken:JSessionId).
        run setBatiment in vhtacheAssImmBatiment(ttObjetAssImm.iNumeroContrat, ttObjetAssImm.cTypeContrat, table ttBatimentAssImm by-reference).
        if mError:erreur() then return.

        /* controle contractant (cas ou la table ttRoleContractant est vide) */
        run controleContractant in vhContractantContrat(ttObjetAssImm.cTypeContrat, ttObjetAssImm.iNumeroContrat).
        if mError:erreur() then return.
    end.
    mError:createError({&information}, 1000660, string(ttObjetAssImm.iNumeroContrat)).            //création du contrat d'assurance &1 terminée
    for first ctrat no-lock
        where ctrat.tpcon = ttObjetAssImm.cTypeContrat
          and ctrat.nocon = ttObjetAssImm.iNumeroContrat:
        mError:createInfoRowid(rowid(ctrat)).
    end.

end procedure.

procedure delAssurance:
    /*------------------------------------------------------------------------------
    Purpose: suppression assurance, depuis adb/tier/assici00.p, bouton suppression
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table for ttObjetAssImm.
    define input parameter table for ttError.

    define variable vhProc as handle no-undo.
    define variable voCollectionHandlePgm as class collection no-undo.

    for first ttObjetAssImm where ttObjetAssImm.CRUD = "D":
        if can-find(first ctrat no-lock
                    where ctrat.tpcon = ttObjetAssImm.cTypeContrat
                      and ctrat.nocon = ttObjetAssImm.iNumeroContrat)
        then do:
            voCollectionHandlePgm = new collection().
            run mandat/suppressionContratAssurance.p persistent set vhProc.
            run getTokenInstance in vhProc(mToken:JSessionId).
            run SupAssurance in vhProc(table ttError, ttObjetAssImm.iNumeroContrat, ttObjetAssImm.cTypeContrat, "", input-output voCollectionHandlePgm).
            run destroy in vhproc.
            suppressionPgmPersistent(voCollectionHandlePgm).
            delete object voCollectionHandlePgm.
        end.
        else mError:createError({&error}, 100057).
    end.
    return.
end procedure.
