/*------------------------------------------------------------------------
File        : zecr_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table zecr
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/zecr.i}
{application/include/error.i}
define variable ghttzecr as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phJou-cd as handle, output phPrd-cd as handle, output phPrd-num as handle, output phPiece-compta as handle, output phCpt-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-compta/cpt-cd, 
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
            when 'cpt-cd' then phCpt-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudZecr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteZecr.
    run updateZecr.
    run createZecr.
end procedure.

procedure setZecr:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttZecr.
    ghttZecr = phttZecr.
    run crudZecr.
    delete object phttZecr.
end procedure.

procedure readZecr:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table zecr Fichier pour creation des ecritures 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd       as integer    no-undo.
    define input parameter piEtab-cd      as integer    no-undo.
    define input parameter pcJou-cd       as character  no-undo.
    define input parameter piPrd-cd       as integer    no-undo.
    define input parameter piPrd-num      as integer    no-undo.
    define input parameter piPiece-compta as integer    no-undo.
    define input parameter pcCpt-cd       as character  no-undo.
    define input parameter table-handle phttZecr.
    define variable vhttBuffer as handle no-undo.
    define buffer zecr for zecr.

    vhttBuffer = phttZecr:default-buffer-handle.
    for first zecr no-lock
        where zecr.soc-cd = piSoc-cd
          and zecr.etab-cd = piEtab-cd
          and zecr.jou-cd = pcJou-cd
          and zecr.prd-cd = piPrd-cd
          and zecr.prd-num = piPrd-num
          and zecr.piece-compta = piPiece-compta
          and zecr.cpt-cd = pcCpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer zecr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttZecr no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getZecr:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table zecr Fichier pour creation des ecritures 
    Notes  : service externe. Critère piPiece-compta = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd       as integer    no-undo.
    define input parameter piEtab-cd      as integer    no-undo.
    define input parameter pcJou-cd       as character  no-undo.
    define input parameter piPrd-cd       as integer    no-undo.
    define input parameter piPrd-num      as integer    no-undo.
    define input parameter piPiece-compta as integer    no-undo.
    define input parameter table-handle phttZecr.
    define variable vhttBuffer as handle  no-undo.
    define buffer zecr for zecr.

    vhttBuffer = phttZecr:default-buffer-handle.
    if piPiece-compta = ?
    then for each zecr no-lock
        where zecr.soc-cd = piSoc-cd
          and zecr.etab-cd = piEtab-cd
          and zecr.jou-cd = pcJou-cd
          and zecr.prd-cd = piPrd-cd
          and zecr.prd-num = piPrd-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer zecr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each zecr no-lock
        where zecr.soc-cd = piSoc-cd
          and zecr.etab-cd = piEtab-cd
          and zecr.jou-cd = pcJou-cd
          and zecr.prd-cd = piPrd-cd
          and zecr.prd-num = piPrd-num
          and zecr.piece-compta = piPiece-compta:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer zecr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttZecr no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateZecr private:
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
    define variable vhCpt-cd    as handle  no-undo.
    define buffer zecr for zecr.

    create query vhttquery.
    vhttBuffer = ghttZecr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttZecr:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-compta, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first zecr exclusive-lock
                where rowid(zecr) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer zecr:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-compta/cpt-cd: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-compta:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer zecr:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createZecr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer zecr for zecr.

    create query vhttquery.
    vhttBuffer = ghttZecr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttZecr:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create zecr.
            if not outils:copyValidField(buffer zecr:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteZecr private:
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
    define variable vhCpt-cd    as handle  no-undo.
    define buffer zecr for zecr.

    create query vhttquery.
    vhttBuffer = ghttZecr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttZecr:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-compta, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first zecr exclusive-lock
                where rowid(Zecr) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer zecr:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-compta/cpt-cd: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-compta:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete zecr no-error.
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

