/*------------------------------------------------------------------------
File        : magiToken_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table magiToken
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/magiToken.i}
{application/include/error.i}
define variable ghttmagiToken as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phJsessionid as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur jSessionId, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'jSessionId' then phJsessionid = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudMagitoken private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteMagitoken.
    run updateMagitoken.
    run createMagitoken.
end procedure.

procedure setMagitoken:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttMagitoken.
    ghttMagitoken = phttMagitoken.
    run crudMagitoken.
    delete object phttMagitoken.
end procedure.

procedure readMagitoken:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table magiToken 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcJsessionid as character  no-undo.
    define input parameter table-handle phttMagitoken.
    define variable vhttBuffer as handle no-undo.
    define buffer magiToken for magiToken.

    vhttBuffer = phttMagitoken:default-buffer-handle.
    for first magiToken no-lock
        where magiToken.jSessionId = pcJsessionid:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer magiToken:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMagitoken no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getMagitoken:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table magiToken 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttMagitoken.
    define variable vhttBuffer as handle  no-undo.
    define buffer magiToken for magiToken.

    vhttBuffer = phttMagitoken:default-buffer-handle.
    for each magiToken no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer magiToken:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMagitoken no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateMagitoken private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhJsessionid    as handle  no-undo.
    define buffer magiToken for magiToken.

    create query vhttquery.
    vhttBuffer = ghttMagitoken:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttMagitoken:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhJsessionid).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first magiToken exclusive-lock
                where rowid(magiToken) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer magiToken:handle, 'jSessionId: ', substitute('&1', vhJsessionid:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer magiToken:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createMagitoken private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer magiToken for magiToken.

    create query vhttquery.
    vhttBuffer = ghttMagitoken:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttMagitoken:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create magiToken.
            if not outils:copyValidField(buffer magiToken:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteMagitoken private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhJsessionid    as handle  no-undo.
    define buffer magiToken for magiToken.

    create query vhttquery.
    vhttBuffer = ghttMagitoken:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttMagitoken:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhJsessionid).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first magiToken exclusive-lock
                where rowid(Magitoken) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer magiToken:handle, 'jSessionId: ', substitute('&1', vhJsessionid:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete magiToken no-error.
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

