/*------------------------------------------------------------------------
File        : GL_CHP_USER_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table GL_CHP_USER
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/GL_CHP_USER.i}
{application/include/error.i}
define variable ghttGL_CHP_USER as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNochp as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nochp, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nochp' then phNochp = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudGl_chp_user private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteGl_chp_user.
    run updateGl_chp_user.
    run createGl_chp_user.
end procedure.

procedure setGl_chp_user:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_chp_user.
    ghttGl_chp_user = phttGl_chp_user.
    run crudGl_chp_user.
    delete object phttGl_chp_user.
end procedure.

procedure readGl_chp_user:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table GL_CHP_USER Liaison entre le champ et l'utilisateur (=> droits)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNochp as integer    no-undo.
    define input parameter table-handle phttGl_chp_user.
    define variable vhttBuffer as handle no-undo.
    define buffer GL_CHP_USER for GL_CHP_USER.

    vhttBuffer = phttGl_chp_user:default-buffer-handle.
    for first GL_CHP_USER no-lock
        where GL_CHP_USER.nochp = piNochp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_CHP_USER:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_chp_user no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getGl_chp_user:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table GL_CHP_USER Liaison entre le champ et l'utilisateur (=> droits)
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_chp_user.
    define variable vhttBuffer as handle  no-undo.
    define buffer GL_CHP_USER for GL_CHP_USER.

    vhttBuffer = phttGl_chp_user:default-buffer-handle.
    for each GL_CHP_USER no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_CHP_USER:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_chp_user no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateGl_chp_user private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNochp    as handle  no-undo.
    define buffer GL_CHP_USER for GL_CHP_USER.

    create query vhttquery.
    vhttBuffer = ghttGl_chp_user:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttGl_chp_user:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNochp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_CHP_USER exclusive-lock
                where rowid(GL_CHP_USER) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_CHP_USER:handle, 'nochp: ', substitute('&1', vhNochp:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer GL_CHP_USER:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createGl_chp_user private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer GL_CHP_USER for GL_CHP_USER.

    create query vhttquery.
    vhttBuffer = ghttGl_chp_user:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttGl_chp_user:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create GL_CHP_USER.
            if not outils:copyValidField(buffer GL_CHP_USER:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteGl_chp_user private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNochp    as handle  no-undo.
    define buffer GL_CHP_USER for GL_CHP_USER.

    create query vhttquery.
    vhttBuffer = ghttGl_chp_user:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttGl_chp_user:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNochp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_CHP_USER exclusive-lock
                where rowid(Gl_chp_user) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_CHP_USER:handle, 'nochp: ', substitute('&1', vhNochp:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete GL_CHP_USER no-error.
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

