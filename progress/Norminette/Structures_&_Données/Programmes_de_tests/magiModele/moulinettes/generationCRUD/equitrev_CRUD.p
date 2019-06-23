/*------------------------------------------------------------------------
File        : equitrev_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table equitrev
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/equitrev.i}
{application/include/error.i}
define variable ghttequitrev as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoloc as handle, output phNoord as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noloc/noord, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noloc' then phNoloc = phBuffer:buffer-field(vi).
            when 'noord' then phNoord = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudEquitrev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteEquitrev.
    run updateEquitrev.
    run createEquitrev.
end procedure.

procedure setEquitrev:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEquitrev.
    ghttEquitrev = phttEquitrev.
    run crudEquitrev.
    delete object phttEquitrev.
end procedure.

procedure readEquitrev:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table equitrev 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pdeNoloc as decimal    no-undo.
    define input parameter piNoord as integer    no-undo.
    define input parameter table-handle phttEquitrev.
    define variable vhttBuffer as handle no-undo.
    define buffer equitrev for equitrev.

    vhttBuffer = phttEquitrev:default-buffer-handle.
    for first equitrev no-lock
        where equitrev.noloc = pdeNoloc
          and equitrev.noord = piNoord:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer equitrev:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEquitrev no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getEquitrev:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table equitrev 
    Notes  : service externe. Critère pdeNoloc = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pdeNoloc as decimal    no-undo.
    define input parameter table-handle phttEquitrev.
    define variable vhttBuffer as handle  no-undo.
    define buffer equitrev for equitrev.

    vhttBuffer = phttEquitrev:default-buffer-handle.
    if pdeNoloc = ?
    then for each equitrev no-lock
        where equitrev.noloc = pdeNoloc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer equitrev:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each equitrev no-lock
        where equitrev.noloc = pdeNoloc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer equitrev:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEquitrev no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateEquitrev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoloc    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer equitrev for equitrev.

    create query vhttquery.
    vhttBuffer = ghttEquitrev:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttEquitrev:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoloc, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first equitrev exclusive-lock
                where rowid(equitrev) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer equitrev:handle, 'noloc/noord: ', substitute('&1/&2', vhNoloc:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer equitrev:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createEquitrev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer equitrev for equitrev.

    create query vhttquery.
    vhttBuffer = ghttEquitrev:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttEquitrev:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create equitrev.
            if not outils:copyValidField(buffer equitrev:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteEquitrev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoloc    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer equitrev for equitrev.

    create query vhttquery.
    vhttBuffer = ghttEquitrev:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttEquitrev:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoloc, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first equitrev exclusive-lock
                where rowid(Equitrev) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer equitrev:handle, 'noloc/noord: ', substitute('&1/&2', vhNoloc:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete equitrev no-error.
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

