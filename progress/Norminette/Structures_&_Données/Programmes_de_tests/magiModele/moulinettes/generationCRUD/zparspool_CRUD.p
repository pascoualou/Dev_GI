/*------------------------------------------------------------------------
File        : zparspool_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table zparspool
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/zparspool.i}
{application/include/error.i}
define variable ghttzparspool as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudZparspool private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteZparspool.
    run updateZparspool.
    run createZparspool.
end procedure.

procedure setZparspool:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttZparspool.
    ghttZparspool = phttZparspool.
    run crudZparspool.
    delete object phttZparspool.
end procedure.

procedure readZparspool:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table zparspool 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttZparspool.
    define variable vhttBuffer as handle no-undo.
    define buffer zparspool for zparspool.

    vhttBuffer = phttZparspool:default-buffer-handle.
    for first zparspool no-lock
        where :
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer zparspool:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttZparspool no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getZparspool:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table zparspool 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttZparspool.
    define variable vhttBuffer as handle  no-undo.
    define buffer zparspool for zparspool.

    vhttBuffer = phttZparspool:default-buffer-handle.
    for each zparspool no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer zparspool:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttZparspool no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateZparspool private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer zparspool for zparspool.

    create query vhttquery.
    vhttBuffer = ghttZparspool:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttZparspool:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first zparspool exclusive-lock
                where rowid(zparspool) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer zparspool:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer zparspool:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createZparspool private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer zparspool for zparspool.

    create query vhttquery.
    vhttBuffer = ghttZparspool:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttZparspool:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create zparspool.
            if not outils:copyValidField(buffer zparspool:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteZparspool private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer zparspool for zparspool.

    create query vhttquery.
    vhttBuffer = ghttZparspool:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttZparspool:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first zparspool exclusive-lock
                where rowid(Zparspool) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer zparspool:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete zparspool no-error.
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

