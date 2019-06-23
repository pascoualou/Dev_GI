/*------------------------------------------------------------------------
File        : gatac_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table gatac
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/gatac.i}
{application/include/error.i}
define variable ghttgatac as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNotac as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur notac, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'notac' then phNotac = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudGatac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteGatac.
    run updateGatac.
    run createGatac.
end procedure.

procedure setGatac:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGatac.
    ghttGatac = phttGatac.
    run crudGatac.
    delete object phttGatac.
end procedure.

procedure readGatac:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table gatac 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNotac as integer    no-undo.
    define input parameter table-handle phttGatac.
    define variable vhttBuffer as handle no-undo.
    define buffer gatac for gatac.

    vhttBuffer = phttGatac:default-buffer-handle.
    for first gatac no-lock
        where gatac.notac = piNotac:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer gatac:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGatac no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getGatac:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table gatac 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGatac.
    define variable vhttBuffer as handle  no-undo.
    define buffer gatac for gatac.

    vhttBuffer = phttGatac:default-buffer-handle.
    for each gatac no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer gatac:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGatac no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateGatac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNotac    as handle  no-undo.
    define buffer gatac for gatac.

    create query vhttquery.
    vhttBuffer = ghttGatac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttGatac:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNotac).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first gatac exclusive-lock
                where rowid(gatac) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer gatac:handle, 'notac: ', substitute('&1', vhNotac:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer gatac:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createGatac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer gatac for gatac.

    create query vhttquery.
    vhttBuffer = ghttGatac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttGatac:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create gatac.
            if not outils:copyValidField(buffer gatac:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteGatac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNotac    as handle  no-undo.
    define buffer gatac for gatac.

    create query vhttquery.
    vhttBuffer = ghttGatac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttGatac:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNotac).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first gatac exclusive-lock
                where rowid(Gatac) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer gatac:handle, 'notac: ', substitute('&1', vhNotac:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete gatac no-error.
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

