/*------------------------------------------------------------------------
File        : rubqt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table rubqt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/rubqt.i}
{application/include/error.i}
define variable ghttrubqt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdrub as handle, output phCdlib as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cdrub/cdlib, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cdrub' then phCdrub = phBuffer:buffer-field(vi).
            when 'cdlib' then phCdlib = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudRubqt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteRubqt.
    run updateRubqt.
    run createRubqt.
end procedure.

procedure setRubqt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRubqt.
    ghttRubqt = phttRubqt.
    run crudRubqt.
    delete object phttRubqt.
end procedure.

procedure readRubqt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table rubqt 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piCdrub as integer    no-undo.
    define input parameter piCdlib as integer    no-undo.
    define input parameter table-handle phttRubqt.
    define variable vhttBuffer as handle no-undo.
    define buffer rubqt for rubqt.

    vhttBuffer = phttRubqt:default-buffer-handle.
    for first rubqt no-lock
        where rubqt.cdrub = piCdrub
          and rubqt.cdlib = piCdlib:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer rubqt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRubqt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getRubqt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table rubqt 
    Notes  : service externe. Critère piCdrub = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piCdrub as integer    no-undo.
    define input parameter table-handle phttRubqt.
    define variable vhttBuffer as handle  no-undo.
    define buffer rubqt for rubqt.

    vhttBuffer = phttRubqt:default-buffer-handle.
    if piCdrub = ?
    then for each rubqt no-lock
        where rubqt.cdrub = piCdrub:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer rubqt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each rubqt no-lock
        where rubqt.cdrub = piCdrub:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer rubqt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRubqt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateRubqt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdrub    as handle  no-undo.
    define variable vhCdlib    as handle  no-undo.
    define buffer rubqt for rubqt.

    create query vhttquery.
    vhttBuffer = ghttRubqt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttRubqt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdrub, output vhCdlib).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first rubqt exclusive-lock
                where rowid(rubqt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer rubqt:handle, 'cdrub/cdlib: ', substitute('&1/&2', vhCdrub:buffer-value(), vhCdlib:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer rubqt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createRubqt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer rubqt for rubqt.

    create query vhttquery.
    vhttBuffer = ghttRubqt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttRubqt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create rubqt.
            if not outils:copyValidField(buffer rubqt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteRubqt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdrub    as handle  no-undo.
    define variable vhCdlib    as handle  no-undo.
    define buffer rubqt for rubqt.

    create query vhttquery.
    vhttBuffer = ghttRubqt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttRubqt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdrub, output vhCdlib).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first rubqt exclusive-lock
                where rowid(Rubqt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer rubqt:handle, 'cdrub/cdlib: ', substitute('&1/&2', vhCdrub:buffer-value(), vhCdlib:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete rubqt no-error.
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

