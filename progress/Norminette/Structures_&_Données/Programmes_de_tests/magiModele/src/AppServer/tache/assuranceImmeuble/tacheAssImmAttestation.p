/*------------------------------------------------------------------------
File        : tacheAssImmAttestation.p
Purpose     : tache assurance immeuble attestations
Author(s)   : GGA  -  2017/11/27
Notes       : a partir de adb/tach/prmasatt.p adb/tach/zomasatt.p
------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}

using parametre.pclie.parametrageDefautMandat.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{tache/include/tacheAssuranceImmeuble.i}
{adblib/include/cttac.i}

procedure getAttestation:
    /*------------------------------------------------------------------------------
    Purpose: lecture attestation assurance 
    Notes  : service externe
    @param piNumeroContrat     : numero d'assurance
    @param pcTypeContrat       : type de contrat d'assurance pour le moment developpé pour TYPECONTRAT-assuranceGerance (01039) 
    @param ttAttestationAssImm : infos attestation   
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define output parameter table for ttAttestationAssImm.

    define buffer assat for assat.

    empty temp-table ttAttestationAssImm.
    if can-find(first ctrat no-lock
                where ctrat.tpcon = pcTypeContrat
                  and ctrat.nocon = piNumeroContrat)
    then for each assat no-lock
        where assat.tpcon = pcTypeContrat
          and assat.nocon = piNumeroContrat
          and assat.tptac = {&TYPETACHE-AttestationAssurance}:
        create ttAttestationAssImm.
        outils:copyValidField(buffer assat:handle, buffer ttAttestationAssImm:handle).
    end.
    else mError:createError({&error}, 100057).
end procedure.

procedure setAttestation:
    /*------------------------------------------------------------------------------
    Purpose: maj attestation assurance 
    Notes  : service externe
    @param ttAttestationAssImm : infos attestation   
    ------------------------------------------------------------------------------*/
    define input parameter table for ttAttestationAssImm.

    define buffer vbttAttestationAssImm for ttAttestationAssImm.

    for first ttAttestationAssImm
        where lookup(ttAttestationAssImm.CRUD, "C,U,D") > 0:
        if can-find(first vbttAttestationAssImm
                    where lookup(vbttAttestationAssImm.CRUD, "C,U,D") > 0
                      and vbttAttestationAssImm.iNumeroAttestation <> ttAttestationAssImm.iNumeroAttestation)   
        then mError:createError({&error}, 1000589). //Vous ne pouvez traiter en maj qu'un enregistrement à la fois
        else run verZonSai(buffer ttAttestationAssImm).
        if not mError:erreur() then run majtbltch(ttAttestationAssImm.cTypeContrat, ttAttestationAssImm.iNumeroContrat).
    end.
end procedure.

procedure verZonSai private:
    /*------------------------------------------------------------------------------
    Purpose: Controle des données saisies
    Notes  : 
    ------------------------------------------------------------------------------*/
    define parameter buffer ttAttestationAssImm for ttAttestationAssImm. 

    define buffer assat for assat.

    if not can-find(first ctrat no-lock                                             
                    where ctrat.tpcon = ttAttestationAssImm.cTypeContrat
                      and ctrat.nocon = ttAttestationAssImm.iNumeroContrat)
    then mError:createError({&error}, 100057).
    else if ttAttestationAssImm.daReception = ?
    then mError:createError({&error}, 100849).
    else if ttAttestationAssImm.daDebut = ?
    then mError:createError({&error}, 100853).
    else if ttAttestationAssImm.daFin = ?
    then mError:createError({&error}, 108115).
    else if ttAttestationAssImm.daFin < ttAttestationAssImm.daDeb
    then mError:createErrorGestion({&error}, 100850, "").
    else if lookup(ttAttestationAssImm.CRUD, "U,D") > 0
    and not can-find (first assat no-lock
                      where assat.tpcon = ttAttestationAssImm.cTypeContrat 
                        and assat.nocon = ttAttestationAssImm.iNumeroContrat
                        and assat.tptac = {&TYPETACHE-AttestationAssurance}
                        and assat.noatt = ttAttestationAssImm.iNumeroAttestation)
    then mError:createError({&error}, 1000579). // 1000579 "modification d'une attestation inexistante"
    else do:
        {&_proparse_ prolint-nowarn(use-index)}
        find last assat no-lock
            where assat.tpcon = ttAttestationAssImm.cTypeContrat
              and assat.nocon = ttAttestationAssImm.iNumeroContrat
              and assat.tptac = {&TYPETACHE-AttestationAssurance}
            use-index ix_assat01 no-error.
        if available assat
        then do: 
            {&_proparse_ prolint-nowarn(use-index)}
            if lookup(ttAttestationAssImm.CRUD, "U,D") > 0
            and assat.noatt <> ttAttestationAssImm.iNumeroAttestation
            then mError:createError({&error}, 1000580). // 1000580 "vous ne pouvez modifier ou supprimer que la derniere attestation"
            else if ttAttestationAssImm.CRUD = "U"
            then find prev assat no-lock
                     where assat.tpcon = ttAttestationAssImm.cTypeContrat
                       and assat.nocon = ttAttestationAssImm.iNumeroContrat
                       and assat.tptac = {&TYPETACHE-AttestationAssurance}
                 use-index ix_assat01 no-error.
        end.
        // en creation, test par rapport au dernier assat et en modification test par rapport au précédent (le dernier etant celui qui va etre modifie)    
        if lookup(ttAttestationAssImm.CRUD, "C,U") > 0 and available assat
        then if ttAttestationAssImm.daReception < assat.dtrcp
             then mError:createErrorGestion({&error}, 101952, string(assat.dtrcp)).
             else if ttAttestationAssImm.daDebut < assat.dtfin
             then mError:createErrorGestion({&error}, 100852, "").
    end.
end procedure.
 
procedure majtbltch private:
    /*------------------------------------------------------------------------------
    Purpose: maj infos attestation assurance 
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.
    
    define variable vhAssat as handle no-undo.
    define variable vhCttac as handle no-undo.

    define buffer cttac for cttac.

    run adblib/assat_CRUD.p persistent set vhAssat.
    run getTokenInstance in vhAssat(mToken:JSessionId).
    run setAssat in vhAssat(table ttAttestationAssImm by-reference).
    run destroy in vhAssat.
    if mError:erreur() then return.

    empty temp-table ttCttac.
    if can-find(first assat no-lock
                where assat.tpcon = pcTypeContrat
                  and assat.nocon = piNumeroContrat)
    then do:
        if not can-find(first cttac no-lock
                        where cttac.tpcon = pcTypeContrat
                          and cttac.nocon = piNumeroContrat
                          and cttac.tptac = {&TYPETACHE-AttestationAssurance})
        then do:
            create ttCttac.
            assign
                ttCttac.tpcon = pcTypeContrat
                ttCttac.nocon = piNumeroContrat
                ttCttac.tptac = {&TYPETACHE-AttestationAssurance}
                ttCttac.CRUD  = "C"
            .
        end. 
    end.
    else for first cttac no-lock
             where cttac.tpcon = pcTypeContrat
               and cttac.nocon = piNumeroContrat
               and cttac.tptac = {&TYPETACHE-AttestationAssurance}:
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
    run adblib/cttac_CRUD.p persistent set vhCttac.
    run getTokenInstance in vhCttac(mToken:JSessionId).        
    run setCttac in vhCttac(table ttCttac by-reference).
    run destroy in vhCttac.
    if mError:erreur() then return.

end procedure.
