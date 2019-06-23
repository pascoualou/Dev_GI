/*------------------------------------------------------------------------
File        : ccbudln_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ccbudln
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ccbudln.i}
{application/include/error.i}
define variable ghttccbudln as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phBudget-cd as handle, output phRub-cd as handle, output phPrd-cd as handle, output phPrd-num as handle, output phCpt-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/budget-cd/rub-cd/prd-cd/prd-num/cpt-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'budget-cd' then phBudget-cd = phBuffer:buffer-field(vi).
            when 'rub-cd' then phRub-cd = phBuffer:buffer-field(vi).
            when 'prd-cd' then phPrd-cd = phBuffer:buffer-field(vi).
            when 'prd-num' then phPrd-num = phBuffer:buffer-field(vi).
            when 'cpt-cd' then phCpt-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCcbudln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCcbudln.
    run updateCcbudln.
    run createCcbudln.
end procedure.

procedure setCcbudln:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCcbudln.
    ghttCcbudln = phttCcbudln.
    run crudCcbudln.
    delete object phttCcbudln.
end procedure.

procedure readCcbudln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ccbudln fichier de construction des lignes de budget general
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcBudget-cd as character  no-undo.
    define input parameter piRub-cd    as integer    no-undo.
    define input parameter piPrd-cd    as integer    no-undo.
    define input parameter piPrd-num   as integer    no-undo.
    define input parameter pcCpt-cd    as character  no-undo.
    define input parameter table-handle phttCcbudln.
    define variable vhttBuffer as handle no-undo.
    define buffer ccbudln for ccbudln.

    vhttBuffer = phttCcbudln:default-buffer-handle.
    for first ccbudln no-lock
        where ccbudln.soc-cd = piSoc-cd
          and ccbudln.etab-cd = piEtab-cd
          and ccbudln.budget-cd = pcBudget-cd
          and ccbudln.rub-cd = piRub-cd
          and ccbudln.prd-cd = piPrd-cd
          and ccbudln.prd-num = piPrd-num
          and ccbudln.cpt-cd = pcCpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ccbudln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCcbudln no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCcbudln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ccbudln fichier de construction des lignes de budget general
    Notes  : service externe. Critère piPrd-num = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcBudget-cd as character  no-undo.
    define input parameter piRub-cd    as integer    no-undo.
    define input parameter piPrd-cd    as integer    no-undo.
    define input parameter piPrd-num   as integer    no-undo.
    define input parameter table-handle phttCcbudln.
    define variable vhttBuffer as handle  no-undo.
    define buffer ccbudln for ccbudln.

    vhttBuffer = phttCcbudln:default-buffer-handle.
    if piPrd-num = ?
    then for each ccbudln no-lock
        where ccbudln.soc-cd = piSoc-cd
          and ccbudln.etab-cd = piEtab-cd
          and ccbudln.budget-cd = pcBudget-cd
          and ccbudln.rub-cd = piRub-cd
          and ccbudln.prd-cd = piPrd-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ccbudln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ccbudln no-lock
        where ccbudln.soc-cd = piSoc-cd
          and ccbudln.etab-cd = piEtab-cd
          and ccbudln.budget-cd = pcBudget-cd
          and ccbudln.rub-cd = piRub-cd
          and ccbudln.prd-cd = piPrd-cd
          and ccbudln.prd-num = piPrd-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ccbudln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCcbudln no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCcbudln private:
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
    define variable vhPrd-cd    as handle  no-undo.
    define variable vhPrd-num    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer ccbudln for ccbudln.

    create query vhttquery.
    vhttBuffer = ghttCcbudln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCcbudln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhBudget-cd, output vhRub-cd, output vhPrd-cd, output vhPrd-num, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ccbudln exclusive-lock
                where rowid(ccbudln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ccbudln:handle, 'soc-cd/etab-cd/budget-cd/rub-cd/prd-cd/prd-num/cpt-cd: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhBudget-cd:buffer-value(), vhRub-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ccbudln:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCcbudln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ccbudln for ccbudln.

    create query vhttquery.
    vhttBuffer = ghttCcbudln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCcbudln:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ccbudln.
            if not outils:copyValidField(buffer ccbudln:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCcbudln private:
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
    define variable vhPrd-cd    as handle  no-undo.
    define variable vhPrd-num    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer ccbudln for ccbudln.

    create query vhttquery.
    vhttBuffer = ghttCcbudln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCcbudln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhBudget-cd, output vhRub-cd, output vhPrd-cd, output vhPrd-num, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ccbudln exclusive-lock
                where rowid(Ccbudln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ccbudln:handle, 'soc-cd/etab-cd/budget-cd/rub-cd/prd-cd/prd-num/cpt-cd: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhBudget-cd:buffer-value(), vhRub-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ccbudln no-error.
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

