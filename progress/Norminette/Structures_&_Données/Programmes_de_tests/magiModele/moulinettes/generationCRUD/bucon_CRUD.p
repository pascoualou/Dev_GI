/*------------------------------------------------------------------------
File        : bucon_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table bucon
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/bucon.i}
{application/include/error.i}
define variable ghttbucon as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNobud as handle, output phCdcle as handle, output phCdrub as handle, output phCdsrb as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nobud/cdcle/cdrub/cdsrb, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nobud' then phNobud = phBuffer:buffer-field(vi).
            when 'cdcle' then phCdcle = phBuffer:buffer-field(vi).
            when 'cdrub' then phCdrub = phBuffer:buffer-field(vi).
            when 'cdsrb' then phCdsrb = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudBucon private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteBucon.
    run updateBucon.
    run createBucon.
end procedure.

procedure setBucon:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttBucon.
    ghttBucon = phttBucon.
    run crudBucon.
    delete object phttBucon.
end procedure.

procedure readBucon:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table bucon 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNobud as int64      no-undo.
    define input parameter pcCdcle as character  no-undo.
    define input parameter piCdrub as integer    no-undo.
    define input parameter piCdsrb as integer    no-undo.
    define input parameter table-handle phttBucon.
    define variable vhttBuffer as handle no-undo.
    define buffer bucon for bucon.

    vhttBuffer = phttBucon:default-buffer-handle.
    for first bucon no-lock
        where bucon.nobud = piNobud
          and bucon.cdcle = pcCdcle
          and bucon.cdrub = piCdrub
          and bucon.cdsrb = piCdsrb:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer bucon:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttBucon no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getBucon:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table bucon 
    Notes  : service externe. Critère piCdrub = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNobud as int64      no-undo.
    define input parameter pcCdcle as character  no-undo.
    define input parameter piCdrub as integer    no-undo.
    define input parameter table-handle phttBucon.
    define variable vhttBuffer as handle  no-undo.
    define buffer bucon for bucon.

    vhttBuffer = phttBucon:default-buffer-handle.
    if piCdrub = ?
    then for each bucon no-lock
        where bucon.nobud = piNobud
          and bucon.cdcle = pcCdcle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer bucon:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each bucon no-lock
        where bucon.nobud = piNobud
          and bucon.cdcle = pcCdcle
          and bucon.cdrub = piCdrub:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer bucon:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttBucon no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateBucon private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNobud    as handle  no-undo.
    define variable vhCdcle    as handle  no-undo.
    define variable vhCdrub    as handle  no-undo.
    define variable vhCdsrb    as handle  no-undo.
    define buffer bucon for bucon.

    create query vhttquery.
    vhttBuffer = ghttBucon:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttBucon:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNobud, output vhCdcle, output vhCdrub, output vhCdsrb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first bucon exclusive-lock
                where rowid(bucon) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer bucon:handle, 'nobud/cdcle/cdrub/cdsrb: ', substitute('&1/&2/&3/&4', vhNobud:buffer-value(), vhCdcle:buffer-value(), vhCdrub:buffer-value(), vhCdsrb:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer bucon:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createBucon private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer bucon for bucon.

    create query vhttquery.
    vhttBuffer = ghttBucon:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttBucon:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create bucon.
            if not outils:copyValidField(buffer bucon:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteBucon private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNobud    as handle  no-undo.
    define variable vhCdcle    as handle  no-undo.
    define variable vhCdrub    as handle  no-undo.
    define variable vhCdsrb    as handle  no-undo.
    define buffer bucon for bucon.

    create query vhttquery.
    vhttBuffer = ghttBucon:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttBucon:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNobud, output vhCdcle, output vhCdrub, output vhCdsrb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first bucon exclusive-lock
                where rowid(Bucon) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer bucon:handle, 'nobud/cdcle/cdrub/cdsrb: ', substitute('&1/&2/&3/&4', vhNobud:buffer-value(), vhCdcle:buffer-value(), vhCdrub:buffer-value(), vhCdsrb:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete bucon no-error.
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

