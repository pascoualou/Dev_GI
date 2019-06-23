/*------------------------------------------------------------------------
File        : GL_HISTO_LOYER89_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table GL_HISTO_LOYER89
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/GL_HISTO_LOYER89.i}
{application/include/error.i}
define variable ghttGL_HISTO_LOYER89 as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNohisto_loyer89 as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nohisto_loyer89, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nohisto_loyer89' then phNohisto_loyer89 = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudGl_histo_loyer89 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteGl_histo_loyer89.
    run updateGl_histo_loyer89.
    run createGl_histo_loyer89.
end procedure.

procedure setGl_histo_loyer89:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_histo_loyer89.
    ghttGl_histo_loyer89 = phttGl_histo_loyer89.
    run crudGl_histo_loyer89.
    delete object phttGl_histo_loyer89.
end procedure.

procedure readGl_histo_loyer89:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table GL_HISTO_LOYER89 Historique de l'aide à la saisie du calcul du loyer loi 89
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNohisto_loyer89 as integer    no-undo.
    define input parameter table-handle phttGl_histo_loyer89.
    define variable vhttBuffer as handle no-undo.
    define buffer GL_HISTO_LOYER89 for GL_HISTO_LOYER89.

    vhttBuffer = phttGl_histo_loyer89:default-buffer-handle.
    for first GL_HISTO_LOYER89 no-lock
        where GL_HISTO_LOYER89.nohisto_loyer89 = piNohisto_loyer89:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_HISTO_LOYER89:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_histo_loyer89 no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getGl_histo_loyer89:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table GL_HISTO_LOYER89 Historique de l'aide à la saisie du calcul du loyer loi 89
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_histo_loyer89.
    define variable vhttBuffer as handle  no-undo.
    define buffer GL_HISTO_LOYER89 for GL_HISTO_LOYER89.

    vhttBuffer = phttGl_histo_loyer89:default-buffer-handle.
    for each GL_HISTO_LOYER89 no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_HISTO_LOYER89:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_histo_loyer89 no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateGl_histo_loyer89 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNohisto_loyer89    as handle  no-undo.
    define buffer GL_HISTO_LOYER89 for GL_HISTO_LOYER89.

    create query vhttquery.
    vhttBuffer = ghttGl_histo_loyer89:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttGl_histo_loyer89:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNohisto_loyer89).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_HISTO_LOYER89 exclusive-lock
                where rowid(GL_HISTO_LOYER89) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_HISTO_LOYER89:handle, 'nohisto_loyer89: ', substitute('&1', vhNohisto_loyer89:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer GL_HISTO_LOYER89:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createGl_histo_loyer89 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer GL_HISTO_LOYER89 for GL_HISTO_LOYER89.

    create query vhttquery.
    vhttBuffer = ghttGl_histo_loyer89:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttGl_histo_loyer89:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create GL_HISTO_LOYER89.
            if not outils:copyValidField(buffer GL_HISTO_LOYER89:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteGl_histo_loyer89 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNohisto_loyer89    as handle  no-undo.
    define buffer GL_HISTO_LOYER89 for GL_HISTO_LOYER89.

    create query vhttquery.
    vhttBuffer = ghttGl_histo_loyer89:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttGl_histo_loyer89:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNohisto_loyer89).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_HISTO_LOYER89 exclusive-lock
                where rowid(Gl_histo_loyer89) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_HISTO_LOYER89:handle, 'nohisto_loyer89: ', substitute('&1', vhNohisto_loyer89:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete GL_HISTO_LOYER89 no-error.
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

