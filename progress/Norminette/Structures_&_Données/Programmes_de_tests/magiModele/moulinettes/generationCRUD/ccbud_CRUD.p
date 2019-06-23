/*------------------------------------------------------------------------
File        : ccbud_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ccbud
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ccbud.i}
{application/include/error.i}
define variable ghttccbud as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phBudget-cd as handle, output phRub-cd as handle, output phCpt-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/budget-cd/rub-cd/cpt-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'budget-cd' then phBudget-cd = phBuffer:buffer-field(vi).
            when 'rub-cd' then phRub-cd = phBuffer:buffer-field(vi).
            when 'cpt-cd' then phCpt-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCcbud private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCcbud.
    run updateCcbud.
    run createCcbud.
end procedure.

procedure setCcbud:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCcbud.
    ghttCcbud = phttCcbud.
    run crudCcbud.
    delete object phttCcbud.
end procedure.

procedure readCcbud:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ccbud Construction budget general
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcBudget-cd as character  no-undo.
    define input parameter piRub-cd    as integer    no-undo.
    define input parameter pcCpt-cd    as character  no-undo.
    define input parameter table-handle phttCcbud.
    define variable vhttBuffer as handle no-undo.
    define buffer ccbud for ccbud.

    vhttBuffer = phttCcbud:default-buffer-handle.
    for first ccbud no-lock
        where ccbud.soc-cd = piSoc-cd
          and ccbud.etab-cd = piEtab-cd
          and ccbud.budget-cd = pcBudget-cd
          and ccbud.rub-cd = piRub-cd
          and ccbud.cpt-cd = pcCpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ccbud:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCcbud no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCcbud:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ccbud Construction budget general
    Notes  : service externe. Critère piRub-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcBudget-cd as character  no-undo.
    define input parameter piRub-cd    as integer    no-undo.
    define input parameter table-handle phttCcbud.
    define variable vhttBuffer as handle  no-undo.
    define buffer ccbud for ccbud.

    vhttBuffer = phttCcbud:default-buffer-handle.
    if piRub-cd = ?
    then for each ccbud no-lock
        where ccbud.soc-cd = piSoc-cd
          and ccbud.etab-cd = piEtab-cd
          and ccbud.budget-cd = pcBudget-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ccbud:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ccbud no-lock
        where ccbud.soc-cd = piSoc-cd
          and ccbud.etab-cd = piEtab-cd
          and ccbud.budget-cd = pcBudget-cd
          and ccbud.rub-cd = piRub-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ccbud:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCcbud no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCcbud private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhBudget-cd    as handle  no-undo.
    define variable vhRub-cd    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer ccbud for ccbud.

    create query vhttquery.
    vhttBuffer = ghttCcbud:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCcbud:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhBudget-cd, output vhRub-cd, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ccbud exclusive-lock
                where rowid(ccbud) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ccbud:handle, 'soc-cd/etab-cd/budget-cd/rub-cd/cpt-cd: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhBudget-cd:buffer-value(), vhRub-cd:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ccbud:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCcbud private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ccbud for ccbud.

    create query vhttquery.
    vhttBuffer = ghttCcbud:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCcbud:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ccbud.
            if not outils:copyValidField(buffer ccbud:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCcbud private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhBudget-cd    as handle  no-undo.
    define variable vhRub-cd    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer ccbud for ccbud.

    create query vhttquery.
    vhttBuffer = ghttCcbud:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCcbud:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhBudget-cd, output vhRub-cd, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ccbud exclusive-lock
                where rowid(Ccbud) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ccbud:handle, 'soc-cd/etab-cd/budget-cd/rub-cd/cpt-cd: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhBudget-cd:buffer-value(), vhRub-cd:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ccbud no-error.
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

