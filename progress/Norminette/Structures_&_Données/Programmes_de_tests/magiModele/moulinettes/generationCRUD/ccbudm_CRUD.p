/*------------------------------------------------------------------------
File        : ccbudm_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ccbudm
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ccbudm.i}
{application/include/error.i}
define variable ghttccbudm as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phBudget-cd as handle, output phRub-cd as handle, output phCpt-cd as handle, output phAna1-cd as handle, output phAna2-cd as handle, output phAna3-cd as handle, output phAna4-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/budget-cd/rub-cd/cpt-cd/ana1-cd/ana2-cd/ana3-cd/ana4-cd, 
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

procedure crudCcbudm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCcbudm.
    run updateCcbudm.
    run createCcbudm.
end procedure.

procedure setCcbudm:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCcbudm.
    ghttCcbudm = phttCcbudm.
    run crudCcbudm.
    delete object phttCcbudm.
end procedure.

procedure readCcbudm:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ccbudm construction des budgets mixtes
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
    define input parameter table-handle phttCcbudm.
    define variable vhttBuffer as handle no-undo.
    define buffer ccbudm for ccbudm.

    vhttBuffer = phttCcbudm:default-buffer-handle.
    for first ccbudm no-lock
        where ccbudm.soc-cd = piSoc-cd
          and ccbudm.etab-cd = piEtab-cd
          and ccbudm.budget-cd = pcBudget-cd
          and ccbudm.rub-cd = piRub-cd
          and ccbudm.cpt-cd = pcCpt-cd
          and ccbudm.ana1-cd = pcAna1-cd
          and ccbudm.ana2-cd = pcAna2-cd
          and ccbudm.ana3-cd = pcAna3-cd
          and ccbudm.ana4-cd = pcAna4-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ccbudm:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCcbudm no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCcbudm:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ccbudm construction des budgets mixtes
    Notes  : service externe. Critère pcAna3-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcBudget-cd as character  no-undo.
    define input parameter piRub-cd    as integer    no-undo.
    define input parameter pcCpt-cd    as character  no-undo.
    define input parameter pcAna1-cd   as character  no-undo.
    define input parameter pcAna2-cd   as character  no-undo.
    define input parameter pcAna3-cd   as character  no-undo.
    define input parameter table-handle phttCcbudm.
    define variable vhttBuffer as handle  no-undo.
    define buffer ccbudm for ccbudm.

    vhttBuffer = phttCcbudm:default-buffer-handle.
    if pcAna3-cd = ?
    then for each ccbudm no-lock
        where ccbudm.soc-cd = piSoc-cd
          and ccbudm.etab-cd = piEtab-cd
          and ccbudm.budget-cd = pcBudget-cd
          and ccbudm.rub-cd = piRub-cd
          and ccbudm.cpt-cd = pcCpt-cd
          and ccbudm.ana1-cd = pcAna1-cd
          and ccbudm.ana2-cd = pcAna2-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ccbudm:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ccbudm no-lock
        where ccbudm.soc-cd = piSoc-cd
          and ccbudm.etab-cd = piEtab-cd
          and ccbudm.budget-cd = pcBudget-cd
          and ccbudm.rub-cd = piRub-cd
          and ccbudm.cpt-cd = pcCpt-cd
          and ccbudm.ana1-cd = pcAna1-cd
          and ccbudm.ana2-cd = pcAna2-cd
          and ccbudm.ana3-cd = pcAna3-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ccbudm:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCcbudm no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCcbudm private:
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
    define buffer ccbudm for ccbudm.

    create query vhttquery.
    vhttBuffer = ghttCcbudm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCcbudm:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhBudget-cd, output vhRub-cd, output vhCpt-cd, output vhAna1-cd, output vhAna2-cd, output vhAna3-cd, output vhAna4-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ccbudm exclusive-lock
                where rowid(ccbudm) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ccbudm:handle, 'soc-cd/etab-cd/budget-cd/rub-cd/cpt-cd/ana1-cd/ana2-cd/ana3-cd/ana4-cd: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhBudget-cd:buffer-value(), vhRub-cd:buffer-value(), vhCpt-cd:buffer-value(), vhAna1-cd:buffer-value(), vhAna2-cd:buffer-value(), vhAna3-cd:buffer-value(), vhAna4-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ccbudm:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCcbudm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ccbudm for ccbudm.

    create query vhttquery.
    vhttBuffer = ghttCcbudm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCcbudm:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ccbudm.
            if not outils:copyValidField(buffer ccbudm:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCcbudm private:
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
    define buffer ccbudm for ccbudm.

    create query vhttquery.
    vhttBuffer = ghttCcbudm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCcbudm:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhBudget-cd, output vhRub-cd, output vhCpt-cd, output vhAna1-cd, output vhAna2-cd, output vhAna3-cd, output vhAna4-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ccbudm exclusive-lock
                where rowid(Ccbudm) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ccbudm:handle, 'soc-cd/etab-cd/budget-cd/rub-cd/cpt-cd/ana1-cd/ana2-cd/ana3-cd/ana4-cd: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhBudget-cd:buffer-value(), vhRub-cd:buffer-value(), vhCpt-cd:buffer-value(), vhAna1-cd:buffer-value(), vhAna2-cd:buffer-value(), vhAna3-cd:buffer-value(), vhAna4-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ccbudm no-error.
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

