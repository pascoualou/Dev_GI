/*------------------------------------------------------------------------
File        : trp_mn_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table trp_mn
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/trp_mn.i}
{application/include/error.i}
define variable ghtttrp_mn as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNomen as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nomen, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nomen' then phNomen = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTrp_mn private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTrp_mn.
    run updateTrp_mn.
    run createTrp_mn.
end procedure.

procedure setTrp_mn:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTrp_mn.
    ghttTrp_mn = phttTrp_mn.
    run crudTrp_mn.
    delete object phttTrp_mn.
end procedure.

procedure readTrp_mn:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table trp_mn 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNomen as integer    no-undo.
    define input parameter table-handle phttTrp_mn.
    define variable vhttBuffer as handle no-undo.
    define buffer trp_mn for trp_mn.

    vhttBuffer = phttTrp_mn:default-buffer-handle.
    for first trp_mn no-lock
        where trp_mn.nomen = piNomen:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trp_mn:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTrp_mn no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTrp_mn:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table trp_mn 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTrp_mn.
    define variable vhttBuffer as handle  no-undo.
    define buffer trp_mn for trp_mn.

    vhttBuffer = phttTrp_mn:default-buffer-handle.
    for each trp_mn no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trp_mn:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTrp_mn no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTrp_mn private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomen    as handle  no-undo.
    define buffer trp_mn for trp_mn.

    create query vhttquery.
    vhttBuffer = ghttTrp_mn:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTrp_mn:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomen).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first trp_mn exclusive-lock
                where rowid(trp_mn) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer trp_mn:handle, 'nomen: ', substitute('&1', vhNomen:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer trp_mn:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTrp_mn private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer trp_mn for trp_mn.

    create query vhttquery.
    vhttBuffer = ghttTrp_mn:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTrp_mn:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create trp_mn.
            if not outils:copyValidField(buffer trp_mn:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTrp_mn private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomen    as handle  no-undo.
    define buffer trp_mn for trp_mn.

    create query vhttquery.
    vhttBuffer = ghttTrp_mn:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTrp_mn:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomen).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first trp_mn exclusive-lock
                where rowid(Trp_mn) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer trp_mn:handle, 'nomen: ', substitute('&1', vhNomen:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete trp_mn no-error.
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

