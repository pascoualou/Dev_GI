/*------------------------------------------------------------------------
File        : cextsai_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cextsai
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cextsai.i}
{application/include/error.i}
define variable ghttcextsai as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phNatjou-cd as handle, output phPrd-cd as handle, output phPrd-num as handle, output phJou-cd as handle, output phPiece-compta as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/natjou-cd/prd-cd/prd-num/jou-cd/piece-compta, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'natjou-cd' then phNatjou-cd = phBuffer:buffer-field(vi).
            when 'prd-cd' then phPrd-cd = phBuffer:buffer-field(vi).
            when 'prd-num' then phPrd-num = phBuffer:buffer-field(vi).
            when 'jou-cd' then phJou-cd = phBuffer:buffer-field(vi).
            when 'piece-compta' then phPiece-compta = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCextsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCextsai.
    run updateCextsai.
    run createCextsai.
end procedure.

procedure setCextsai:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCextsai.
    ghttCextsai = phttCextsai.
    run crudCextsai.
    delete object phttCextsai.
end procedure.

procedure readCextsai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cextsai Entete de gestion des ecritures
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd       as integer    no-undo.
    define input parameter piEtab-cd      as integer    no-undo.
    define input parameter piNatjou-cd    as integer    no-undo.
    define input parameter piPrd-cd       as integer    no-undo.
    define input parameter piPrd-num      as integer    no-undo.
    define input parameter pcJou-cd       as character  no-undo.
    define input parameter piPiece-compta as integer    no-undo.
    define input parameter table-handle phttCextsai.
    define variable vhttBuffer as handle no-undo.
    define buffer cextsai for cextsai.

    vhttBuffer = phttCextsai:default-buffer-handle.
    for first cextsai no-lock
        where cextsai.soc-cd = piSoc-cd
          and cextsai.etab-cd = piEtab-cd
          and cextsai.natjou-cd = piNatjou-cd
          and cextsai.prd-cd = piPrd-cd
          and cextsai.prd-num = piPrd-num
          and cextsai.jou-cd = pcJou-cd
          and cextsai.piece-compta = piPiece-compta:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cextsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCextsai no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCextsai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cextsai Entete de gestion des ecritures
    Notes  : service externe. Critère pcJou-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd       as integer    no-undo.
    define input parameter piEtab-cd      as integer    no-undo.
    define input parameter piNatjou-cd    as integer    no-undo.
    define input parameter piPrd-cd       as integer    no-undo.
    define input parameter piPrd-num      as integer    no-undo.
    define input parameter pcJou-cd       as character  no-undo.
    define input parameter table-handle phttCextsai.
    define variable vhttBuffer as handle  no-undo.
    define buffer cextsai for cextsai.

    vhttBuffer = phttCextsai:default-buffer-handle.
    if pcJou-cd = ?
    then for each cextsai no-lock
        where cextsai.soc-cd = piSoc-cd
          and cextsai.etab-cd = piEtab-cd
          and cextsai.natjou-cd = piNatjou-cd
          and cextsai.prd-cd = piPrd-cd
          and cextsai.prd-num = piPrd-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cextsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cextsai no-lock
        where cextsai.soc-cd = piSoc-cd
          and cextsai.etab-cd = piEtab-cd
          and cextsai.natjou-cd = piNatjou-cd
          and cextsai.prd-cd = piPrd-cd
          and cextsai.prd-num = piPrd-num
          and cextsai.jou-cd = pcJou-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cextsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCextsai no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCextsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNatjou-cd    as handle  no-undo.
    define variable vhPrd-cd    as handle  no-undo.
    define variable vhPrd-num    as handle  no-undo.
    define variable vhJou-cd    as handle  no-undo.
    define variable vhPiece-compta    as handle  no-undo.
    define buffer cextsai for cextsai.

    create query vhttquery.
    vhttBuffer = ghttCextsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCextsai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNatjou-cd, output vhPrd-cd, output vhPrd-num, output vhJou-cd, output vhPiece-compta).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cextsai exclusive-lock
                where rowid(cextsai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cextsai:handle, 'soc-cd/etab-cd/natjou-cd/prd-cd/prd-num/jou-cd/piece-compta: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNatjou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhJou-cd:buffer-value(), vhPiece-compta:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cextsai:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCextsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cextsai for cextsai.

    create query vhttquery.
    vhttBuffer = ghttCextsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCextsai:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cextsai.
            if not outils:copyValidField(buffer cextsai:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCextsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNatjou-cd    as handle  no-undo.
    define variable vhPrd-cd    as handle  no-undo.
    define variable vhPrd-num    as handle  no-undo.
    define variable vhJou-cd    as handle  no-undo.
    define variable vhPiece-compta    as handle  no-undo.
    define buffer cextsai for cextsai.

    create query vhttquery.
    vhttBuffer = ghttCextsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCextsai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNatjou-cd, output vhPrd-cd, output vhPrd-num, output vhJou-cd, output vhPiece-compta).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cextsai exclusive-lock
                where rowid(Cextsai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cextsai:handle, 'soc-cd/etab-cd/natjou-cd/prd-cd/prd-num/jou-cd/piece-compta: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNatjou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhJou-cd:buffer-value(), vhPiece-compta:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cextsai no-error.
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

