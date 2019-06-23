/*------------------------------------------------------------------------
File        : pcbudmln_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table pcbudmln
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/pcbudmln.i}
{application/include/error.i}
define variable ghttpcbudmln as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phBudget-cd as handle, output phRub-cd as handle, output phCpt-cd as handle, output phAna1-cd as handle, output phAna2-cd as handle, output phAna3-cd as handle, output phAna4-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/budget-cd/rub-cd/cpt-cd/ana1-cd/ana2-cd/ana3-cd/ana4-cd/prd-numdeb, 
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

procedure crudPcbudmln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePcbudmln.
    run updatePcbudmln.
    run createPcbudmln.
end procedure.

procedure setPcbudmln:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPcbudmln.
    ghttPcbudmln = phttPcbudmln.
    run crudPcbudmln.
    delete object phttPcbudmln.
end procedure.

procedure readPcbudmln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table pcbudmln construction des budgets : Affectation des Montants
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
    define input parameter table-handle phttPcbudmln.
    define variable vhttBuffer as handle no-undo.
    define buffer pcbudmln for pcbudmln.

    vhttBuffer = phttPcbudmln:default-buffer-handle.
    for first pcbudmln no-lock
        where pcbudmln.soc-cd = piSoc-cd
          and pcbudmln.etab-cd = piEtab-cd
          and pcbudmln.budget-cd = pcBudget-cd
          and pcbudmln.rub-cd = piRub-cd
          and pcbudmln.cpt-cd = pcCpt-cd
          and pcbudmln.ana1-cd = pcAna1-cd
          and pcbudmln.ana2-cd = pcAna2-cd
          and pcbudmln.ana3-cd = pcAna3-cd
          and pcbudmln.ana4-cd = pcAna4-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pcbudmln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPcbudmln no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPcbudmln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table pcbudmln construction des budgets : Affectation des Montants
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
    define input parameter table-handle phttPcbudmln.
    define variable vhttBuffer as handle  no-undo.
    define buffer pcbudmln for pcbudmln.

    vhttBuffer = phttPcbudmln:default-buffer-handle.
    if pcAna4-cd = ?
    then for each pcbudmln no-lock
        where pcbudmln.soc-cd = piSoc-cd
          and pcbudmln.etab-cd = piEtab-cd
          and pcbudmln.budget-cd = pcBudget-cd
          and pcbudmln.rub-cd = piRub-cd
          and pcbudmln.cpt-cd = pcCpt-cd
          and pcbudmln.ana1-cd = pcAna1-cd
          and pcbudmln.ana2-cd = pcAna2-cd
          and pcbudmln.ana3-cd = pcAna3-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pcbudmln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each pcbudmln no-lock
        where pcbudmln.soc-cd = piSoc-cd
          and pcbudmln.etab-cd = piEtab-cd
          and pcbudmln.budget-cd = pcBudget-cd
          and pcbudmln.rub-cd = piRub-cd
          and pcbudmln.cpt-cd = pcCpt-cd
          and pcbudmln.ana1-cd = pcAna1-cd
          and pcbudmln.ana2-cd = pcAna2-cd
          and pcbudmln.ana3-cd = pcAna3-cd
          and pcbudmln.ana4-cd = pcAna4-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pcbudmln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPcbudmln no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePcbudmln private:
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
    define buffer pcbudmln for pcbudmln.

    create query vhttquery.
    vhttBuffer = ghttPcbudmln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPcbudmln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhBudget-cd, output vhRub-cd, output vhCpt-cd, output vhAna1-cd, output vhAna2-cd, output vhAna3-cd, output vhAna4-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pcbudmln exclusive-lock
                where rowid(pcbudmln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pcbudmln:handle, 'soc-cd/etab-cd/budget-cd/rub-cd/cpt-cd/ana1-cd/ana2-cd/ana3-cd/ana4-cd/prd-numdeb: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhBudget-cd:buffer-value(), vhRub-cd:buffer-value(), vhCpt-cd:buffer-value(), vhAna1-cd:buffer-value(), vhAna2-cd:buffer-value(), vhAna3-cd:buffer-value(), vhAna4-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer pcbudmln:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPcbudmln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer pcbudmln for pcbudmln.

    create query vhttquery.
    vhttBuffer = ghttPcbudmln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPcbudmln:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create pcbudmln.
            if not outils:copyValidField(buffer pcbudmln:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePcbudmln private:
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
    define buffer pcbudmln for pcbudmln.

    create query vhttquery.
    vhttBuffer = ghttPcbudmln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPcbudmln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhBudget-cd, output vhRub-cd, output vhCpt-cd, output vhAna1-cd, output vhAna2-cd, output vhAna3-cd, output vhAna4-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pcbudmln exclusive-lock
                where rowid(Pcbudmln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pcbudmln:handle, 'soc-cd/etab-cd/budget-cd/rub-cd/cpt-cd/ana1-cd/ana2-cd/ana3-cd/ana4-cd/prd-numdeb: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhBudget-cd:buffer-value(), vhRub-cd:buffer-value(), vhCpt-cd:buffer-value(), vhAna1-cd:buffer-value(), vhAna2-cd:buffer-value(), vhAna3-cd:buffer-value(), vhAna4-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete pcbudmln no-error.
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

