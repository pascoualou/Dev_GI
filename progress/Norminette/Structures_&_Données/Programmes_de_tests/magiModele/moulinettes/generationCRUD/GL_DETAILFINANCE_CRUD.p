/*------------------------------------------------------------------------
File        : GL_DETAILFINANCE_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table GL_DETAILFINANCE
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/GL_DETAILFINANCE.i}
{application/include/error.i}
define variable ghttGL_DETAILFINANCE as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNodetailfinance as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nodetailfinance, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nodetailfinance' then phNodetailfinance = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudGl_detailfinance private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteGl_detailfinance.
    run updateGl_detailfinance.
    run createGl_detailfinance.
end procedure.

procedure setGl_detailfinance:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_detailfinance.
    ghttGl_detailfinance = phttGl_detailfinance.
    run crudGl_detailfinance.
    delete object phttGl_detailfinance.
end procedure.

procedure readGl_detailfinance:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table GL_DETAILFINANCE Ligne de détails des éléments financiers
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNodetailfinance as integer    no-undo.
    define input parameter table-handle phttGl_detailfinance.
    define variable vhttBuffer as handle no-undo.
    define buffer GL_DETAILFINANCE for GL_DETAILFINANCE.

    vhttBuffer = phttGl_detailfinance:default-buffer-handle.
    for first GL_DETAILFINANCE no-lock
        where GL_DETAILFINANCE.nodetailfinance = piNodetailfinance:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_DETAILFINANCE:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_detailfinance no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getGl_detailfinance:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table GL_DETAILFINANCE Ligne de détails des éléments financiers
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_detailfinance.
    define variable vhttBuffer as handle  no-undo.
    define buffer GL_DETAILFINANCE for GL_DETAILFINANCE.

    vhttBuffer = phttGl_detailfinance:default-buffer-handle.
    for each GL_DETAILFINANCE no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_DETAILFINANCE:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_detailfinance no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateGl_detailfinance private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNodetailfinance    as handle  no-undo.
    define buffer GL_DETAILFINANCE for GL_DETAILFINANCE.

    create query vhttquery.
    vhttBuffer = ghttGl_detailfinance:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttGl_detailfinance:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNodetailfinance).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_DETAILFINANCE exclusive-lock
                where rowid(GL_DETAILFINANCE) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_DETAILFINANCE:handle, 'nodetailfinance: ', substitute('&1', vhNodetailfinance:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer GL_DETAILFINANCE:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createGl_detailfinance private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer GL_DETAILFINANCE for GL_DETAILFINANCE.

    create query vhttquery.
    vhttBuffer = ghttGl_detailfinance:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttGl_detailfinance:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create GL_DETAILFINANCE.
            if not outils:copyValidField(buffer GL_DETAILFINANCE:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteGl_detailfinance private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNodetailfinance    as handle  no-undo.
    define buffer GL_DETAILFINANCE for GL_DETAILFINANCE.

    create query vhttquery.
    vhttBuffer = ghttGl_detailfinance:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttGl_detailfinance:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNodetailfinance).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_DETAILFINANCE exclusive-lock
                where rowid(Gl_detailfinance) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_DETAILFINANCE:handle, 'nodetailfinance: ', substitute('&1', vhNodetailfinance:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete GL_DETAILFINANCE no-error.
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

