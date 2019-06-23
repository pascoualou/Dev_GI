/*------------------------------------------------------------------------
File        : CHAMP_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table CHAMP
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/CHAMP.i}
{application/include/error.i}
define variable ghttCHAMP as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNochp as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nochp, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nochp' then phNochp = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudChamp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteChamp.
    run updateChamp.
    run createChamp.
end procedure.

procedure setChamp:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttChamp.
    ghttChamp = phttChamp.
    run crudChamp.
    delete object phttChamp.
end procedure.

procedure readChamp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table CHAMP Champ
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNochp as integer    no-undo.
    define input parameter table-handle phttChamp.
    define variable vhttBuffer as handle no-undo.
    define buffer CHAMP for CHAMP.

    vhttBuffer = phttChamp:default-buffer-handle.
    for first CHAMP no-lock
        where CHAMP.nochp = piNochp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer CHAMP:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttChamp no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getChamp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table CHAMP Champ
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttChamp.
    define variable vhttBuffer as handle  no-undo.
    define buffer CHAMP for CHAMP.

    vhttBuffer = phttChamp:default-buffer-handle.
    for each CHAMP no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer CHAMP:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttChamp no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateChamp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNochp    as handle  no-undo.
    define buffer CHAMP for CHAMP.

    create query vhttquery.
    vhttBuffer = ghttChamp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttChamp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNochp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first CHAMP exclusive-lock
                where rowid(CHAMP) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer CHAMP:handle, 'nochp: ', substitute('&1', vhNochp:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer CHAMP:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createChamp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer CHAMP for CHAMP.

    create query vhttquery.
    vhttBuffer = ghttChamp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttChamp:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create CHAMP.
            if not outils:copyValidField(buffer CHAMP:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteChamp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNochp    as handle  no-undo.
    define buffer CHAMP for CHAMP.

    create query vhttquery.
    vhttBuffer = ghttChamp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttChamp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNochp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first CHAMP exclusive-lock
                where rowid(Champ) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer CHAMP:handle, 'nochp: ', substitute('&1', vhNochp:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete CHAMP no-error.
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

