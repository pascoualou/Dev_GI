/*------------------------------------------------------------------------
File        : tappli_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table tappli
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/tappli.i}
{application/include/error.i}
define variable ghtttappli as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdapp as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cdapp, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cdapp' then phCdapp = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTappli private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTappli.
    run updateTappli.
    run createTappli.
end procedure.

procedure setTappli:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTappli.
    ghttTappli = phttTappli.
    run crudTappli.
    delete object phttTappli.
end procedure.

procedure readTappli:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table tappli 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdapp as character  no-undo.
    define input parameter table-handle phttTappli.
    define variable vhttBuffer as handle no-undo.
    define buffer tappli for tappli.

    vhttBuffer = phttTappli:default-buffer-handle.
    for first tappli no-lock
        where tappli.cdapp = pcCdapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tappli:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTappli no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTappli:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table tappli 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTappli.
    define variable vhttBuffer as handle  no-undo.
    define buffer tappli for tappli.

    vhttBuffer = phttTappli:default-buffer-handle.
    for each tappli no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tappli:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTappli no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTappli private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdapp    as handle  no-undo.
    define buffer tappli for tappli.

    create query vhttquery.
    vhttBuffer = ghttTappli:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTappli:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdapp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tappli exclusive-lock
                where rowid(tappli) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tappli:handle, 'cdapp: ', substitute('&1', vhCdapp:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer tappli:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTappli private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer tappli for tappli.

    create query vhttquery.
    vhttBuffer = ghttTappli:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTappli:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create tappli.
            if not outils:copyValidField(buffer tappli:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTappli private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdapp    as handle  no-undo.
    define buffer tappli for tappli.

    create query vhttquery.
    vhttBuffer = ghttTappli:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTappli:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdapp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tappli exclusive-lock
                where rowid(Tappli) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tappli:handle, 'cdapp: ', substitute('&1', vhCdapp:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete tappli no-error.
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

