/*------------------------------------------------------------------------
File        : batiment.p
Purpose     :
Author(s)   : kantena - 2016/08/12
Notes       :
Tables      : BASE sadb : intnt tache imbl
------------------------------------------------------------------------*/
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2adresse.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{immeubleEtLot/include/batiment.i}
{immeubleEtLot/include/equipementBien.i}
{adresse/include/ladrs.i}
{adblib/include/intnt.i}

procedure readbatiment:
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
    if not available Batim
    then mError:createError({&error}, 211653, if pcCodeBatiment = ?
                                              then substitute('batim-nobat: &1', string(piIdentifiant))
                                              else substitute('batim-noimm/cdbat: &1/&2', string(piIdentifiant), pcCodeBatiment)).
    else do:
        create ttBatiment.
        assign
            ttBatiment.CRUD             = 'R'
            ttBatiment.iNumeroImmeuble  = batim.noimm
            ttBatiment.iNumeroBatiment  = batim.NoBat
            ttBatiment.cCodeBatiment    = batim.CdBat
            ttBatiment.cLibelleBatiment = batim.LbBat
            ttBatiment.cTypeBien        = {&TYPEBIEN-batiment}
            ttBatiment.dtTimestamp      = datetime(batim.dtmsy, batim.hemsy)
            ttBatiment.rRowid           = rowid(batim)
        .
    end.
    error-status:error = false no-error.  // reset error-status
    return.

end procedure.

function iGetNextbatiment returns integer(piNumeroBatiment as integer):
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

procedure updatebatiment:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par batiment.p
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttBatiment.

    define variable vhttBuffer as handle  no-undo.
    define variable vhttQuery  as handle  no-undo.
    define buffer batim for batim.

    vhttBuffer = phttBatiment:default-buffer-handle.
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

            find first batim exclusive-lock where rowid(batim) = phttBatiment::rRowid no-wait no-error.
            if outils:isUpdated(buffer batim:handle, 'batiment: ', string(phttBatiment::iNumeroBatiment), phttBatiment::dtTimestamp)
            then undo blocTransaction, leave blocTransaction.

            if not outils:copyValidLabeledField(buffer batim:handle, vhttBuffer, 'U', mtoken:cUser) then undo blocTransaction, leave blocTransaction.
         end.
     end.
    error-status:error = false no-error.  // reset error-status
    return.

end procedure.

procedure createbatiment:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par batiment.p
    ------------------------------------------------------------------------------*/
    define input-output parameter table-handle phttBatiment.

    define variable vhProcIntnt      as handle  no-undo.
    define variable vhttBuffer       as handle  no-undo.
    define variable vhttQuery        as handle  no-undo.
    define variable viNumeroBatiment as integer no-undo.
    define buffer batim for batim.
    define buffer intnt for intnt.

    vhttBuffer = phttBatiment:default-buffer-handle.
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

            viNumeroBatiment = iGetNextbatiment(vhttBuffer::iNumeroBatiment).
            create batim.
            assign
                batim.NoBat                 = viNumeroBatiment
                vhttBuffer::iNumeroBatiment = viNumeroBatiment
            no-error.
            if error-status:error
            then do:
                mError:createError({&error},  error-status:get-message(1)).
                undo blocTransaction, leave blocTransaction.
            end.
            if not outils:copyValidLabeledField(buffer batim:handle, vhttBuffer, 'C', mtoken:cUser) then undo blocTransaction, leave blocTransaction.

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
            run adblib/intnt_CRUD.p persistent set vhProcIntnt.
            run getTokenInstance in vhProcIntnt(mToken:JSessionId).
            run setIntnt in vhProcIntnt(table ttIntnt by-reference).
            run destroy in vhProcIntnt.
        end.
    end.
    error-status:error = false no-error.  // reset error-status
    return.

end procedure.

procedure deletebatiment:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par batiment.p
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttBatiment.

    define variable vhProcIntnt as handle  no-undo.
    define variable vhttBuffer  as handle  no-undo.
    define variable vhttQuery   as handle  no-undo.
    define buffer batim for batim.
    define buffer tache for tache.
    define buffer intnt for intnt.

    vhttBuffer = phttBatiment:default-buffer-handle.
    create query  vhttQuery.
    vhttQuery:set-buffers(vhttBuffer).
    vhttQuery:query-prepare(substitute('for each &1 where &1.CRUD="D"', vhttBuffer:name)).
    vhttQuery:query-open().
    run adblib/intnt_CRUD.p persistent set vhProcIntnt.
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

procedure getBatiment:
    /*------------------------------------------------------------------------------
    Purpose: Récupérer les informations Batiments
    Notes  : service beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroImmeuble as integer no-undo.
    define output parameter table for ttBatiment.

    define variable vlExisteLien as logical  no-undo.
    define buffer batim   for batim.
    define buffer vbLadrs for ladrs.
    define buffer ladrs   for ladrs.

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
        /*--> Rechercher l'adresse de l'immeuble correspondant au batiment */
        for first ladrs no-lock
            where ladrs.tpidt = {&TYPEBIEN-batiment}
              and ladrs.noidt = batim.nobat
          , each vbLadrs no-lock
            where vbLadrs.tpidt = {&TYPEBIEN-immeuble}
              and vbLadrs.noidt = piNumeroImmeuble:
            buffer-compare vbLadrs
                     using vbLadrs.tpfrt vbLadrs.novoi vbLadrs.cdadr vbLadrs.noadr
                        to ladrs
            save result in vlExisteLien.
            if vlExisteLien then ttBatiment.iNumeroLien = vbLadrs.NoLie.
        end.
    end.
    error-status:error = false no-error.    // reset error-status
    return.                                 // reset return-value
end procedure.

procedure getEquipementBatiment:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroImmeuble as integer no-undo.
    define output parameter table for ttEquipementBien.
    define output parameter table for ttFichierJointEquipement.

    define variable vhproc as handle no-undo.
    define buffer batim for batim.

    empty temp-table ttEquipementBien.
    empty temp-table ttFichierJointEquipement.
    run ImmeubleEtLot/equipementBien.p persistent set vhproc.
    run getTokenInstance in vhproc(mToken:JSessionId).
    /* Ajout des équipements des batiments de l'immeuble */
    for each batim no-lock
        where batim.noimm = piNumeroImmeuble:
        run getEquipementBien in vhproc(batim.noBat, {&TYPEBIEN-batiment}, output table ttEquipementBien by-reference, output table ttFichierJointEquipement by-reference).
    end.
    run destroy in vhproc.
    error-status:error = false no-error.    // reset error-status
    return.                                 // reset return-value
end procedure.

procedure setBatiment:
    /*------------------------------------------------------------------------------
    Purpose: Mise à jour Base de données
    Notes  : service beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input-output parameter table for ttBatiment.

    run deletebatiment (table ttBatiment by-reference).
    run updatebatiment (table ttBatiment by-reference).
    run createbatiment (input-output table ttBatiment by-reference).

end procedure.

procedure setAdresseBatiment:
    /*------------------------------------------------------------------------------
    Purpose: Création et mise à jour du lien adresse - batiment
    Notes  : service appelé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input parameter table for ttBatiment.

    define variable vhProcLadrs as handle  no-undo.
    define variable vlCompare   as logical no-undo.
    define buffer ladrs   for ladrs.
    define buffer vbLadrs for ladrs.

    run adresse/ladrs_CRUD.p persistent set vhProcLadrs.
    run getTokenInstance in vhProcLadrs(mToken:JSessionId).

    /* Modification des adresses batiments */
    for each ttBatiment
        where ttBatiment.CRUD = "C" or ttBatiment.CRUD = "U"
      , first vbLadrs no-lock
        where vbLadrs.nolie = ttBatiment.iNumeroLien:
        find first ladrs no-lock
            where ladrs.tpidt = {&TYPEBIEN-batiment}
              and ladrs.noidt = ttBatiment.iNumeroBatiment no-error.
        if not available ladrs
        then do:
            create ttladrs.
            assign
                ttladrs.noidt = ttBatiment.iNumeroBatiment
                ttladrs.tpidt = {&TYPEBIEN-batiment}
                ttladrs.tpadr = {&TYPEADRESSE-Principale}
                ttladrs.tpfrt = vbLadrs.tpfrt
                ttladrs.novoi = vbLadrs.novoi
                ttladrs.cdadr = vbLadrs.cdadr
                ttladrs.noadr = vbLadrs.noadr
                ttladrs.cdte1 = "00000"
                ttladrs.cdte2 = "00000"
                ttladrs.cdte3 = "00000"
                ttladrs.CRUD  = "C"
            .
        end.
        else do:
            buffer-compare vbLadrs
                     using vbLadrs.tpfrt vbLadrs.novoi vbLadrs.cdadr vbLadrs.noadr
                        to ladrs
            save result in vlCompare.
            if not vlCompare
            then do:
                create ttladrs.
                assign
                    ttladrs.nolie = ladrs.nolie
                    ttladrs.tpidt = {&TYPEBIEN-batiment}
                    ttladrs.tpadr = {&TYPEADRESSE-Principale}
                    ttladrs.noidt = ttBatiment.iNumeroBatiment
                    ttladrs.tpfrt = vbLadrs.tpfrt
                    ttladrs.novoi = vbLadrs.novoi
                    ttladrs.cdadr = vbLadrs.cdadr
                    ttladrs.noadr = vbLadrs.noadr
                    ttladrs.CRUD  = "U"
                .
            end.
        end.
    end.
    run setLadrs in vhProcLadrs(table ttLadrs by-reference).
    run destroy in vhProcLadrs.
    error-status:error = false no-error.    // reset error-status
    return.                                 // reset return-value
end procedure.

procedure setEquipementBatiments:
    /*------------------------------------------------------------------------------
    Purpose: Enregistrement des equipements des batiments
    Notes  : Service a développer?
    TODO   : pas utilisé !?
    ------------------------------------------------------------------------------*/
    error-status:error = false no-error.    // reset error-status
    return.                                 // reset return-value
end procedure.
