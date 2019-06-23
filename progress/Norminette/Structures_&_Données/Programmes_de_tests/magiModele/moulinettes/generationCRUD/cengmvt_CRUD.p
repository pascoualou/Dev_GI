/*------------------------------------------------------------------------
File        : cengmvt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cengmvt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cengmvt.i}
{application/include/error.i}
define variable ghttcengmvt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phBudget-cd as handle, output phNiv-num as handle, output phAna-cd as handle, output phRub-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/budget-cd/niv-num/ana-cd/rub-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'budget-cd' then phBudget-cd = phBuffer:buffer-field(vi).
            when 'niv-num' then phNiv-num = phBuffer:buffer-field(vi).
            when 'ana-cd' then phAna-cd = phBuffer:buffer-field(vi).
            when 'rub-cd' then phRub-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCengmvt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCengmvt.
    run updateCengmvt.
    run createCengmvt.
end procedure.

procedure setCengmvt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCengmvt.
    ghttCengmvt = phttCengmvt.
    run crudCengmvt.
    delete object phttCengmvt.
end procedure.

procedure readCengmvt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cengmvt 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcBudget-cd as character  no-undo.
    define input parameter piNiv-num   as integer    no-undo.
    define input parameter pcAna-cd    as character  no-undo.
    define input parameter piRub-cd    as integer    no-undo.
    define input parameter table-handle phttCengmvt.
    define variable vhttBuffer as handle no-undo.
    define buffer cengmvt for cengmvt.

    vhttBuffer = phttCengmvt:default-buffer-handle.
    for first cengmvt no-lock
        where cengmvt.soc-cd = piSoc-cd
          and cengmvt.etab-cd = piEtab-cd
          and cengmvt.budget-cd = pcBudget-cd
          and cengmvt.niv-num = piNiv-num
          and cengmvt.ana-cd = pcAna-cd
          and cengmvt.rub-cd = piRub-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cengmvt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCengmvt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCengmvt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cengmvt 
    Notes  : service externe. Critère pcAna-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcBudget-cd as character  no-undo.
    define input parameter piNiv-num   as integer    no-undo.
    define input parameter pcAna-cd    as character  no-undo.
    define input parameter table-handle phttCengmvt.
    define variable vhttBuffer as handle  no-undo.
    define buffer cengmvt for cengmvt.

    vhttBuffer = phttCengmvt:default-buffer-handle.
    if pcAna-cd = ?
    then for each cengmvt no-lock
        where cengmvt.soc-cd = piSoc-cd
          and cengmvt.etab-cd = piEtab-cd
          and cengmvt.budget-cd = pcBudget-cd
          and cengmvt.niv-num = piNiv-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cengmvt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cengmvt no-lock
        where cengmvt.soc-cd = piSoc-cd
          and cengmvt.etab-cd = piEtab-cd
          and cengmvt.budget-cd = pcBudget-cd
          and cengmvt.niv-num = piNiv-num
          and cengmvt.ana-cd = pcAna-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cengmvt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCengmvt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCengmvt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhBudget-cd    as handle  no-undo.
    define variable vhNiv-num    as handle  no-undo.
    define variable vhAna-cd    as handle  no-undo.
    define variable vhRub-cd    as handle  no-undo.
    define buffer cengmvt for cengmvt.

    create query vhttquery.
    vhttBuffer = ghttCengmvt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCengmvt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhBudget-cd, output vhNiv-num, output vhAna-cd, output vhRub-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cengmvt exclusive-lock
                where rowid(cengmvt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cengmvt:handle, 'soc-cd/etab-cd/budget-cd/niv-num/ana-cd/rub-cd: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhBudget-cd:buffer-value(), vhNiv-num:buffer-value(), vhAna-cd:buffer-value(), vhRub-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cengmvt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCengmvt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cengmvt for cengmvt.

    create query vhttquery.
    vhttBuffer = ghttCengmvt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCengmvt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cengmvt.
            if not outils:copyValidField(buffer cengmvt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCengmvt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhBudget-cd    as handle  no-undo.
    define variable vhNiv-num    as handle  no-undo.
    define variable vhAna-cd    as handle  no-undo.
    define variable vhRub-cd    as handle  no-undo.
    define buffer cengmvt for cengmvt.

    create query vhttquery.
    vhttBuffer = ghttCengmvt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCengmvt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhBudget-cd, output vhNiv-num, output vhAna-cd, output vhRub-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cengmvt exclusive-lock
                where rowid(Cengmvt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cengmvt:handle, 'soc-cd/etab-cd/budget-cd/niv-num/ana-cd/rub-cd: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhBudget-cd:buffer-value(), vhNiv-num:buffer-value(), vhAna-cd:buffer-value(), vhRub-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cengmvt no-error.
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

