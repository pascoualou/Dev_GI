/*------------------------------------------------------------------------
File        : GL_HONORAIRE_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table GL_HONORAIRE
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/GL_HONORAIRE.i}
{application/include/error.i}
define variable ghttGL_HONORAIRE as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNohonoraire as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nohonoraire, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nohonoraire' then phNohonoraire = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudGl_honoraire private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteGl_honoraire.
    run updateGl_honoraire.
    run createGl_honoraire.
end procedure.

procedure setGl_honoraire:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_honoraire.
    ghttGl_honoraire = phttGl_honoraire.
    run crudGl_honoraire.
    delete object phttGl_honoraire.
end procedure.

procedure readGl_honoraire:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table GL_HONORAIRE Liste des éléments financiers de type honoraires
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNohonoraire as integer    no-undo.
    define input parameter table-handle phttGl_honoraire.
    define variable vhttBuffer as handle no-undo.
    define buffer GL_HONORAIRE for GL_HONORAIRE.

    vhttBuffer = phttGl_honoraire:default-buffer-handle.
    for first GL_HONORAIRE no-lock
        where GL_HONORAIRE.nohonoraire = piNohonoraire:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_HONORAIRE:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_honoraire no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getGl_honoraire:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table GL_HONORAIRE Liste des éléments financiers de type honoraires
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_honoraire.
    define variable vhttBuffer as handle  no-undo.
    define buffer GL_HONORAIRE for GL_HONORAIRE.

    vhttBuffer = phttGl_honoraire:default-buffer-handle.
    for each GL_HONORAIRE no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_HONORAIRE:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_honoraire no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateGl_honoraire private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNohonoraire    as handle  no-undo.
    define buffer GL_HONORAIRE for GL_HONORAIRE.

    create query vhttquery.
    vhttBuffer = ghttGl_honoraire:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttGl_honoraire:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNohonoraire).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_HONORAIRE exclusive-lock
                where rowid(GL_HONORAIRE) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_HONORAIRE:handle, 'nohonoraire: ', substitute('&1', vhNohonoraire:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer GL_HONORAIRE:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createGl_honoraire private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer GL_HONORAIRE for GL_HONORAIRE.

    create query vhttquery.
    vhttBuffer = ghttGl_honoraire:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttGl_honoraire:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create GL_HONORAIRE.
            if not outils:copyValidField(buffer GL_HONORAIRE:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteGl_honoraire private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNohonoraire    as handle  no-undo.
    define buffer GL_HONORAIRE for GL_HONORAIRE.

    create query vhttquery.
    vhttBuffer = ghttGl_honoraire:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttGl_honoraire:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNohonoraire).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_HONORAIRE exclusive-lock
                where rowid(Gl_honoraire) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_HONORAIRE:handle, 'nohonoraire: ', substitute('&1', vhNohonoraire:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete GL_HONORAIRE no-error.
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

