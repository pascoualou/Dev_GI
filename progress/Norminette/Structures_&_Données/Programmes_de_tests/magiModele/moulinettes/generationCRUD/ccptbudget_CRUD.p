/*------------------------------------------------------------------------
File        : ccptbudget_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ccptbudget
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ccptbudget.i}
{application/include/error.i}
define variable ghttccptbudget as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phBudget-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/budget-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'budget-cle' then phBudget-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCcptbudget private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCcptbudget.
    run updateCcptbudget.
    run createCcptbudget.
end procedure.

procedure setCcptbudget:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCcptbudget.
    ghttCcptbudget = phttCcptbudget.
    run crudCcptbudget.
    delete object phttCcptbudget.
end procedure.

procedure readCcptbudget:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ccptbudget Fichier codes &/ou Comptes Budgetaires
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter piBudget-cle as integer    no-undo.
    define input parameter table-handle phttCcptbudget.
    define variable vhttBuffer as handle no-undo.
    define buffer ccptbudget for ccptbudget.

    vhttBuffer = phttCcptbudget:default-buffer-handle.
    for first ccptbudget no-lock
        where ccptbudget.soc-cd = piSoc-cd
          and ccptbudget.etab-cd = piEtab-cd
          and ccptbudget.budget-cle = piBudget-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ccptbudget:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCcptbudget no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCcptbudget:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ccptbudget Fichier codes &/ou Comptes Budgetaires
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter table-handle phttCcptbudget.
    define variable vhttBuffer as handle  no-undo.
    define buffer ccptbudget for ccptbudget.

    vhttBuffer = phttCcptbudget:default-buffer-handle.
    if piEtab-cd = ?
    then for each ccptbudget no-lock
        where ccptbudget.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ccptbudget:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ccptbudget no-lock
        where ccptbudget.soc-cd = piSoc-cd
          and ccptbudget.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ccptbudget:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCcptbudget no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCcptbudget private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhBudget-cle    as handle  no-undo.
    define buffer ccptbudget for ccptbudget.

    create query vhttquery.
    vhttBuffer = ghttCcptbudget:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCcptbudget:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhBudget-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ccptbudget exclusive-lock
                where rowid(ccptbudget) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ccptbudget:handle, 'soc-cd/etab-cd/budget-cle: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhBudget-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ccptbudget:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCcptbudget private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ccptbudget for ccptbudget.

    create query vhttquery.
    vhttBuffer = ghttCcptbudget:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCcptbudget:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ccptbudget.
            if not outils:copyValidField(buffer ccptbudget:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCcptbudget private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhBudget-cle    as handle  no-undo.
    define buffer ccptbudget for ccptbudget.

    create query vhttquery.
    vhttBuffer = ghttCcptbudget:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCcptbudget:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhBudget-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ccptbudget exclusive-lock
                where rowid(Ccptbudget) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ccptbudget:handle, 'soc-cd/etab-cd/budget-cle: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhBudget-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ccptbudget no-error.
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

