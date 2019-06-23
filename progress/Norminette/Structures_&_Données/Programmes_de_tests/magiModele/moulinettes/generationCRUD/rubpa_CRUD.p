/*------------------------------------------------------------------------
File        : rubpa_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table rubpa
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/rubpa.i}
{application/include/error.i}
define variable ghttrubpa as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdrub as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cdrub, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cdrub' then phCdrub = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudRubpa private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteRubpa.
    run updateRubpa.
    run createRubpa.
end procedure.

procedure setRubpa:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRubpa.
    ghttRubpa = phttRubpa.
    run crudRubpa.
    delete object phttRubpa.
end procedure.

procedure readRubpa:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table rubpa 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piCdrub as integer    no-undo.
    define input parameter table-handle phttRubpa.
    define variable vhttBuffer as handle no-undo.
    define buffer rubpa for rubpa.

    vhttBuffer = phttRubpa:default-buffer-handle.
    for first rubpa no-lock
        where rubpa.cdrub = piCdrub:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer rubpa:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRubpa no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getRubpa:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table rubpa 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRubpa.
    define variable vhttBuffer as handle  no-undo.
    define buffer rubpa for rubpa.

    vhttBuffer = phttRubpa:default-buffer-handle.
    for each rubpa no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer rubpa:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRubpa no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateRubpa private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdrub    as handle  no-undo.
    define buffer rubpa for rubpa.

    create query vhttquery.
    vhttBuffer = ghttRubpa:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttRubpa:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdrub).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first rubpa exclusive-lock
                where rowid(rubpa) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer rubpa:handle, 'cdrub: ', substitute('&1', vhCdrub:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer rubpa:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createRubpa private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer rubpa for rubpa.

    create query vhttquery.
    vhttBuffer = ghttRubpa:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttRubpa:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create rubpa.
            if not outils:copyValidField(buffer rubpa:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteRubpa private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdrub    as handle  no-undo.
    define buffer rubpa for rubpa.

    create query vhttquery.
    vhttBuffer = ghttRubpa:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttRubpa:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdrub).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first rubpa exclusive-lock
                where rowid(Rubpa) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer rubpa:handle, 'cdrub: ', substitute('&1', vhCdrub:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete rubpa no-error.
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

