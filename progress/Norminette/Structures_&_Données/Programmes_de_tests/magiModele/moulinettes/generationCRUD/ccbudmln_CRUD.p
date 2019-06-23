/*------------------------------------------------------------------------
File        : ccbudmln_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ccbudmln
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ccbudmln.i}
{application/include/error.i}
define variable ghttccbudmln as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phBudget-cd as handle, output phRub-cd as handle, output phCpt-cd as handle, output phAna1-cd as handle, output phAna2-cd as handle, output phAna3-cd as handle, output phAna4-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/budget-cd/rub-cd/cpt-cd/ana1-cd/ana2-cd/ana3-cd/ana4-cd/prd-num, 
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
            when 'ana1-cd' then phAna1-cd = phBuffer:buffer-field(vi).
            when 'ana2-cd' then phAna2-cd = phBuffer:buffer-field(vi).
            when 'ana3-cd' then phAna3-cd = phBuffer:buffer-field(vi).
            when 'ana4-cd' then phAna4-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCcbudmln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCcbudmln.
    run updateCcbudmln.
    run createCcbudmln.
end procedure.

procedure setCcbudmln:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCcbudmln.
    ghttCcbudmln = phttCcbudmln.
    run crudCcbudmln.
    delete object phttCcbudmln.
end procedure.

procedure readCcbudmln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ccbudmln constructin des lignes de budgets mixtes
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcBudget-cd as character  no-undo.
    define input parameter piRub-cd    as integer    no-undo.
    define input parameter pcCpt-cd    as character  no-undo.
    define input parameter pcAna1-cd   as character  no-undo.
    define input parameter pcAna2-cd   as character  no-undo.
    define input parameter pcAna3-cd   as character  no-undo.
    define input parameter pcAna4-cd   as character  no-undo.
    define input parameter table-handle phttCcbudmln.
    define variable vhttBuffer as handle no-undo.
    define buffer ccbudmln for ccbudmln.

    vhttBuffer = phttCcbudmln:default-buffer-handle.
    for first ccbudmln no-lock
        where ccbudmln.soc-cd = piSoc-cd
          and ccbudmln.etab-cd = piEtab-cd
          and ccbudmln.budget-cd = pcBudget-cd
          and ccbudmln.rub-cd = piRub-cd
          and ccbudmln.cpt-cd = pcCpt-cd
          and ccbudmln.ana1-cd = pcAna1-cd
          and ccbudmln.ana2-cd = pcAna2-cd
          and ccbudmln.ana3-cd = pcAna3-cd
          and ccbudmln.ana4-cd = pcAna4-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ccbudmln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCcbudmln no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCcbudmln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ccbudmln constructin des lignes de budgets mixtes
    Notes  : service externe. Critère pcAna4-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcBudget-cd as character  no-undo.
    define input parameter piRub-cd    as integer    no-undo.
    define input parameter pcCpt-cd    as character  no-undo.
    define input parameter pcAna1-cd   as character  no-undo.
    define input parameter pcAna2-cd   as character  no-undo.
    define input parameter pcAna3-cd   as character  no-undo.
    define input parameter pcAna4-cd   as character  no-undo.
    define input parameter table-handle phttCcbudmln.
    define variable vhttBuffer as handle  no-undo.
    define buffer ccbudmln for ccbudmln.

    vhttBuffer = phttCcbudmln:default-buffer-handle.
    if pcAna4-cd = ?
    then for each ccbudmln no-lock
        where ccbudmln.soc-cd = piSoc-cd
          and ccbudmln.etab-cd = piEtab-cd
          and ccbudmln.budget-cd = pcBudget-cd
          and ccbudmln.rub-cd = piRub-cd
          and ccbudmln.cpt-cd = pcCpt-cd
          and ccbudmln.ana1-cd = pcAna1-cd
          and ccbudmln.ana2-cd = pcAna2-cd
          and ccbudmln.ana3-cd = pcAna3-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ccbudmln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ccbudmln no-lock
        where ccbudmln.soc-cd = piSoc-cd
          and ccbudmln.etab-cd = piEtab-cd
          and ccbudmln.budget-cd = pcBudget-cd
          and ccbudmln.rub-cd = piRub-cd
          and ccbudmln.cpt-cd = pcCpt-cd
          and ccbudmln.ana1-cd = pcAna1-cd
          and ccbudmln.ana2-cd = pcAna2-cd
          and ccbudmln.ana3-cd = pcAna3-cd
          and ccbudmln.ana4-cd = pcAna4-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ccbudmln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCcbudmln no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCcbudmln private:
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
    define variable vhAna1-cd    as handle  no-undo.
    define variable vhAna2-cd    as handle  no-undo.
    define variable vhAna3-cd    as handle  no-undo.
    define variable vhAna4-cd    as handle  no-undo.
    define buffer ccbudmln for ccbudmln.

    create query vhttquery.
    vhttBuffer = ghttCcbudmln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCcbudmln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhBudget-cd, output vhRub-cd, output vhCpt-cd, output vhAna1-cd, output vhAna2-cd, output vhAna3-cd, output vhAna4-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ccbudmln exclusive-lock
                where rowid(ccbudmln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ccbudmln:handle, 'soc-cd/etab-cd/budget-cd/rub-cd/cpt-cd/ana1-cd/ana2-cd/ana3-cd/ana4-cd/prd-num: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhBudget-cd:buffer-value(), vhRub-cd:buffer-value(), vhCpt-cd:buffer-value(), vhAna1-cd:buffer-value(), vhAna2-cd:buffer-value(), vhAna3-cd:buffer-value(), vhAna4-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ccbudmln:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCcbudmln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ccbudmln for ccbudmln.

    create query vhttquery.
    vhttBuffer = ghttCcbudmln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCcbudmln:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ccbudmln.
            if not outils:copyValidField(buffer ccbudmln:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCcbudmln private:
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
    define variable vhAna1-cd    as handle  no-undo.
    define variable vhAna2-cd    as handle  no-undo.
    define variable vhAna3-cd    as handle  no-undo.
    define variable vhAna4-cd    as handle  no-undo.
    define buffer ccbudmln for ccbudmln.

    create query vhttquery.
    vhttBuffer = ghttCcbudmln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCcbudmln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhBudget-cd, output vhRub-cd, output vhCpt-cd, output vhAna1-cd, output vhAna2-cd, output vhAna3-cd, output vhAna4-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ccbudmln exclusive-lock
                where rowid(Ccbudmln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ccbudmln:handle, 'soc-cd/etab-cd/budget-cd/rub-cd/cpt-cd/ana1-cd/ana2-cd/ana3-cd/ana4-cd/prd-num: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhBudget-cd:buffer-value(), vhRub-cd:buffer-value(), vhCpt-cd:buffer-value(), vhAna1-cd:buffer-value(), vhAna2-cd:buffer-value(), vhAna3-cd:buffer-value(), vhAna4-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ccbudmln no-error.
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

