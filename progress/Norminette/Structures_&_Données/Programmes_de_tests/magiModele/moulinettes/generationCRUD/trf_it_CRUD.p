/*------------------------------------------------------------------------
File        : trf_it_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table trf_it
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/trf_it.i}
{application/include/error.i}
define variable ghtttrf_it as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoite as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noite, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noite' then phNoite = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTrf_it private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTrf_it.
    run updateTrf_it.
    run createTrf_it.
end procedure.

procedure setTrf_it:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTrf_it.
    ghttTrf_it = phttTrf_it.
    run crudTrf_it.
    delete object phttTrf_it.
end procedure.

procedure readTrf_it:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table trf_it 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoite as integer    no-undo.
    define input parameter table-handle phttTrf_it.
    define variable vhttBuffer as handle no-undo.
    define buffer trf_it for trf_it.

    vhttBuffer = phttTrf_it:default-buffer-handle.
    for first trf_it no-lock
        where trf_it.noite = piNoite:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trf_it:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTrf_it no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTrf_it:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table trf_it 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTrf_it.
    define variable vhttBuffer as handle  no-undo.
    define buffer trf_it for trf_it.

    vhttBuffer = phttTrf_it:default-buffer-handle.
    for each trf_it no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trf_it:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTrf_it no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTrf_it private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoite    as handle  no-undo.
    define buffer trf_it for trf_it.

    create query vhttquery.
    vhttBuffer = ghttTrf_it:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTrf_it:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoite).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first trf_it exclusive-lock
                where rowid(trf_it) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer trf_it:handle, 'noite: ', substitute('&1', vhNoite:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer trf_it:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTrf_it private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer trf_it for trf_it.

    create query vhttquery.
    vhttBuffer = ghttTrf_it:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTrf_it:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create trf_it.
            if not outils:copyValidField(buffer trf_it:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTrf_it private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoite    as handle  no-undo.
    define buffer trf_it for trf_it.

    create query vhttquery.
    vhttBuffer = ghttTrf_it:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTrf_it:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoite).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first trf_it exclusive-lock
                where rowid(Trf_it) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer trf_it:handle, 'noite: ', substitute('&1', vhNoite:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete trf_it no-error.
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

