/*------------------------------------------------------------------------
File        : DesEv_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table DesEv
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/DesEv.i}
{application/include/error.i}
define variable ghttDesEv as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoeve as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur NoEve, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'NoEve' then phNoeve = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudDesev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteDesev.
    run updateDesev.
    run createDesev.
end procedure.

procedure setDesev:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttDesev.
    ghttDesev = phttDesev.
    run crudDesev.
    delete object phttDesev.
end procedure.

procedure readDesev:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table DesEv 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoeve as integer    no-undo.
    define input parameter table-handle phttDesev.
    define variable vhttBuffer as handle no-undo.
    define buffer DesEv for DesEv.

    vhttBuffer = phttDesev:default-buffer-handle.
    for first DesEv no-lock
        where DesEv.NoEve = piNoeve:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DesEv:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDesev no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getDesev:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table DesEv 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttDesev.
    define variable vhttBuffer as handle  no-undo.
    define buffer DesEv for DesEv.

    vhttBuffer = phttDesev:default-buffer-handle.
    for each DesEv no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DesEv:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDesev no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateDesev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoeve    as handle  no-undo.
    define buffer DesEv for DesEv.

    create query vhttquery.
    vhttBuffer = ghttDesev:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttDesev:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoeve).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first DesEv exclusive-lock
                where rowid(DesEv) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer DesEv:handle, 'NoEve: ', substitute('&1', vhNoeve:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer DesEv:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createDesev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer DesEv for DesEv.

    create query vhttquery.
    vhttBuffer = ghttDesev:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttDesev:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create DesEv.
            if not outils:copyValidField(buffer DesEv:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteDesev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoeve    as handle  no-undo.
    define buffer DesEv for DesEv.

    create query vhttquery.
    vhttBuffer = ghttDesev:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttDesev:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoeve).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first DesEv exclusive-lock
                where rowid(Desev) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer DesEv:handle, 'NoEve: ', substitute('&1', vhNoeve:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete DesEv no-error.
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

