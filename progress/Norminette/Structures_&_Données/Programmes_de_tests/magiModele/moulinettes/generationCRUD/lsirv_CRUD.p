/*------------------------------------------------------------------------
File        : lsirv_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table lsirv
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/lsirv.i}
{application/include/error.i}
define variable ghttlsirv as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdirv as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cdirv, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cdirv' then phCdirv = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudLsirv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteLsirv.
    run updateLsirv.
    run createLsirv.
end procedure.

procedure setLsirv:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttLsirv.
    ghttLsirv = phttLsirv.
    run crudLsirv.
    delete object phttLsirv.
end procedure.

procedure readLsirv:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table lsirv 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piCdirv as integer    no-undo.
    define input parameter table-handle phttLsirv.
    define variable vhttBuffer as handle no-undo.
    define buffer lsirv for lsirv.

    vhttBuffer = phttLsirv:default-buffer-handle.
    for first lsirv no-lock
        where lsirv.cdirv = piCdirv:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer lsirv:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLsirv no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getLsirv:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table lsirv 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttLsirv.
    define variable vhttBuffer as handle  no-undo.
    define buffer lsirv for lsirv.

    vhttBuffer = phttLsirv:default-buffer-handle.
    for each lsirv no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer lsirv:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLsirv no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateLsirv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdirv    as handle  no-undo.
    define buffer lsirv for lsirv.

    create query vhttquery.
    vhttBuffer = ghttLsirv:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttLsirv:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdirv).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first lsirv exclusive-lock
                where rowid(lsirv) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer lsirv:handle, 'cdirv: ', substitute('&1', vhCdirv:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer lsirv:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createLsirv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer lsirv for lsirv.

    create query vhttquery.
    vhttBuffer = ghttLsirv:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttLsirv:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create lsirv.
            if not outils:copyValidField(buffer lsirv:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteLsirv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdirv    as handle  no-undo.
    define buffer lsirv for lsirv.

    create query vhttquery.
    vhttBuffer = ghttLsirv:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttLsirv:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdirv).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first lsirv exclusive-lock
                where rowid(Lsirv) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer lsirv:handle, 'cdirv: ', substitute('&1', vhCdirv:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete lsirv no-error.
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

