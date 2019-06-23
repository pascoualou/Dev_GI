/*------------------------------------------------------------------------
File        : GL_HISTO_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table GL_HISTO
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/GL_HISTO.i}
{application/include/error.i}
define variable ghttGL_HISTO as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNohisto as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nohisto, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nohisto' then phNohisto = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudGl_histo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteGl_histo.
    run updateGl_histo.
    run createGl_histo.
end procedure.

procedure setGl_histo:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_histo.
    ghttGl_histo = phttGl_histo.
    run crudGl_histo.
    delete object phttGl_histo.
end procedure.

procedure readGl_histo:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table GL_HISTO Historique de la fiche
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNohisto as integer    no-undo.
    define input parameter table-handle phttGl_histo.
    define variable vhttBuffer as handle no-undo.
    define buffer GL_HISTO for GL_HISTO.

    vhttBuffer = phttGl_histo:default-buffer-handle.
    for first GL_HISTO no-lock
        where GL_HISTO.nohisto = piNohisto:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_HISTO:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_histo no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getGl_histo:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table GL_HISTO Historique de la fiche
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_histo.
    define variable vhttBuffer as handle  no-undo.
    define buffer GL_HISTO for GL_HISTO.

    vhttBuffer = phttGl_histo:default-buffer-handle.
    for each GL_HISTO no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_HISTO:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_histo no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateGl_histo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNohisto    as handle  no-undo.
    define buffer GL_HISTO for GL_HISTO.

    create query vhttquery.
    vhttBuffer = ghttGl_histo:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttGl_histo:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNohisto).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_HISTO exclusive-lock
                where rowid(GL_HISTO) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_HISTO:handle, 'nohisto: ', substitute('&1', vhNohisto:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer GL_HISTO:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createGl_histo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer GL_HISTO for GL_HISTO.

    create query vhttquery.
    vhttBuffer = ghttGl_histo:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttGl_histo:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create GL_HISTO.
            if not outils:copyValidField(buffer GL_HISTO:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteGl_histo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNohisto    as handle  no-undo.
    define buffer GL_HISTO for GL_HISTO.

    create query vhttquery.
    vhttBuffer = ghttGl_histo:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttGl_histo:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNohisto).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_HISTO exclusive-lock
                where rowid(Gl_histo) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_HISTO:handle, 'nohisto: ', substitute('&1', vhNohisto:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete GL_HISTO no-error.
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

