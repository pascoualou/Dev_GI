/*------------------------------------------------------------------------
File        : igedplan_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table igedplan
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/igedplan.i}
{application/include/error.i}
define variable ghttigedplan as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phPlan-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur plan-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'plan-cd' then phPlan-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIgedplan private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIgedplan.
    run updateIgedplan.
    run createIgedplan.
end procedure.

procedure setIgedplan:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIgedplan.
    ghttIgedplan = phttIgedplan.
    run crudIgedplan.
    delete object phttIgedplan.
end procedure.

procedure readIgedplan:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table igedplan 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcPlan-cd as character  no-undo.
    define input parameter table-handle phttIgedplan.
    define variable vhttBuffer as handle no-undo.
    define buffer igedplan for igedplan.

    vhttBuffer = phttIgedplan:default-buffer-handle.
    for first igedplan no-lock
        where igedplan.plan-cd = pcPlan-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer igedplan:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIgedplan no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIgedplan:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table igedplan 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIgedplan.
    define variable vhttBuffer as handle  no-undo.
    define buffer igedplan for igedplan.

    vhttBuffer = phttIgedplan:default-buffer-handle.
    for each igedplan no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer igedplan:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIgedplan no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIgedplan private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhPlan-cd    as handle  no-undo.
    define buffer igedplan for igedplan.

    create query vhttquery.
    vhttBuffer = ghttIgedplan:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIgedplan:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhPlan-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first igedplan exclusive-lock
                where rowid(igedplan) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer igedplan:handle, 'plan-cd: ', substitute('&1', vhPlan-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer igedplan:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIgedplan private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer igedplan for igedplan.

    create query vhttquery.
    vhttBuffer = ghttIgedplan:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIgedplan:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create igedplan.
            if not outils:copyValidField(buffer igedplan:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIgedplan private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhPlan-cd    as handle  no-undo.
    define buffer igedplan for igedplan.

    create query vhttquery.
    vhttBuffer = ghttIgedplan:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIgedplan:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhPlan-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first igedplan exclusive-lock
                where rowid(Igedplan) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer igedplan:handle, 'plan-cd: ', substitute('&1', vhPlan-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete igedplan no-error.
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

