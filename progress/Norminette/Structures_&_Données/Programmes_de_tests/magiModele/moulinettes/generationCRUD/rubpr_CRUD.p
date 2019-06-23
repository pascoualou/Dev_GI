/*------------------------------------------------------------------------
File        : rubpr_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table rubpr
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/rubpr.i}
{application/include/error.i}
define variable ghttrubpr as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phModul as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur modul, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'modul' then phModul = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudRubpr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteRubpr.
    run updateRubpr.
    run createRubpr.
end procedure.

procedure setRubpr:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRubpr.
    ghttRubpr = phttRubpr.
    run crudRubpr.
    delete object phttRubpr.
end procedure.

procedure readRubpr:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table rubpr paramétrage des modules du calcul
de la Paie concierge
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcModul as character  no-undo.
    define input parameter table-handle phttRubpr.
    define variable vhttBuffer as handle no-undo.
    define buffer rubpr for rubpr.

    vhttBuffer = phttRubpr:default-buffer-handle.
    for first rubpr no-lock
        where rubpr.modul = pcModul:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer rubpr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRubpr no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getRubpr:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table rubpr paramétrage des modules du calcul
de la Paie concierge
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRubpr.
    define variable vhttBuffer as handle  no-undo.
    define buffer rubpr for rubpr.

    vhttBuffer = phttRubpr:default-buffer-handle.
    for each rubpr no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer rubpr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRubpr no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateRubpr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhModul    as handle  no-undo.
    define buffer rubpr for rubpr.

    create query vhttquery.
    vhttBuffer = ghttRubpr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttRubpr:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhModul).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first rubpr exclusive-lock
                where rowid(rubpr) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer rubpr:handle, 'modul: ', substitute('&1', vhModul:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer rubpr:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createRubpr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer rubpr for rubpr.

    create query vhttquery.
    vhttBuffer = ghttRubpr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttRubpr:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create rubpr.
            if not outils:copyValidField(buffer rubpr:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteRubpr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhModul    as handle  no-undo.
    define buffer rubpr for rubpr.

    create query vhttquery.
    vhttBuffer = ghttRubpr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttRubpr:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhModul).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first rubpr exclusive-lock
                where rowid(Rubpr) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer rubpr:handle, 'modul: ', substitute('&1', vhModul:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete rubpr no-error.
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

