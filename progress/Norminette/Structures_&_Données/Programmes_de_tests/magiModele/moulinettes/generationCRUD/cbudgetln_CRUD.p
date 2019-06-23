/*------------------------------------------------------------------------
File        : cbudgetln_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cbudgetln
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cbudgetln.i}
{application/include/error.i}
define variable ghttcbudgetln as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phBudget-cd as handle, output phRub-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/budget-cd/rub-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'budget-cd' then phBudget-cd = phBuffer:buffer-field(vi).
            when 'rub-cd' then phRub-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCbudgetln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCbudgetln.
    run updateCbudgetln.
    run createCbudgetln.
end procedure.

procedure setCbudgetln:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCbudgetln.
    ghttCbudgetln = phttCbudgetln.
    run crudCbudgetln.
    delete object phttCbudgetln.
end procedure.

procedure readCbudgetln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cbudgetln fichier detail budgets
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcBudget-cd as character  no-undo.
    define input parameter piRub-cd    as integer    no-undo.
    define input parameter table-handle phttCbudgetln.
    define variable vhttBuffer as handle no-undo.
    define buffer cbudgetln for cbudgetln.

    vhttBuffer = phttCbudgetln:default-buffer-handle.
    for first cbudgetln no-lock
        where cbudgetln.soc-cd = piSoc-cd
          and cbudgetln.etab-cd = piEtab-cd
          and cbudgetln.budget-cd = pcBudget-cd
          and cbudgetln.rub-cd = piRub-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbudgetln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCbudgetln no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCbudgetln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cbudgetln fichier detail budgets
    Notes  : service externe. Critère pcBudget-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcBudget-cd as character  no-undo.
    define input parameter table-handle phttCbudgetln.
    define variable vhttBuffer as handle  no-undo.
    define buffer cbudgetln for cbudgetln.

    vhttBuffer = phttCbudgetln:default-buffer-handle.
    if pcBudget-cd = ?
    then for each cbudgetln no-lock
        where cbudgetln.soc-cd = piSoc-cd
          and cbudgetln.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbudgetln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cbudgetln no-lock
        where cbudgetln.soc-cd = piSoc-cd
          and cbudgetln.etab-cd = piEtab-cd
          and cbudgetln.budget-cd = pcBudget-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbudgetln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCbudgetln no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCbudgetln private:
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
    define buffer cbudgetln for cbudgetln.

    create query vhttquery.
    vhttBuffer = ghttCbudgetln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCbudgetln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhBudget-cd, output vhRub-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cbudgetln exclusive-lock
                where rowid(cbudgetln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cbudgetln:handle, 'soc-cd/etab-cd/budget-cd/rub-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhBudget-cd:buffer-value(), vhRub-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cbudgetln:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCbudgetln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cbudgetln for cbudgetln.

    create query vhttquery.
    vhttBuffer = ghttCbudgetln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCbudgetln:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cbudgetln.
            if not outils:copyValidField(buffer cbudgetln:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCbudgetln private:
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
    define buffer cbudgetln for cbudgetln.

    create query vhttquery.
    vhttBuffer = ghttCbudgetln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCbudgetln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhBudget-cd, output vhRub-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cbudgetln exclusive-lock
                where rowid(Cbudgetln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cbudgetln:handle, 'soc-cd/etab-cd/budget-cd/rub-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhBudget-cd:buffer-value(), vhRub-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cbudgetln no-error.
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

