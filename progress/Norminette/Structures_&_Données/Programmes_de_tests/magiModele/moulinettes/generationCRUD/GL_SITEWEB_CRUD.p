/*------------------------------------------------------------------------
File        : GL_SITEWEB_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table GL_SITEWEB
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/GL_SITEWEB.i}
{application/include/error.i}
define variable ghttGL_SITEWEB as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNositeweb as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nositeweb, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nositeweb' then phNositeweb = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudGl_siteweb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteGl_siteweb.
    run updateGl_siteweb.
    run createGl_siteweb.
end procedure.

procedure setGl_siteweb:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_siteweb.
    ghttGl_siteweb = phttGl_siteweb.
    run crudGl_siteweb.
    delete object phttGl_siteweb.
end procedure.

procedure readGl_siteweb:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table GL_SITEWEB 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNositeweb as integer    no-undo.
    define input parameter table-handle phttGl_siteweb.
    define variable vhttBuffer as handle no-undo.
    define buffer GL_SITEWEB for GL_SITEWEB.

    vhttBuffer = phttGl_siteweb:default-buffer-handle.
    for first GL_SITEWEB no-lock
        where GL_SITEWEB.nositeweb = piNositeweb:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_SITEWEB:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_siteweb no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getGl_siteweb:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table GL_SITEWEB 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_siteweb.
    define variable vhttBuffer as handle  no-undo.
    define buffer GL_SITEWEB for GL_SITEWEB.

    vhttBuffer = phttGl_siteweb:default-buffer-handle.
    for each GL_SITEWEB no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_SITEWEB:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_siteweb no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateGl_siteweb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNositeweb    as handle  no-undo.
    define buffer GL_SITEWEB for GL_SITEWEB.

    create query vhttquery.
    vhttBuffer = ghttGl_siteweb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttGl_siteweb:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNositeweb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_SITEWEB exclusive-lock
                where rowid(GL_SITEWEB) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_SITEWEB:handle, 'nositeweb: ', substitute('&1', vhNositeweb:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer GL_SITEWEB:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createGl_siteweb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer GL_SITEWEB for GL_SITEWEB.

    create query vhttquery.
    vhttBuffer = ghttGl_siteweb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttGl_siteweb:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create GL_SITEWEB.
            if not outils:copyValidField(buffer GL_SITEWEB:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteGl_siteweb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNositeweb    as handle  no-undo.
    define buffer GL_SITEWEB for GL_SITEWEB.

    create query vhttquery.
    vhttBuffer = ghttGl_siteweb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttGl_siteweb:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNositeweb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_SITEWEB exclusive-lock
                where rowid(Gl_siteweb) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_SITEWEB:handle, 'nositeweb: ', substitute('&1', vhNositeweb:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete GL_SITEWEB no-error.
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

