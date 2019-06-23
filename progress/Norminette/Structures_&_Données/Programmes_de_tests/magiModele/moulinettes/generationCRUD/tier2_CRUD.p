/*------------------------------------------------------------------------
File        : tier2_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table tier2
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/tier2.i}
{application/include/error.i}
define variable ghtttier2 as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNotie as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur notie, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'notie' then phNotie = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTier2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTier2.
    run updateTier2.
    run createTier2.
end procedure.

procedure setTier2:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTier2.
    ghttTier2 = phttTier2.
    run crudTier2.
    delete object phttTier2.
end procedure.

procedure readTier2:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table tier2 complément information tiers
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNotie as int64      no-undo.
    define input parameter table-handle phttTier2.
    define variable vhttBuffer as handle no-undo.
    define buffer tier2 for tier2.

    vhttBuffer = phttTier2:default-buffer-handle.
    for first tier2 no-lock
        where tier2.notie = piNotie:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tier2:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTier2 no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTier2:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table tier2 complément information tiers
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTier2.
    define variable vhttBuffer as handle  no-undo.
    define buffer tier2 for tier2.

    vhttBuffer = phttTier2:default-buffer-handle.
    for each tier2 no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tier2:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTier2 no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTier2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNotie    as handle  no-undo.
    define buffer tier2 for tier2.

    create query vhttquery.
    vhttBuffer = ghttTier2:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTier2:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNotie).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tier2 exclusive-lock
                where rowid(tier2) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tier2:handle, 'notie: ', substitute('&1', vhNotie:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer tier2:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTier2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer tier2 for tier2.

    create query vhttquery.
    vhttBuffer = ghttTier2:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTier2:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create tier2.
            if not outils:copyValidField(buffer tier2:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTier2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNotie    as handle  no-undo.
    define buffer tier2 for tier2.

    create query vhttquery.
    vhttBuffer = ghttTier2:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTier2:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNotie).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tier2 exclusive-lock
                where rowid(Tier2) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tier2:handle, 'notie: ', substitute('&1', vhNotie:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete tier2 no-error.
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

