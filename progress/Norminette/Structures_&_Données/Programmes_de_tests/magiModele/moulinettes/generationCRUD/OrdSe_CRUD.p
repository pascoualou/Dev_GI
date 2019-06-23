/*------------------------------------------------------------------------
File        : OrdSe_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table OrdSe
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/OrdSe.i}
{application/include/error.i}
define variable ghttOrdSe as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoord as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur NoOrd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'NoOrd' then phNoord = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudOrdse private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteOrdse.
    run updateOrdse.
    run createOrdse.
end procedure.

procedure setOrdse:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttOrdse.
    ghttOrdse = phttOrdse.
    run crudOrdse.
    delete object phttOrdse.
end procedure.

procedure readOrdse:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table OrdSe Chaine Travaux : Table des Ordres de Service
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoord as integer    no-undo.
    define input parameter table-handle phttOrdse.
    define variable vhttBuffer as handle no-undo.
    define buffer OrdSe for OrdSe.

    vhttBuffer = phttOrdse:default-buffer-handle.
    for first OrdSe no-lock
        where OrdSe.NoOrd = piNoord:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer OrdSe:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttOrdse no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getOrdse:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table OrdSe Chaine Travaux : Table des Ordres de Service
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttOrdse.
    define variable vhttBuffer as handle  no-undo.
    define buffer OrdSe for OrdSe.

    vhttBuffer = phttOrdse:default-buffer-handle.
    for each OrdSe no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer OrdSe:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttOrdse no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateOrdse private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer OrdSe for OrdSe.

    create query vhttquery.
    vhttBuffer = ghttOrdse:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttOrdse:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first OrdSe exclusive-lock
                where rowid(OrdSe) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer OrdSe:handle, 'NoOrd: ', substitute('&1', vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer OrdSe:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createOrdse private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer OrdSe for OrdSe.

    create query vhttquery.
    vhttBuffer = ghttOrdse:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttOrdse:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create OrdSe.
            if not outils:copyValidField(buffer OrdSe:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteOrdse private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer OrdSe for OrdSe.

    create query vhttquery.
    vhttBuffer = ghttOrdse:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttOrdse:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first OrdSe exclusive-lock
                where rowid(Ordse) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer OrdSe:handle, 'NoOrd: ', substitute('&1', vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete OrdSe no-error.
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

