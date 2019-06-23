/*------------------------------------------------------------------------
File        : aloye_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table aloye
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/aloye.i}
{application/include/error.i}
define variable ghttaloye as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phMsqtt as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur msqtt, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'msqtt' then phMsqtt = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAloye private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAloye.
    run updateAloye.
    run createAloye.
end procedure.

procedure setAloye:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAloye.
    ghttAloye = phttAloye.
    run crudAloye.
    delete object phttAloye.
end procedure.

procedure readAloye:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table aloye 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piMsqtt as integer    no-undo.
    define input parameter table-handle phttAloye.
    define variable vhttBuffer as handle no-undo.
    define buffer aloye for aloye.

    vhttBuffer = phttAloye:default-buffer-handle.
    for first aloye no-lock
        where aloye.msqtt = piMsqtt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aloye:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAloye no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAloye:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table aloye 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAloye.
    define variable vhttBuffer as handle  no-undo.
    define buffer aloye for aloye.

    vhttBuffer = phttAloye:default-buffer-handle.
    for each aloye no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aloye:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAloye no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAloye private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhMsqtt    as handle  no-undo.
    define buffer aloye for aloye.

    create query vhttquery.
    vhttBuffer = ghttAloye:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAloye:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhMsqtt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aloye exclusive-lock
                where rowid(aloye) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aloye:handle, 'msqtt: ', substitute('&1', vhMsqtt:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer aloye:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAloye private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer aloye for aloye.

    create query vhttquery.
    vhttBuffer = ghttAloye:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAloye:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create aloye.
            if not outils:copyValidField(buffer aloye:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAloye private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhMsqtt    as handle  no-undo.
    define buffer aloye for aloye.

    create query vhttquery.
    vhttBuffer = ghttAloye:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAloye:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhMsqtt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aloye exclusive-lock
                where rowid(Aloye) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aloye:handle, 'msqtt: ', substitute('&1', vhMsqtt:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete aloye no-error.
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

