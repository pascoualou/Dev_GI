/*------------------------------------------------------------------------
File        : gl_CHPFINANCE_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table gl_CHPFINANCE
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/gl_CHPFINANCE.i}
{application/include/error.i}
define variable ghttgl_CHPFINANCE as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNochpfinance as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nochpfinance, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nochpfinance' then phNochpfinance = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudGl_chpfinance private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteGl_chpfinance.
    run updateGl_chpfinance.
    run createGl_chpfinance.
end procedure.

procedure setGl_chpfinance:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_chpfinance.
    ghttGl_chpfinance = phttGl_chpfinance.
    run crudGl_chpfinance.
    delete object phttGl_chpfinance.
end procedure.

procedure readGl_chpfinance:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table gl_CHPFINANCE Liste des champs "détails financiers" par type de finance. Exemple : Stationnement" dans un élément financier de type "Loyer".
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNochpfinance as integer    no-undo.
    define input parameter table-handle phttGl_chpfinance.
    define variable vhttBuffer as handle no-undo.
    define buffer gl_CHPFINANCE for gl_CHPFINANCE.

    vhttBuffer = phttGl_chpfinance:default-buffer-handle.
    for first gl_CHPFINANCE no-lock
        where gl_CHPFINANCE.nochpfinance = piNochpfinance:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer gl_CHPFINANCE:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_chpfinance no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getGl_chpfinance:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table gl_CHPFINANCE Liste des champs "détails financiers" par type de finance. Exemple : Stationnement" dans un élément financier de type "Loyer".
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_chpfinance.
    define variable vhttBuffer as handle  no-undo.
    define buffer gl_CHPFINANCE for gl_CHPFINANCE.

    vhttBuffer = phttGl_chpfinance:default-buffer-handle.
    for each gl_CHPFINANCE no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer gl_CHPFINANCE:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_chpfinance no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateGl_chpfinance private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNochpfinance    as handle  no-undo.
    define buffer gl_CHPFINANCE for gl_CHPFINANCE.

    create query vhttquery.
    vhttBuffer = ghttGl_chpfinance:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttGl_chpfinance:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNochpfinance).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first gl_CHPFINANCE exclusive-lock
                where rowid(gl_CHPFINANCE) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer gl_CHPFINANCE:handle, 'nochpfinance: ', substitute('&1', vhNochpfinance:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer gl_CHPFINANCE:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createGl_chpfinance private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer gl_CHPFINANCE for gl_CHPFINANCE.

    create query vhttquery.
    vhttBuffer = ghttGl_chpfinance:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttGl_chpfinance:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create gl_CHPFINANCE.
            if not outils:copyValidField(buffer gl_CHPFINANCE:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteGl_chpfinance private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNochpfinance    as handle  no-undo.
    define buffer gl_CHPFINANCE for gl_CHPFINANCE.

    create query vhttquery.
    vhttBuffer = ghttGl_chpfinance:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttGl_chpfinance:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNochpfinance).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first gl_CHPFINANCE exclusive-lock
                where rowid(Gl_chpfinance) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer gl_CHPFINANCE:handle, 'nochpfinance: ', substitute('&1', vhNochpfinance:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete gl_CHPFINANCE no-error.
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

