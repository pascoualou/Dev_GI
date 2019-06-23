/*------------------------------------------------------------------------
File        : pnumatt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table pnumatt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/pnumatt.i}
{application/include/error.i}
define variable ghttpnumatt as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudPnumatt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePnumatt.
    run updatePnumatt.
    run createPnumatt.
end procedure.

procedure setPnumatt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPnumatt.
    ghttPnumatt = phttPnumatt.
    run crudPnumatt.
    delete object phttPnumatt.
end procedure.

procedure readPnumatt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table pnumatt Fichier numeros de pieces en attente (remises clients)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd       as integer    no-undo.
    define input parameter piEtab-cd      as integer    no-undo.
    define input parameter pcJou-cd       as character  no-undo.
    define input parameter piPrd-cd       as integer    no-undo.
    define input parameter piPrd-num      as integer    no-undo.
    define input parameter piPiece-compta as integer    no-undo.
    define input parameter table-handle phttPnumatt.
    define variable vhttBuffer as handle no-undo.
    define buffer pnumatt for pnumatt.

    vhttBuffer = phttPnumatt:default-buffer-handle.
    for first pnumatt no-lock
        where pnumatt.soc-cd = piSoc-cd
          and pnumatt.etab-cd = piEtab-cd
          and pnumatt.jou-cd = pcJou-cd
          and pnumatt.prd-cd = piPrd-cd
          and pnumatt.prd-num = piPrd-num
          and pnumatt.piece-compta = piPiece-compta:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pnumatt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPnumatt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPnumatt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table pnumatt Fichier numeros de pieces en attente (remises clients)
    Notes  : service externe. Critère piPrd-num = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd       as integer    no-undo.
    define input parameter piEtab-cd      as integer    no-undo.
    define input parameter pcJou-cd       as character  no-undo.
    define input parameter piPrd-cd       as integer    no-undo.
    define input parameter piPrd-num      as integer    no-undo.
    define input parameter table-handle phttPnumatt.
    define variable vhttBuffer as handle  no-undo.
    define buffer pnumatt for pnumatt.

    vhttBuffer = phttPnumatt:default-buffer-handle.
    if piPrd-num = ?
    then for each pnumatt no-lock
        where pnumatt.soc-cd = piSoc-cd
          and pnumatt.etab-cd = piEtab-cd
          and pnumatt.jou-cd = pcJou-cd
          and pnumatt.prd-cd = piPrd-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pnumatt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each pnumatt no-lock
        where pnumatt.soc-cd = piSoc-cd
          and pnumatt.etab-cd = piEtab-cd
          and pnumatt.jou-cd = pcJou-cd
          and pnumatt.prd-cd = piPrd-cd
          and pnumatt.prd-num = piPrd-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pnumatt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPnumatt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePnumatt private:
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
    define buffer pnumatt for pnumatt.

    create query vhttquery.
    vhttBuffer = ghttPnumatt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPnumatt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-compta).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pnumatt exclusive-lock
                where rowid(pnumatt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pnumatt:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-compta: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-compta:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer pnumatt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPnumatt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer pnumatt for pnumatt.

    create query vhttquery.
    vhttBuffer = ghttPnumatt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPnumatt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create pnumatt.
            if not outils:copyValidField(buffer pnumatt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePnumatt private:
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
    define buffer pnumatt for pnumatt.

    create query vhttquery.
    vhttBuffer = ghttPnumatt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPnumatt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-compta).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pnumatt exclusive-lock
                where rowid(Pnumatt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pnumatt:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-compta: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-compta:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete pnumatt no-error.
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

