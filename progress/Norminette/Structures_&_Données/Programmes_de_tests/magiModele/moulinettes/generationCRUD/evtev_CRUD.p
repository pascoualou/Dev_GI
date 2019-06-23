/*------------------------------------------------------------------------
File        : evtev_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table evtev
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/evtev.i}
{application/include/error.i}
define variable ghttevtev as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoev1 as handle, output phNoev2 as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noev1/noev2, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noev1' then phNoev1 = phBuffer:buffer-field(vi).
            when 'noev2' then phNoev2 = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudEvtev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteEvtev.
    run updateEvtev.
    run createEvtev.
end procedure.

procedure setEvtev:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEvtev.
    ghttEvtev = phttEvtev.
    run crudEvtev.
    delete object phttEvtev.
end procedure.

procedure readEvtev:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table evtev Liens évènement-évènement
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoev1 as int64      no-undo.
    define input parameter piNoev2 as int64      no-undo.
    define input parameter table-handle phttEvtev.
    define variable vhttBuffer as handle no-undo.
    define buffer evtev for evtev.

    vhttBuffer = phttEvtev:default-buffer-handle.
    for first evtev no-lock
        where evtev.noev1 = piNoev1
          and evtev.noev2 = piNoev2:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer evtev:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEvtev no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getEvtev:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table evtev Liens évènement-évènement
    Notes  : service externe. Critère piNoev1 = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoev1 as int64      no-undo.
    define input parameter table-handle phttEvtev.
    define variable vhttBuffer as handle  no-undo.
    define buffer evtev for evtev.

    vhttBuffer = phttEvtev:default-buffer-handle.
    if piNoev1 = ?
    then for each evtev no-lock
        where evtev.noev1 = piNoev1:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer evtev:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each evtev no-lock
        where evtev.noev1 = piNoev1:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer evtev:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEvtev no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateEvtev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoev1    as handle  no-undo.
    define variable vhNoev2    as handle  no-undo.
    define buffer evtev for evtev.

    create query vhttquery.
    vhttBuffer = ghttEvtev:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttEvtev:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoev1, output vhNoev2).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first evtev exclusive-lock
                where rowid(evtev) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer evtev:handle, 'noev1/noev2: ', substitute('&1/&2', vhNoev1:buffer-value(), vhNoev2:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer evtev:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createEvtev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer evtev for evtev.

    create query vhttquery.
    vhttBuffer = ghttEvtev:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttEvtev:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create evtev.
            if not outils:copyValidField(buffer evtev:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteEvtev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoev1    as handle  no-undo.
    define variable vhNoev2    as handle  no-undo.
    define buffer evtev for evtev.

    create query vhttquery.
    vhttBuffer = ghttEvtev:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttEvtev:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoev1, output vhNoev2).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first evtev exclusive-lock
                where rowid(Evtev) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer evtev:handle, 'noev1/noev2: ', substitute('&1/&2', vhNoev1:buffer-value(), vhNoev2:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete evtev no-error.
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

