/*------------------------------------------------------------------------
File        : zspool_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table zspool
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/zspool.i}
{application/include/error.i}
define variable ghttzspool as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phPort as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur port, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'port' then phPort = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudZspool private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteZspool.
    run updateZspool.
    run createZspool.
end procedure.

procedure setZspool:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttZspool.
    ghttZspool = phttZspool.
    run crudZspool.
    delete object phttZspool.
end procedure.

procedure readZspool:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table zspool 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piPort as integer    no-undo.
    define input parameter table-handle phttZspool.
    define variable vhttBuffer as handle no-undo.
    define buffer zspool for zspool.

    vhttBuffer = phttZspool:default-buffer-handle.
    for first zspool no-lock
        where zspool.port = piPort:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer zspool:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttZspool no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getZspool:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table zspool 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttZspool.
    define variable vhttBuffer as handle  no-undo.
    define buffer zspool for zspool.

    vhttBuffer = phttZspool:default-buffer-handle.
    for each zspool no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer zspool:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttZspool no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateZspool private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhPort    as handle  no-undo.
    define buffer zspool for zspool.

    create query vhttquery.
    vhttBuffer = ghttZspool:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttZspool:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhPort).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first zspool exclusive-lock
                where rowid(zspool) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer zspool:handle, 'port: ', substitute('&1', vhPort:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer zspool:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createZspool private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer zspool for zspool.

    create query vhttquery.
    vhttBuffer = ghttZspool:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttZspool:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create zspool.
            if not outils:copyValidField(buffer zspool:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteZspool private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhPort    as handle  no-undo.
    define buffer zspool for zspool.

    create query vhttquery.
    vhttBuffer = ghttZspool:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttZspool:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhPort).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first zspool exclusive-lock
                where rowid(Zspool) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer zspool:handle, 'port: ', substitute('&1', vhPort:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete zspool no-error.
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

