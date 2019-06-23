/*------------------------------------------------------------------------
File        : LSTTYPAPP_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table LSTTYPAPP
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/LSTTYPAPP.i}
{application/include/error.i}
define variable ghttLSTTYPAPP as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTypapp-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur typapp-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'typapp-cd' then phTypapp-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudLsttypapp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteLsttypapp.
    run updateLsttypapp.
    run createLsttypapp.
end procedure.

procedure setLsttypapp:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttLsttypapp.
    ghttLsttypapp = phttLsttypapp.
    run crudLsttypapp.
    delete object phttLsttypapp.
end procedure.

procedure readLsttypapp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table LSTTYPAPP 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypapp-cd as character  no-undo.
    define input parameter table-handle phttLsttypapp.
    define variable vhttBuffer as handle no-undo.
    define buffer LSTTYPAPP for LSTTYPAPP.

    vhttBuffer = phttLsttypapp:default-buffer-handle.
    for first LSTTYPAPP no-lock
        where LSTTYPAPP.typapp-cd = pcTypapp-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer LSTTYPAPP:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLsttypapp no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getLsttypapp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table LSTTYPAPP 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttLsttypapp.
    define variable vhttBuffer as handle  no-undo.
    define buffer LSTTYPAPP for LSTTYPAPP.

    vhttBuffer = phttLsttypapp:default-buffer-handle.
    for each LSTTYPAPP no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer LSTTYPAPP:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLsttypapp no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateLsttypapp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTypapp-cd    as handle  no-undo.
    define buffer LSTTYPAPP for LSTTYPAPP.

    create query vhttquery.
    vhttBuffer = ghttLsttypapp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttLsttypapp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTypapp-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first LSTTYPAPP exclusive-lock
                where rowid(LSTTYPAPP) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer LSTTYPAPP:handle, 'typapp-cd: ', substitute('&1', vhTypapp-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer LSTTYPAPP:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createLsttypapp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer LSTTYPAPP for LSTTYPAPP.

    create query vhttquery.
    vhttBuffer = ghttLsttypapp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttLsttypapp:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create LSTTYPAPP.
            if not outils:copyValidField(buffer LSTTYPAPP:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteLsttypapp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTypapp-cd    as handle  no-undo.
    define buffer LSTTYPAPP for LSTTYPAPP.

    create query vhttquery.
    vhttBuffer = ghttLsttypapp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttLsttypapp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTypapp-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first LSTTYPAPP exclusive-lock
                where rowid(Lsttypapp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer LSTTYPAPP:handle, 'typapp-cd: ', substitute('&1', vhTypapp-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete LSTTYPAPP no-error.
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

