/*------------------------------------------------------------------------
File        : TYPAPPDEM_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table TYPAPPDEM
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/TYPAPPDEM.i}
{application/include/error.i}
define variable ghttTYPAPPDEM as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudTypappdem private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTypappdem.
    run updateTypappdem.
    run createTypappdem.
end procedure.

procedure setTypappdem:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTypappdem.
    ghttTypappdem = phttTypappdem.
    run crudTypappdem.
    delete object phttTypappdem.
end procedure.

procedure readTypappdem:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table TYPAPPDEM Lien entre la liste des applications et
la liste des demandes
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTypappdem.
    define variable vhttBuffer as handle no-undo.
    define buffer TYPAPPDEM for TYPAPPDEM.

    vhttBuffer = phttTypappdem:default-buffer-handle.
    for first TYPAPPDEM no-lock
        where :
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer TYPAPPDEM:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTypappdem no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTypappdem:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table TYPAPPDEM Lien entre la liste des applications et
la liste des demandes
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTypappdem.
    define variable vhttBuffer as handle  no-undo.
    define buffer TYPAPPDEM for TYPAPPDEM.

    vhttBuffer = phttTypappdem:default-buffer-handle.
    for each TYPAPPDEM no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer TYPAPPDEM:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTypappdem no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTypappdem private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer TYPAPPDEM for TYPAPPDEM.

    create query vhttquery.
    vhttBuffer = ghttTypappdem:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTypappdem:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first TYPAPPDEM exclusive-lock
                where rowid(TYPAPPDEM) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer TYPAPPDEM:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer TYPAPPDEM:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTypappdem private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer TYPAPPDEM for TYPAPPDEM.

    create query vhttquery.
    vhttBuffer = ghttTypappdem:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTypappdem:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create TYPAPPDEM.
            if not outils:copyValidField(buffer TYPAPPDEM:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTypappdem private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer TYPAPPDEM for TYPAPPDEM.

    create query vhttquery.
    vhttBuffer = ghttTypappdem:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTypappdem:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first TYPAPPDEM exclusive-lock
                where rowid(Typappdem) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer TYPAPPDEM:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete TYPAPPDEM no-error.
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

