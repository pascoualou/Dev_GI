/*------------------------------------------------------------------------
File        : cexmsai_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cexmsai
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cexmsai.i}
{application/include/error.i}
define variable ghttcexmsai as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phJou-cd as handle, output phPrd-cd as handle, output phPrd-num as handle, output phPiece-compta as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-compta, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'jou-cd' then phJou-cd = phBuffer:buffer-field(vi).
            when 'prd-cd' then phPrd-cd = phBuffer:buffer-field(vi).
            when 'prd-num' then phPrd-num = phBuffer:buffer-field(vi).
            when 'piece-compta' then phPiece-compta = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCexmsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCexmsai.
    run updateCexmsai.
    run createCexmsai.
end procedure.

procedure setCexmsai:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCexmsai.
    ghttCexmsai = phttCexmsai.
    run crudCexmsai.
    delete object phttCexmsai.
end procedure.

procedure readCexmsai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cexmsai Entete Charges locatives mandat
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd       as integer    no-undo.
    define input parameter piEtab-cd      as integer    no-undo.
    define input parameter pcJou-cd       as character  no-undo.
    define input parameter piPrd-cd       as integer    no-undo.
    define input parameter piPrd-num      as integer    no-undo.
    define input parameter piPiece-compta as integer    no-undo.
    define input parameter table-handle phttCexmsai.
    define variable vhttBuffer as handle no-undo.
    define buffer cexmsai for cexmsai.

    vhttBuffer = phttCexmsai:default-buffer-handle.
    for first cexmsai no-lock
        where cexmsai.soc-cd = piSoc-cd
          and cexmsai.etab-cd = piEtab-cd
          and cexmsai.jou-cd = pcJou-cd
          and cexmsai.prd-cd = piPrd-cd
          and cexmsai.prd-num = piPrd-num
          and cexmsai.piece-compta = piPiece-compta:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cexmsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCexmsai no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCexmsai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cexmsai Entete Charges locatives mandat
    Notes  : service externe. Critère piPrd-num = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd       as integer    no-undo.
    define input parameter piEtab-cd      as integer    no-undo.
    define input parameter pcJou-cd       as character  no-undo.
    define input parameter piPrd-cd       as integer    no-undo.
    define input parameter piPrd-num      as integer    no-undo.
    define input parameter table-handle phttCexmsai.
    define variable vhttBuffer as handle  no-undo.
    define buffer cexmsai for cexmsai.

    vhttBuffer = phttCexmsai:default-buffer-handle.
    if piPrd-num = ?
    then for each cexmsai no-lock
        where cexmsai.soc-cd = piSoc-cd
          and cexmsai.etab-cd = piEtab-cd
          and cexmsai.jou-cd = pcJou-cd
          and cexmsai.prd-cd = piPrd-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cexmsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cexmsai no-lock
        where cexmsai.soc-cd = piSoc-cd
          and cexmsai.etab-cd = piEtab-cd
          and cexmsai.jou-cd = pcJou-cd
          and cexmsai.prd-cd = piPrd-cd
          and cexmsai.prd-num = piPrd-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cexmsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCexmsai no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCexmsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhJou-cd    as handle  no-undo.
    define variable vhPrd-cd    as handle  no-undo.
    define variable vhPrd-num    as handle  no-undo.
    define variable vhPiece-compta    as handle  no-undo.
    define buffer cexmsai for cexmsai.

    create query vhttquery.
    vhttBuffer = ghttCexmsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCexmsai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-compta).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cexmsai exclusive-lock
                where rowid(cexmsai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cexmsai:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-compta: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-compta:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cexmsai:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCexmsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cexmsai for cexmsai.

    create query vhttquery.
    vhttBuffer = ghttCexmsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCexmsai:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cexmsai.
            if not outils:copyValidField(buffer cexmsai:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCexmsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhJou-cd    as handle  no-undo.
    define variable vhPrd-cd    as handle  no-undo.
    define variable vhPrd-num    as handle  no-undo.
    define variable vhPiece-compta    as handle  no-undo.
    define buffer cexmsai for cexmsai.

    create query vhttquery.
    vhttBuffer = ghttCexmsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCexmsai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-compta).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cexmsai exclusive-lock
                where rowid(Cexmsai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cexmsai:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-compta: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-compta:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cexmsai no-error.
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

