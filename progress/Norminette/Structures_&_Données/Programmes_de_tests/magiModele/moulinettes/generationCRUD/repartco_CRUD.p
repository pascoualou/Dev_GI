/*------------------------------------------------------------------------
File        : repartco_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table repartco
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/repartco.i}
{application/include/error.i}
define variable ghttrepartco as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpmdt as handle, output phNomdt as handle, output phTptrt as handle, output phNotrt as handle, output phPhasetrt as handle, output phNomat as handle, output phTrimdges as handle, output phOrdrereg as handle, output phCodregr as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpmdt/nomdt/tptrt/notrt/Phasetrt/nomat/triMdges/ordrereg/codregr/tricle/cdcle/trirub/cdrub/cdsrub/numdepense/nolot, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpmdt' then phTpmdt = phBuffer:buffer-field(vi).
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
            when 'tptrt' then phTptrt = phBuffer:buffer-field(vi).
            when 'notrt' then phNotrt = phBuffer:buffer-field(vi).
            when 'Phasetrt' then phPhasetrt = phBuffer:buffer-field(vi).
            when 'nomat' then phNomat = phBuffer:buffer-field(vi).
            when 'triMdges' then phTrimdges = phBuffer:buffer-field(vi).
            when 'ordrereg' then phOrdrereg = phBuffer:buffer-field(vi).
            when 'codregr' then phCodregr = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudRepartco private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteRepartco.
    run updateRepartco.
    run createRepartco.
end procedure.

procedure setRepartco:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRepartco.
    ghttRepartco = phttRepartco.
    run crudRepartco.
    delete object phttRepartco.
end procedure.

procedure readRepartco:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table repartco Stockage de la répartition par matric/clé/lot des charges de copropriété (c.f. TbMatLot)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpmdt    as character  no-undo.
    define input parameter piNomdt    as integer    no-undo.
    define input parameter pcTptrt    as character  no-undo.
    define input parameter piNotrt    as integer    no-undo.
    define input parameter pcPhasetrt as character  no-undo.
    define input parameter piNomat    as integer    no-undo.
    define input parameter pcTrimdges as character  no-undo.
    define input parameter piOrdrereg as integer    no-undo.
    define input parameter pcCodregr  as character  no-undo.
    define input parameter table-handle phttRepartco.
    define variable vhttBuffer as handle no-undo.
    define buffer repartco for repartco.

    vhttBuffer = phttRepartco:default-buffer-handle.
    for first repartco no-lock
        where repartco.tpmdt = pcTpmdt
          and repartco.nomdt = piNomdt
          and repartco.tptrt = pcTptrt
          and repartco.notrt = piNotrt
          and repartco.Phasetrt = pcPhasetrt
          and repartco.nomat = piNomat
          and repartco.triMdges = pcTrimdges
          and repartco.ordrereg = piOrdrereg
          and repartco.codregr = pcCodregr:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer repartco:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRepartco no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getRepartco:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table repartco Stockage de la répartition par matric/clé/lot des charges de copropriété (c.f. TbMatLot)
    Notes  : service externe. Critère pcCodregr = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpmdt    as character  no-undo.
    define input parameter piNomdt    as integer    no-undo.
    define input parameter pcTptrt    as character  no-undo.
    define input parameter piNotrt    as integer    no-undo.
    define input parameter pcPhasetrt as character  no-undo.
    define input parameter piNomat    as integer    no-undo.
    define input parameter pcTrimdges as character  no-undo.
    define input parameter piOrdrereg as integer    no-undo.
    define input parameter pcCodregr  as character  no-undo.
    define input parameter table-handle phttRepartco.
    define variable vhttBuffer as handle  no-undo.
    define buffer repartco for repartco.

    vhttBuffer = phttRepartco:default-buffer-handle.
    if pcCodregr = ?
    then for each repartco no-lock
        where repartco.tpmdt = pcTpmdt
          and repartco.nomdt = piNomdt
          and repartco.tptrt = pcTptrt
          and repartco.notrt = piNotrt
          and repartco.Phasetrt = pcPhasetrt
          and repartco.nomat = piNomat
          and repartco.triMdges = pcTrimdges
          and repartco.ordrereg = piOrdrereg:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer repartco:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each repartco no-lock
        where repartco.tpmdt = pcTpmdt
          and repartco.nomdt = piNomdt
          and repartco.tptrt = pcTptrt
          and repartco.notrt = piNotrt
          and repartco.Phasetrt = pcPhasetrt
          and repartco.nomat = piNomat
          and repartco.triMdges = pcTrimdges
          and repartco.ordrereg = piOrdrereg
          and repartco.codregr = pcCodregr:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer repartco:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRepartco no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateRepartco private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpmdt    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhTptrt    as handle  no-undo.
    define variable vhNotrt    as handle  no-undo.
    define variable vhPhasetrt    as handle  no-undo.
    define variable vhNomat    as handle  no-undo.
    define variable vhTrimdges    as handle  no-undo.
    define variable vhOrdrereg    as handle  no-undo.
    define variable vhCodregr    as handle  no-undo.
    define buffer repartco for repartco.

    create query vhttquery.
    vhttBuffer = ghttRepartco:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttRepartco:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpmdt, output vhNomdt, output vhTptrt, output vhNotrt, output vhPhasetrt, output vhNomat, output vhTrimdges, output vhOrdrereg, output vhCodregr).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first repartco exclusive-lock
                where rowid(repartco) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer repartco:handle, 'tpmdt/nomdt/tptrt/notrt/Phasetrt/nomat/triMdges/ordrereg/codregr/tricle/cdcle/trirub/cdrub/cdsrub/numdepense/nolot: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhTpmdt:buffer-value(), vhNomdt:buffer-value(), vhTptrt:buffer-value(), vhNotrt:buffer-value(), vhPhasetrt:buffer-value(), vhNomat:buffer-value(), vhTrimdges:buffer-value(), vhOrdrereg:buffer-value(), vhCodregr:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer repartco:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createRepartco private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer repartco for repartco.

    create query vhttquery.
    vhttBuffer = ghttRepartco:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttRepartco:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create repartco.
            if not outils:copyValidField(buffer repartco:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteRepartco private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpmdt    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhTptrt    as handle  no-undo.
    define variable vhNotrt    as handle  no-undo.
    define variable vhPhasetrt    as handle  no-undo.
    define variable vhNomat    as handle  no-undo.
    define variable vhTrimdges    as handle  no-undo.
    define variable vhOrdrereg    as handle  no-undo.
    define variable vhCodregr    as handle  no-undo.
    define buffer repartco for repartco.

    create query vhttquery.
    vhttBuffer = ghttRepartco:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttRepartco:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpmdt, output vhNomdt, output vhTptrt, output vhNotrt, output vhPhasetrt, output vhNomat, output vhTrimdges, output vhOrdrereg, output vhCodregr).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first repartco exclusive-lock
                where rowid(Repartco) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer repartco:handle, 'tpmdt/nomdt/tptrt/notrt/Phasetrt/nomat/triMdges/ordrereg/codregr/tricle/cdcle/trirub/cdrub/cdsrub/numdepense/nolot: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhTpmdt:buffer-value(), vhNomdt:buffer-value(), vhTptrt:buffer-value(), vhNotrt:buffer-value(), vhPhasetrt:buffer-value(), vhNomat:buffer-value(), vhTrimdges:buffer-value(), vhOrdrereg:buffer-value(), vhCodregr:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete repartco no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

