/*------------------------------------------------------------------------
File        : GL_FINANCE_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table GL_FINANCE
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/GL_FINANCE.i}
{application/include/error.i}
define variable ghttGL_FINANCE as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNofinance as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nofinance, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nofinance' then phNofinance = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudGl_finance private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteGl_finance.
    run updateGl_finance.
    run createGl_finance.
end procedure.

procedure setGl_finance:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_finance.
    ghttGl_finance = phttGl_finance.
    run crudGl_finance.
    delete object phttGl_finance.
end procedure.

procedure readGl_finance:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table GL_FINANCE Table des éléments financiers (loyers, dépôts, honoraires)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNofinance as integer    no-undo.
    define input parameter table-handle phttGl_finance.
    define variable vhttBuffer as handle no-undo.
    define buffer GL_FINANCE for GL_FINANCE.

    vhttBuffer = phttGl_finance:default-buffer-handle.
    for first GL_FINANCE no-lock
        where GL_FINANCE.nofinance = piNofinance:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_FINANCE:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_finance no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getGl_finance:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table GL_FINANCE Table des éléments financiers (loyers, dépôts, honoraires)
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_finance.
    define variable vhttBuffer as handle  no-undo.
    define buffer GL_FINANCE for GL_FINANCE.

    vhttBuffer = phttGl_finance:default-buffer-handle.
    for each GL_FINANCE no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_FINANCE:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_finance no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateGl_finance private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNofinance    as handle  no-undo.
    define buffer GL_FINANCE for GL_FINANCE.

    create query vhttquery.
    vhttBuffer = ghttGl_finance:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttGl_finance:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNofinance).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_FINANCE exclusive-lock
                where rowid(GL_FINANCE) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_FINANCE:handle, 'nofinance: ', substitute('&1', vhNofinance:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer GL_FINANCE:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createGl_finance private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer GL_FINANCE for GL_FINANCE.

    create query vhttquery.
    vhttBuffer = ghttGl_finance:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttGl_finance:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create GL_FINANCE.
            if not outils:copyValidField(buffer GL_FINANCE:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteGl_finance private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNofinance    as handle  no-undo.
    define buffer GL_FINANCE for GL_FINANCE.

    create query vhttquery.
    vhttBuffer = ghttGl_finance:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttGl_finance:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNofinance).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_FINANCE exclusive-lock
                where rowid(Gl_finance) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_FINANCE:handle, 'nofinance: ', substitute('&1', vhNofinance:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete GL_FINANCE no-error.
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

