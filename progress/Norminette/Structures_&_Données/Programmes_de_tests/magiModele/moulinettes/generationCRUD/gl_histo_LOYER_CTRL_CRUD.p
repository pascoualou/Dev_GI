/*------------------------------------------------------------------------
File        : gl_histo_LOYER_CTRL_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table gl_histo_LOYER_CTRL
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/gl_histo_LOYER_CTRL.i}
{application/include/error.i}
define variable ghttgl_histo_LOYER_CTRL as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNohisto_loyer_ctrl as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nohisto_loyer_ctrl, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nohisto_loyer_ctrl' then phNohisto_loyer_ctrl = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudGl_histo_loyer_ctrl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteGl_histo_loyer_ctrl.
    run updateGl_histo_loyer_ctrl.
    run createGl_histo_loyer_ctrl.
end procedure.

procedure setGl_histo_loyer_ctrl:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_histo_loyer_ctrl.
    ghttGl_histo_loyer_ctrl = phttGl_histo_loyer_ctrl.
    run crudGl_histo_loyer_ctrl.
    delete object phttGl_histo_loyer_ctrl.
end procedure.

procedure readGl_histo_loyer_ctrl:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table gl_histo_LOYER_CTRL Historique appel webservice "contrôle du loyer" (actuellement "Yanport").
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNohisto_loyer_ctrl as integer    no-undo.
    define input parameter table-handle phttGl_histo_loyer_ctrl.
    define variable vhttBuffer as handle no-undo.
    define buffer gl_histo_LOYER_CTRL for gl_histo_LOYER_CTRL.

    vhttBuffer = phttGl_histo_loyer_ctrl:default-buffer-handle.
    for first gl_histo_LOYER_CTRL no-lock
        where gl_histo_LOYER_CTRL.nohisto_loyer_ctrl = piNohisto_loyer_ctrl:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer gl_histo_LOYER_CTRL:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_histo_loyer_ctrl no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getGl_histo_loyer_ctrl:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table gl_histo_LOYER_CTRL Historique appel webservice "contrôle du loyer" (actuellement "Yanport").
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_histo_loyer_ctrl.
    define variable vhttBuffer as handle  no-undo.
    define buffer gl_histo_LOYER_CTRL for gl_histo_LOYER_CTRL.

    vhttBuffer = phttGl_histo_loyer_ctrl:default-buffer-handle.
    for each gl_histo_LOYER_CTRL no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer gl_histo_LOYER_CTRL:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_histo_loyer_ctrl no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateGl_histo_loyer_ctrl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNohisto_loyer_ctrl    as handle  no-undo.
    define buffer gl_histo_LOYER_CTRL for gl_histo_LOYER_CTRL.

    create query vhttquery.
    vhttBuffer = ghttGl_histo_loyer_ctrl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttGl_histo_loyer_ctrl:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNohisto_loyer_ctrl).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first gl_histo_LOYER_CTRL exclusive-lock
                where rowid(gl_histo_LOYER_CTRL) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer gl_histo_LOYER_CTRL:handle, 'nohisto_loyer_ctrl: ', substitute('&1', vhNohisto_loyer_ctrl:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer gl_histo_LOYER_CTRL:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createGl_histo_loyer_ctrl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer gl_histo_LOYER_CTRL for gl_histo_LOYER_CTRL.

    create query vhttquery.
    vhttBuffer = ghttGl_histo_loyer_ctrl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttGl_histo_loyer_ctrl:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create gl_histo_LOYER_CTRL.
            if not outils:copyValidField(buffer gl_histo_LOYER_CTRL:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteGl_histo_loyer_ctrl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNohisto_loyer_ctrl    as handle  no-undo.
    define buffer gl_histo_LOYER_CTRL for gl_histo_LOYER_CTRL.

    create query vhttquery.
    vhttBuffer = ghttGl_histo_loyer_ctrl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttGl_histo_loyer_ctrl:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNohisto_loyer_ctrl).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first gl_histo_LOYER_CTRL exclusive-lock
                where rowid(Gl_histo_loyer_ctrl) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer gl_histo_LOYER_CTRL:handle, 'nohisto_loyer_ctrl: ', substitute('&1', vhNohisto_loyer_ctrl:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete gl_histo_LOYER_CTRL no-error.
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

