/*------------------------------------------------------------------------
File        : DtOrd_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table DtOrd
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/DtOrd.i}
{application/include/error.i}
define variable ghttDtOrd as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoord as handle, output phNoint as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur NoOrd/NoInt, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'NoOrd' then phNoord = phBuffer:buffer-field(vi).
            when 'NoInt' then phNoint = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudDtord private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteDtord.
    run updateDtord.
    run createDtord.
end procedure.

procedure setDtord:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttDtord.
    ghttDtord = phttDtord.
    run crudDtord.
    delete object phttDtord.
end procedure.

procedure readDtord:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table DtOrd Chaine Travaux : Table Détail Ordre de Service
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoord as integer    no-undo.
    define input parameter piNoint as int64      no-undo.
    define input parameter table-handle phttDtord.
    define variable vhttBuffer as handle no-undo.
    define buffer DtOrd for DtOrd.

    vhttBuffer = phttDtord:default-buffer-handle.
    for first DtOrd no-lock
        where DtOrd.NoOrd = piNoord
          and DtOrd.NoInt = piNoint:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DtOrd:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDtord no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getDtord:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table DtOrd Chaine Travaux : Table Détail Ordre de Service
    Notes  : service externe. Critère piNoord = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoord as integer    no-undo.
    define input parameter table-handle phttDtord.
    define variable vhttBuffer as handle  no-undo.
    define buffer DtOrd for DtOrd.

    vhttBuffer = phttDtord:default-buffer-handle.
    if piNoord = ?
    then for each DtOrd no-lock
        where DtOrd.NoOrd = piNoord:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DtOrd:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each DtOrd no-lock
        where DtOrd.NoOrd = piNoord:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DtOrd:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDtord no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateDtord private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoord    as handle  no-undo.
    define variable vhNoint    as handle  no-undo.
    define buffer DtOrd for DtOrd.

    create query vhttquery.
    vhttBuffer = ghttDtord:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttDtord:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoord, output vhNoint).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first DtOrd exclusive-lock
                where rowid(DtOrd) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer DtOrd:handle, 'NoOrd/NoInt: ', substitute('&1/&2', vhNoord:buffer-value(), vhNoint:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer DtOrd:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createDtord private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer DtOrd for DtOrd.

    create query vhttquery.
    vhttBuffer = ghttDtord:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttDtord:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create DtOrd.
            if not outils:copyValidField(buffer DtOrd:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteDtord private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoord    as handle  no-undo.
    define variable vhNoint    as handle  no-undo.
    define buffer DtOrd for DtOrd.

    create query vhttquery.
    vhttBuffer = ghttDtord:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttDtord:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoord, output vhNoint).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first DtOrd exclusive-lock
                where rowid(Dtord) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer DtOrd:handle, 'NoOrd/NoInt: ', substitute('&1/&2', vhNoord:buffer-value(), vhNoint:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete DtOrd no-error.
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

