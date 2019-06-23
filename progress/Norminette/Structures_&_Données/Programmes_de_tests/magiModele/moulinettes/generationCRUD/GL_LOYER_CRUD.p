/*------------------------------------------------------------------------
File        : GL_LOYER_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table GL_LOYER
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/GL_LOYER.i}
{application/include/error.i}
define variable ghttGL_LOYER as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoloyer as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noloyer, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noloyer' then phNoloyer = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudGl_loyer private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteGl_loyer.
    run updateGl_loyer.
    run createGl_loyer.
end procedure.

procedure setGl_loyer:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_loyer.
    ghttGl_loyer = phttGl_loyer.
    run crudGl_loyer.
    delete object phttGl_loyer.
end procedure.

procedure readGl_loyer:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table GL_LOYER Liste des éléments financiers de type loyer
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoloyer as integer    no-undo.
    define input parameter table-handle phttGl_loyer.
    define variable vhttBuffer as handle no-undo.
    define buffer GL_LOYER for GL_LOYER.

    vhttBuffer = phttGl_loyer:default-buffer-handle.
    for first GL_LOYER no-lock
        where GL_LOYER.noloyer = piNoloyer:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_LOYER:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_loyer no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getGl_loyer:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table GL_LOYER Liste des éléments financiers de type loyer
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_loyer.
    define variable vhttBuffer as handle  no-undo.
    define buffer GL_LOYER for GL_LOYER.

    vhttBuffer = phttGl_loyer:default-buffer-handle.
    for each GL_LOYER no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_LOYER:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_loyer no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateGl_loyer private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoloyer    as handle  no-undo.
    define buffer GL_LOYER for GL_LOYER.

    create query vhttquery.
    vhttBuffer = ghttGl_loyer:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttGl_loyer:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoloyer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_LOYER exclusive-lock
                where rowid(GL_LOYER) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_LOYER:handle, 'noloyer: ', substitute('&1', vhNoloyer:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer GL_LOYER:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createGl_loyer private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer GL_LOYER for GL_LOYER.

    create query vhttquery.
    vhttBuffer = ghttGl_loyer:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttGl_loyer:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create GL_LOYER.
            if not outils:copyValidField(buffer GL_LOYER:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteGl_loyer private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoloyer    as handle  no-undo.
    define buffer GL_LOYER for GL_LOYER.

    create query vhttquery.
    vhttBuffer = ghttGl_loyer:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttGl_loyer:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoloyer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_LOYER exclusive-lock
                where rowid(Gl_loyer) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_LOYER:handle, 'noloyer: ', substitute('&1', vhNoloyer:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete GL_LOYER no-error.
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

