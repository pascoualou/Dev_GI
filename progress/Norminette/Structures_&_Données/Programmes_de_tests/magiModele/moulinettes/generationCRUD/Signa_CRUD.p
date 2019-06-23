/*------------------------------------------------------------------------
File        : Signa_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table Signa
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/Signa.i}
{application/include/error.i}
define variable ghttSigna as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNosig as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur NoSig, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'NoSig' then phNosig = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSigna private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSigna.
    run updateSigna.
    run createSigna.
end procedure.

procedure setSigna:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSigna.
    ghttSigna = phttSigna.
    run crudSigna.
    delete object phttSigna.
end procedure.

procedure readSigna:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table Signa Chaine Travaux : Table des Signalements
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNosig as integer    no-undo.
    define input parameter table-handle phttSigna.
    define variable vhttBuffer as handle no-undo.
    define buffer Signa for Signa.

    vhttBuffer = phttSigna:default-buffer-handle.
    for first Signa no-lock
        where Signa.NoSig = piNosig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer Signa:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSigna no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSigna:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table Signa Chaine Travaux : Table des Signalements
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSigna.
    define variable vhttBuffer as handle  no-undo.
    define buffer Signa for Signa.

    vhttBuffer = phttSigna:default-buffer-handle.
    for each Signa no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer Signa:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSigna no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSigna private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNosig    as handle  no-undo.
    define buffer Signa for Signa.

    create query vhttquery.
    vhttBuffer = ghttSigna:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSigna:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNosig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first Signa exclusive-lock
                where rowid(Signa) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer Signa:handle, 'NoSig: ', substitute('&1', vhNosig:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer Signa:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSigna private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer Signa for Signa.

    create query vhttquery.
    vhttBuffer = ghttSigna:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSigna:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create Signa.
            if not outils:copyValidField(buffer Signa:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSigna private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNosig    as handle  no-undo.
    define buffer Signa for Signa.

    create query vhttquery.
    vhttBuffer = ghttSigna:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSigna:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNosig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first Signa exclusive-lock
                where rowid(Signa) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer Signa:handle, 'NoSig: ', substitute('&1', vhNosig:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete Signa no-error.
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

