/*------------------------------------------------------------------------
File        : equit_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table equit
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/equit.i}
{application/include/error.i}
define variable ghttequit as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoint as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noint, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noint' then phNoint = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudEquit private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteEquit.
    run updateEquit.
    run createEquit.
end procedure.

procedure setEquit:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEquit.
    ghttEquit = phttEquit.
    run crudEquit.
    delete object phttEquit.
end procedure.

procedure readEquit:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table equit 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoint as int64      no-undo.
    define input parameter table-handle phttEquit.
    define variable vhttBuffer as handle no-undo.
    define buffer equit for equit.

    vhttBuffer = phttEquit:default-buffer-handle.
    for first equit no-lock
        where equit.noint = piNoint:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer equit:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEquit no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getEquit:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table equit 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEquit.
    define variable vhttBuffer as handle  no-undo.
    define buffer equit for equit.

    vhttBuffer = phttEquit:default-buffer-handle.
    for each equit no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer equit:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEquit no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateEquit private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoint    as handle  no-undo.
    define buffer equit for equit.

    create query vhttquery.
    vhttBuffer = ghttEquit:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttEquit:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoint).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first equit exclusive-lock
                where rowid(equit) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer equit:handle, 'noint: ', substitute('&1', vhNoint:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer equit:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createEquit private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer equit for equit.

    create query vhttquery.
    vhttBuffer = ghttEquit:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttEquit:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create equit.
            if not outils:copyValidField(buffer equit:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteEquit private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoint    as handle  no-undo.
    define buffer equit for equit.

    create query vhttquery.
    vhttBuffer = ghttEquit:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttEquit:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoint).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first equit exclusive-lock
                where rowid(Equit) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer equit:handle, 'noint: ', substitute('&1', vhNoint:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete equit no-error.
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

