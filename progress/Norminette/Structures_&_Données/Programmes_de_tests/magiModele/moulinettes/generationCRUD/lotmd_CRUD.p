/*------------------------------------------------------------------------
File        : lotmd_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table lotmd
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/lotmd.i}
{application/include/error.i}
define variable ghttlotmd as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phCdcle as handle, output phNorep as handle, output phNoimm as handle, output phNolot as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcon/nocon/cdcle/norep/noimm/nolot, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'cdcle' then phCdcle = phBuffer:buffer-field(vi).
            when 'norep' then phNorep = phBuffer:buffer-field(vi).
            when 'noimm' then phNoimm = phBuffer:buffer-field(vi).
            when 'nolot' then phNolot = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudLotmd private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteLotmd.
    run updateLotmd.
    run createLotmd.
end procedure.

procedure setLotmd:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttLotmd.
    ghttLotmd = phttLotmd.
    run crudLotmd.
    delete object phttLotmd.
end procedure.

procedure readLotmd:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table lotmd Archivage/Historique des cles des lots des mandats
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as integer    no-undo.
    define input parameter pcCdcle as character  no-undo.
    define input parameter piNorep as integer    no-undo.
    define input parameter piNoimm as integer    no-undo.
    define input parameter piNolot as integer    no-undo.
    define input parameter table-handle phttLotmd.
    define variable vhttBuffer as handle no-undo.
    define buffer lotmd for lotmd.

    vhttBuffer = phttLotmd:default-buffer-handle.
    for first lotmd no-lock
        where lotmd.tpcon = pcTpcon
          and lotmd.nocon = piNocon
          and lotmd.cdcle = pcCdcle
          and lotmd.norep = piNorep
          and lotmd.noimm = piNoimm
          and lotmd.nolot = piNolot:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer lotmd:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLotmd no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getLotmd:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table lotmd Archivage/Historique des cles des lots des mandats
    Notes  : service externe. Critère piNoimm = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as integer    no-undo.
    define input parameter pcCdcle as character  no-undo.
    define input parameter piNorep as integer    no-undo.
    define input parameter piNoimm as integer    no-undo.
    define input parameter table-handle phttLotmd.
    define variable vhttBuffer as handle  no-undo.
    define buffer lotmd for lotmd.

    vhttBuffer = phttLotmd:default-buffer-handle.
    if piNoimm = ?
    then for each lotmd no-lock
        where lotmd.tpcon = pcTpcon
          and lotmd.nocon = piNocon
          and lotmd.cdcle = pcCdcle
          and lotmd.norep = piNorep:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer lotmd:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each lotmd no-lock
        where lotmd.tpcon = pcTpcon
          and lotmd.nocon = piNocon
          and lotmd.cdcle = pcCdcle
          and lotmd.norep = piNorep
          and lotmd.noimm = piNoimm:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer lotmd:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLotmd no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateLotmd private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhCdcle    as handle  no-undo.
    define variable vhNorep    as handle  no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define buffer lotmd for lotmd.

    create query vhttquery.
    vhttBuffer = ghttLotmd:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttLotmd:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhCdcle, output vhNorep, output vhNoimm, output vhNolot).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first lotmd exclusive-lock
                where rowid(lotmd) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer lotmd:handle, 'tpcon/nocon/cdcle/norep/noimm/nolot: ', substitute('&1/&2/&3/&4/&5/&6', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhCdcle:buffer-value(), vhNorep:buffer-value(), vhNoimm:buffer-value(), vhNolot:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer lotmd:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createLotmd private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer lotmd for lotmd.

    create query vhttquery.
    vhttBuffer = ghttLotmd:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttLotmd:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create lotmd.
            if not outils:copyValidField(buffer lotmd:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteLotmd private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhCdcle    as handle  no-undo.
    define variable vhNorep    as handle  no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define buffer lotmd for lotmd.

    create query vhttquery.
    vhttBuffer = ghttLotmd:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttLotmd:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhCdcle, output vhNorep, output vhNoimm, output vhNolot).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first lotmd exclusive-lock
                where rowid(Lotmd) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer lotmd:handle, 'tpcon/nocon/cdcle/norep/noimm/nolot: ', substitute('&1/&2/&3/&4/&5/&6', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhCdcle:buffer-value(), vhNorep:buffer-value(), vhNoimm:buffer-value(), vhNolot:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete lotmd no-error.
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

