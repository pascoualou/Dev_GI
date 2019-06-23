/*------------------------------------------------------------------------
File        : istatsgi_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table istatsgi
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/istatsgi.i}
{application/include/error.i}
define variable ghttistatsgi as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur , 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
       end case.
    end.
end function.

procedure crudIstatsgi private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIstatsgi.
    run updateIstatsgi.
    run createIstatsgi.
end procedure.

procedure setIstatsgi:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIstatsgi.
    ghttIstatsgi = phttIstatsgi.
    run crudIstatsgi.
    delete object phttIstatsgi.
end procedure.

procedure readIstatsgi:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table istatsgi 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIstatsgi.
    define variable vhttBuffer as handle no-undo.
    define buffer istatsgi for istatsgi.

    vhttBuffer = phttIstatsgi:default-buffer-handle.
    for first istatsgi no-lock
        where :
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer istatsgi:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIstatsgi no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIstatsgi:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table istatsgi 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIstatsgi.
    define variable vhttBuffer as handle  no-undo.
    define buffer istatsgi for istatsgi.

    vhttBuffer = phttIstatsgi:default-buffer-handle.
    for each istatsgi no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer istatsgi:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIstatsgi no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIstatsgi private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer istatsgi for istatsgi.

    create query vhttquery.
    vhttBuffer = ghttIstatsgi:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIstatsgi:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first istatsgi exclusive-lock
                where rowid(istatsgi) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer istatsgi:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer istatsgi:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIstatsgi private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer istatsgi for istatsgi.

    create query vhttquery.
    vhttBuffer = ghttIstatsgi:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIstatsgi:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create istatsgi.
            if not outils:copyValidField(buffer istatsgi:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIstatsgi private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer istatsgi for istatsgi.

    create query vhttquery.
    vhttBuffer = ghttIstatsgi:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIstatsgi:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first istatsgi exclusive-lock
                where rowid(Istatsgi) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer istatsgi:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete istatsgi no-error.
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

