/*------------------------------------------------------------------------
File        : iribmaj_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iribmaj
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iribmaj.i}
{application/include/error.i}
define variable ghttiribmaj as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phType as handle, output phTiers-cle as handle, output phOrdre-num as handle, output phCode_action as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/type/tiers-cle/ordre-num/code_action, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'type' then phType = phBuffer:buffer-field(vi).
            when 'tiers-cle' then phTiers-cle = phBuffer:buffer-field(vi).
            when 'ordre-num' then phOrdre-num = phBuffer:buffer-field(vi).
            when 'code_action' then phCode_action = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIribmaj private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIribmaj.
    run updateIribmaj.
    run createIribmaj.
end procedure.

procedure setIribmaj:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIribmaj.
    ghttIribmaj = phttIribmaj.
    run crudIribmaj.
    delete object phttIribmaj.
end procedure.

procedure readIribmaj:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iribmaj Liste des rib en attente de validation
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter pcType        as character  no-undo.
    define input parameter pcTiers-cle   as character  no-undo.
    define input parameter piOrdre-num   as integer    no-undo.
    define input parameter pcCode_action as character  no-undo.
    define input parameter table-handle phttIribmaj.
    define variable vhttBuffer as handle no-undo.
    define buffer iribmaj for iribmaj.

    vhttBuffer = phttIribmaj:default-buffer-handle.
    for first iribmaj no-lock
        where iribmaj.soc-cd = piSoc-cd
          and iribmaj.type = pcType
          and iribmaj.tiers-cle = pcTiers-cle
          and iribmaj.ordre-num = piOrdre-num
          and iribmaj.code_action = pcCode_action:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iribmaj:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIribmaj no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIribmaj:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iribmaj Liste des rib en attente de validation
    Notes  : service externe. Critère piOrdre-num = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter pcType        as character  no-undo.
    define input parameter pcTiers-cle   as character  no-undo.
    define input parameter piOrdre-num   as integer    no-undo.
    define input parameter table-handle phttIribmaj.
    define variable vhttBuffer as handle  no-undo.
    define buffer iribmaj for iribmaj.

    vhttBuffer = phttIribmaj:default-buffer-handle.
    if piOrdre-num = ?
    then for each iribmaj no-lock
        where iribmaj.soc-cd = piSoc-cd
          and iribmaj.type = pcType
          and iribmaj.tiers-cle = pcTiers-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iribmaj:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iribmaj no-lock
        where iribmaj.soc-cd = piSoc-cd
          and iribmaj.type = pcType
          and iribmaj.tiers-cle = pcTiers-cle
          and iribmaj.ordre-num = piOrdre-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iribmaj:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIribmaj no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIribmaj private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhType    as handle  no-undo.
    define variable vhTiers-cle    as handle  no-undo.
    define variable vhOrdre-num    as handle  no-undo.
    define variable vhCode_action    as handle  no-undo.
    define buffer iribmaj for iribmaj.

    create query vhttquery.
    vhttBuffer = ghttIribmaj:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIribmaj:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhType, output vhTiers-cle, output vhOrdre-num, output vhCode_action).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iribmaj exclusive-lock
                where rowid(iribmaj) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iribmaj:handle, 'soc-cd/type/tiers-cle/ordre-num/code_action: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhType:buffer-value(), vhTiers-cle:buffer-value(), vhOrdre-num:buffer-value(), vhCode_action:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iribmaj:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIribmaj private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iribmaj for iribmaj.

    create query vhttquery.
    vhttBuffer = ghttIribmaj:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIribmaj:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iribmaj.
            if not outils:copyValidField(buffer iribmaj:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIribmaj private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhType    as handle  no-undo.
    define variable vhTiers-cle    as handle  no-undo.
    define variable vhOrdre-num    as handle  no-undo.
    define variable vhCode_action    as handle  no-undo.
    define buffer iribmaj for iribmaj.

    create query vhttquery.
    vhttBuffer = ghttIribmaj:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIribmaj:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhType, output vhTiers-cle, output vhOrdre-num, output vhCode_action).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iribmaj exclusive-lock
                where rowid(Iribmaj) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iribmaj:handle, 'soc-cd/type/tiers-cle/ordre-num/code_action: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhType:buffer-value(), vhTiers-cle:buffer-value(), vhOrdre-num:buffer-value(), vhCode_action:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iribmaj no-error.
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

