/*------------------------------------------------------------------------
File        : GL_PROXIMITE_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table GL_PROXIMITE
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/GL_PROXIMITE.i}
{application/include/error.i}
define variable ghttGL_PROXIMITE as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoproximite as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noproximite, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noproximite' then phNoproximite = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudGl_proximite private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteGl_proximite.
    run updateGl_proximite.
    run createGl_proximite.
end procedure.

procedure setGl_proximite:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_proximite.
    ghttGl_proximite = phttGl_proximite.
    run crudGl_proximite.
    delete object phttGl_proximite.
end procedure.

procedure readGl_proximite:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table GL_PROXIMITE Liste des proximités (métro, commerce...)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoproximite as integer    no-undo.
    define input parameter table-handle phttGl_proximite.
    define variable vhttBuffer as handle no-undo.
    define buffer GL_PROXIMITE for GL_PROXIMITE.

    vhttBuffer = phttGl_proximite:default-buffer-handle.
    for first GL_PROXIMITE no-lock
        where GL_PROXIMITE.noproximite = piNoproximite:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_PROXIMITE:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_proximite no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getGl_proximite:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table GL_PROXIMITE Liste des proximités (métro, commerce...)
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_proximite.
    define variable vhttBuffer as handle  no-undo.
    define buffer GL_PROXIMITE for GL_PROXIMITE.

    vhttBuffer = phttGl_proximite:default-buffer-handle.
    for each GL_PROXIMITE no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_PROXIMITE:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_proximite no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateGl_proximite private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoproximite    as handle  no-undo.
    define buffer GL_PROXIMITE for GL_PROXIMITE.

    create query vhttquery.
    vhttBuffer = ghttGl_proximite:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttGl_proximite:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoproximite).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_PROXIMITE exclusive-lock
                where rowid(GL_PROXIMITE) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_PROXIMITE:handle, 'noproximite: ', substitute('&1', vhNoproximite:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer GL_PROXIMITE:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createGl_proximite private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer GL_PROXIMITE for GL_PROXIMITE.

    create query vhttquery.
    vhttBuffer = ghttGl_proximite:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttGl_proximite:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create GL_PROXIMITE.
            if not outils:copyValidField(buffer GL_PROXIMITE:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteGl_proximite private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoproximite    as handle  no-undo.
    define buffer GL_PROXIMITE for GL_PROXIMITE.

    create query vhttquery.
    vhttBuffer = ghttGl_proximite:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttGl_proximite:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoproximite).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_PROXIMITE exclusive-lock
                where rowid(Gl_proximite) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_PROXIMITE:handle, 'noproximite: ', substitute('&1', vhNoproximite:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete GL_PROXIMITE no-error.
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

