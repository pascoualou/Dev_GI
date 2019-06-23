/*------------------------------------------------------------------------
File        : batim_CRUD.p
Purpose     :
Author(s)   : kantena - 2016/08/12
Notes       :
derniere revue: 2018/09/07 - phm: KO
    traiter les todo
------------------------------------------------------------------------*/
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2adresse.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{immeubleEtLot/include/batiment.i}

{crud/include/intnt.i}
define variable ghttBatim as handle no-undo.      // le handle de la temp table à mettre à jour

procedure readbatim:
    /*------------------------------------------------------------------------------
    Purpose: recherche batiment par Numéro bâtiment ou Numéro immeuble/code bâtiment.
    Notes  : service? si pcCodeBatiment = ? recherche sur numeroBatiment, numeroImmeuble/cdbat sinon
    todo   : pas utilisé?!
    ------------------------------------------------------------------------------*/
    define input  parameter piIdentifiant  as integer   no-undo.
    define input  parameter pcCodeBatiment as character no-undo.
    define output parameter table for ttBatiment.

    define buffer batim for batim.

    if pcCodeBatiment = ?
    then find first batim no-lock
        where batim.nobat = piIdentifiant no-error.
    else find first batim no-lock
        where batim.noimm = piIdentifiant
          and batim.cdbat = pcCodeBatiment no-error.
    if not available batim
    then mError:createError({&error}, 211653, if pcCodeBatiment = ?
                                              then substitute('batim-nobat: &1', string(piIdentifiant))
                                              else substitute('batim-noimm/cdbat: &1/&2', string(piIdentifiant), pcCodeBatiment)).
    else do:
        create ttBatiment.
        assign
            ttBatiment.CRUD             = 'R'
            ttBatiment.iNumeroImmeuble  = batim.noimm
            ttBatiment.iNumeroBatiment  = batim.noBat
            ttBatiment.cCodeBatiment    = batim.cdBat
            ttBatiment.cLibelleBatiment = batim.lbBat
            ttBatiment.cTypeBien        = {&TYPEBIEN-batiment}
            ttBatiment.dtTimestamp      = datetime(batim.dtmsy, batim.hemsy)
            ttBatiment.rRowid           = rowid(batim)
        .
    end.
    error-status:error = false no-error.  // reset error-status
    return.

end procedure.

function iGetNextbatim returns integer(piNumeroBatiment as integer):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer batim for batim.

    {&_proparse_ prolint-nowarn(wholeindex)}
    if piNumeroBatiment = ? or piNumeroBatiment = 0
    then for last batim fields (batim.nobat) no-lock:
        return batim.nobat + 1.
    end.
    else return piNumeroBatiment.
    return 1.

end function.

procedure updatebatim private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttBuffer as handle  no-undo.
    define variable vhttQuery  as handle  no-undo.
    define buffer batim for batim.

    vhttBuffer = ghttBatim:default-buffer-handle.
    create query  vhttQuery.
    vhttQuery:set-buffers(vhttBuffer).
    vhttQuery:query-prepare(substitute('for each &1 where &1.CRUD="U"', vhttBuffer:name)).
    vhttQuery:query-open().

blocTransaction:
    do transaction:
blocRepeat:
        repeat:
            vhttQuery:get-next().
            if vhttQuery:query-off-end then leave blocRepeat.

            find first batim exclusive-lock where rowid(batim) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer batim:handle, 'batiment: ', string(vhttBuffer::iNumeroBatiment), vhttBuffer::dtTimestamp)
            then undo blocTransaction, leave blocTransaction.

            if not outils:copyValidField(buffer batim:handle, vhttBuffer, '', mtoken:cUser) then undo blocTransaction, leave blocTransaction.
         end.
     end.
    error-status:error = false no-error.  // reset error-status
    return.

end procedure.

procedure createbatim private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : 
    ------------------------------------------------------------------------------*/
    define variable vhProcIntnt      as handle  no-undo.
    define variable vhttBuffer       as handle  no-undo.
    define variable vhttQuery        as handle  no-undo.
    define variable viNumeroBatiment as integer no-undo.
    define buffer batim for batim.
    define buffer intnt for intnt.

    vhttBuffer = ghttBatim:default-buffer-handle.
    create query  vhttQuery.
    vhttQuery:set-buffers(vhttBuffer).
    vhttQuery:query-prepare(substitute('for each &1 where &1.CRUD="C"', vhttBuffer:name)).
    vhttQuery:query-open().

blocTransaction:
    do transaction:
        empty temp-table ttIntnt.
blocRepeat:
        repeat:
            vhttQuery:get-next().
            if vhttQuery:query-off-end then leave blocRepeat.

            viNumeroBatiment = iGetNextbatim(vhttBuffer::iNumeroBatiment).
            create batim.
            assign
                batim.NoBat                 = viNumeroBatiment
                vhttBuffer::iNumeroBatiment = viNumeroBatiment
            no-error.
            if error-status:error then do:
                mError:createError({&error},  error-status:get-message(1)).
                undo blocTransaction, leave blocTransaction.
            end.
            if not outils:copyValidField(buffer batim:handle, vhttBuffer, '', mtoken:cUser) then undo blocTransaction, leave blocTransaction.

            /*--> Creation des liens Batiment - Mandat de Gerance et Batiment - Mandat de Copro */
            for each Intnt no-lock
                where intnt.tpidt = {&TYPEBIEN-immeuble}
                  and intnt.noidt = batim.noImm
                  and (intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
                    or intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}):
                create ttIntnt.
                assign
                    ttIntnt.tpidt = {&TYPEBIEN-batiment}
                    ttIntnt.tpcon = intnt.tpcon
                    ttIntnt.nocon = intnt.nocon
                    ttIntnt.noidt = batim.NoBat
                    ttIntnt.CRUD  = 'C'
                .
            end.
        end.
        if can-find(first ttIntnt) then do:
            run crud/intnt_CRUD.p persistent set vhProcIntnt.
            run getTokenInstance in vhProcIntnt(mToken:JSessionId).
            run setIntnt in vhProcIntnt(table ttIntnt by-reference).
            run destroy in vhProcIntnt.
        end.
    end.
    error-status:error = false no-error.  // reset error-status
    return.

end procedure.

procedure deletebatim private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhProcIntnt as handle  no-undo.
    define variable vhttBuffer  as handle  no-undo.
    define variable vhttQuery   as handle  no-undo.
    define buffer batim for batim.
    define buffer tache for tache.
    define buffer intnt for intnt.

    vhttBuffer = ghttBatim:default-buffer-handle.
    create query  vhttQuery.
    vhttQuery:set-buffers(vhttBuffer).
    vhttQuery:query-prepare(substitute('for each &1 where &1.CRUD="D"', vhttBuffer:name)).
    vhttQuery:query-open().
    run crud/intnt_CRUD.p persistent set vhProcIntnt.
    run getTokenInstance in vhProcIntnt(mToken:JSessionId).

blocTransaction:
    do transaction:
blocRepeat:
        repeat:
            vhttQuery:get-next().
            if vhttQuery:query-off-end then leave blocRepeat.

            find first batim exclusive-lock where rowid(batim) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer batim:handle, 'batiment: ', string(vhttBuffer::iNumeroBatiment), vhttBuffer::dtTimestamp)
            then undo blocTransaction, leave blocTransaction.

            /*--> Suppression relation contrat - batiment */
            run deleteIntnt2Batiment in vhProcIntnt(batim.nobat).

            /* Suppression du rattachement d'une assurance immeuble au batiment */
            for each intnt no-lock
                where intnt.tpcon = {&TYPECONTRAT-assuranceGerance}
                  and intnt.tpidt = {&TYPEBIEN-immeuble}
                  and intnt.noidt = batim.noimm
              , each tache exclusive-lock
                where tache.tpcon = {&TYPECONTRAT-assuranceGerance}
                  and tache.nocon = intnt.nocon
                  and tache.tptac = {&TYPETACHE-affectationBatiment}
                  and lookup(string(batim.nobat), tache.lbdiv) > 0:
                if string(batim.nobat) = tache.lbdiv
                then tache.lbdiv = ''.
                else assign
                    tache.lbdiv = replace(tache.lbdiv, "," + string(batim.nobat), "")
                    tache.lbdiv = replace(tache.lbdiv, string(batim.nobat) + ",", "")
                .
            end.
            delete batim no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTransaction, leave blocTransaction.
            end.
        end.
    end.
    run destroy in vhProcIntnt.
    error-status:error = false no-error.  // reset error-status
    return.

end procedure.

procedure getBatim:
    /*------------------------------------------------------------------------------
    Purpose: Récupérer les informations Batiments
    Notes  : service beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroImmeuble as integer no-undo.
    define output parameter table for ttBatiment.

    define buffer batim        for batim.
    define buffer iLienAdresse for iLienAdresse.

    for each batim no-lock
       where batim.noimm = piNumeroImmeuble:
       create ttBatiment.
       assign
            ttBatiment.CRUD                   = 'R'
            ttBatiment.iNumeroImmeuble        = batim.noimm
            ttBatiment.iNumeroBatiment        = batim.NoBat
            ttBatiment.cCodeBatiment          = batim.CdBat
            ttBatiment.cLibelleAdresse        = outilFormatage:formatageAdresse({&TYPEBIEN-batiment}, batim.nobat)
            ttBatiment.cLibelleBatiment       = batim.LbBat
            ttBatiment.cCodeTypeConstruction  = batim.TpCst    /* Type de Construction         */
            ttBatiment.cCodeTypeToiture       = batim.TpTot    /* Type de Toitures             */
            ttBatiment.lVentilationMecanique  = batim.FgVen    /* Flag Ventilation Mecanique   */
            ttBatiment.cCodeTypeChauffage     = batim.TpCha    /* Type de Chauffage            */
            ttBatiment.cCodeModeChauffage     = batim.MdCha    /* Mode de Chauffage            */
            ttBatiment.cCodeModeClimatisation = batim.MdCli    /* Mode de Climatisation        */
            ttBatiment.cCodeModeEauChaude     = batim.MdChd    /* Mode Eau Chaude              */
            ttBatiment.cCodeModeEauFroide     = batim.MdFra    /* Mode Eau Froide              */
            ttBatiment.lTeleReleve            = batim.FgRel    /* Telerelevé                   */
            ttBatiment.cDebutPeriodeChauffe   = batim.dtdch    /* Debut perdiode de chauffe    */
            ttBatiment.cFinPeriodeChauffe     = batim.dtfch    /* Fin periode de chaffe        */
            ttBatiment.iNombreEscalier        = batim.nbEsc
            ttBatiment.iNombreEtage           = batim.nbEta
            ttBatiment.iNombreLoge            = batim.nbLog
            ttBatiment.iNombreSousSol         = batim.nbSss
            ttBatiment.lParkingSousSol        = batim.nbpss > 0
            ttBatiment.cTypeBien              = {&TYPEBIEN-batiment}
            ttBatiment.dtTimestamp            = datetime(batim.dtmsy, batim.hemsy)
            ttBatiment.rRowid                 = rowid(batim)
        .
        for first iLienAdresse no-lock                                                        // adresse immeuble
            where iLienAdresse.cTypeIdentifiant   = {&TYPEBIEN-batiment}
              and iLienAdresse.iNumeroIdentifiant = batim.nobat
              and iLienAdresse.cTypeAdresse       = {&TYPEADRESSE-Principale}:
            ttBatiment.iNumeroAdresse = iLienAdresse.iNumeroAdresse.         
        end. 
    end.
    error-status:error = false no-error.    // reset error-status
    return.                                 // reset return-value
end procedure.

procedure crudBatim private:
    /*------------------------------------------------------------------------------
    Purpose: Mise à jour Base de données
    Notes  : service beImmeuble.cls
    todo  une fois les procédures deletebatiment, updatebatiment, createbatiment passée en private
          retirer le paramètre temp-table.
    ------------------------------------------------------------------------------*/

    run deletebatim.
    run updatebatim.
    run createbatim.

end procedure.

procedure setBatim:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (appel depuis les differents pgms de maintenance tache)
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttBatim.
    ghttBatim = phttBatim.
    run crudBatim.
    delete object phttBatim.

end procedure.

