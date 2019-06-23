/*------------------------------------------------------------------------
File        : iengplaf_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iengplaf
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iengplaf.i}
{application/include/error.i}
define variable ghttiengplaf as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phBudget-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/budget-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'budget-cd' then phBudget-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIengplaf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIengplaf.
    run updateIengplaf.
    run createIengplaf.
end procedure.

procedure setIengplaf:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIengplaf.
    ghttIengplaf = phttIengplaf.
    run crudIengplaf.
    delete object phttIengplaf.
end procedure.

procedure readIengplaf:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iengplaf 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcBudget-cd as character  no-undo.
    define input parameter table-handle phttIengplaf.
    define variable vhttBuffer as handle no-undo.
    define buffer iengplaf for iengplaf.

    vhttBuffer = phttIengplaf:default-buffer-handle.
    for first iengplaf no-lock
        where iengplaf.soc-cd = piSoc-cd
          and iengplaf.etab-cd = piEtab-cd
          and iengplaf.budget-cd = pcBudget-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iengplaf:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIengplaf no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIengplaf:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iengplaf 
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter table-handle phttIengplaf.
    define variable vhttBuffer as handle  no-undo.
    define buffer iengplaf for iengplaf.

    vhttBuffer = phttIengplaf:default-buffer-handle.
    if piEtab-cd = ?
    then for each iengplaf no-lock
        where iengplaf.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iengplaf:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iengplaf no-lock
        where iengplaf.soc-cd = piSoc-cd
          and iengplaf.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iengplaf:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIengplaf no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIengplaf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhBudget-cd    as handle  no-undo.
    define buffer iengplaf for iengplaf.

    create query vhttquery.
    vhttBuffer = ghttIengplaf:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIengplaf:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhBudget-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iengplaf exclusive-lock
                where rowid(iengplaf) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iengplaf:handle, 'soc-cd/etab-cd/budget-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhBudget-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iengplaf:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIengplaf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iengplaf for iengplaf.

    create query vhttquery.
    vhttBuffer = ghttIengplaf:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIengplaf:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iengplaf.
            if not outils:copyValidField(buffer iengplaf:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIengplaf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhBudget-cd    as handle  no-undo.
    define buffer iengplaf for iengplaf.

    create query vhttquery.
    vhttBuffer = ghttIengplaf:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIengplaf:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhBudget-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iengplaf exclusive-lock
                where rowid(Iengplaf) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iengplaf:handle, 'soc-cd/etab-cd/budget-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhBudget-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iengplaf no-error.
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

