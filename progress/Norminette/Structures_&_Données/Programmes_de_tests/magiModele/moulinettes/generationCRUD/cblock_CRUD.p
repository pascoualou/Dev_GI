/*------------------------------------------------------------------------
File        : cblock_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cblock
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cblock.i}
{application/include/error.i}
define variable ghttcblock as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phJou-cd as handle, output phPrd-cd as handle, output phPrd-num as handle, output phPiece-int as handle, output phLig as handle, output phDacre as handle, output phHcre as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig/dacre/hcre, 
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
            when 'piece-int' then phPiece-int = phBuffer:buffer-field(vi).
            when 'lig' then phLig = phBuffer:buffer-field(vi).
            when 'dacre' then phDacre = phBuffer:buffer-field(vi).
            when 'hcre' then phHcre = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCblock private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCblock.
    run updateCblock.
    run createCblock.
end procedure.

procedure setCblock:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCblock.
    ghttCblock = phttCblock.
    run crudCblock.
    delete object phttCblock.
end procedure.

procedure readCblock:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cblock 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcJou-cd    as character  no-undo.
    define input parameter piPrd-cd    as integer    no-undo.
    define input parameter piPrd-num   as integer    no-undo.
    define input parameter piPiece-int as integer    no-undo.
    define input parameter piLig       as integer    no-undo.
    define input parameter pdaDacre     as date       no-undo.
    define input parameter piHcre      as integer    no-undo.
    define input parameter table-handle phttCblock.
    define variable vhttBuffer as handle no-undo.
    define buffer cblock for cblock.

    vhttBuffer = phttCblock:default-buffer-handle.
    for first cblock no-lock
        where cblock.soc-cd = piSoc-cd
          and cblock.etab-cd = piEtab-cd
          and cblock.jou-cd = pcJou-cd
          and cblock.prd-cd = piPrd-cd
          and cblock.prd-num = piPrd-num
          and cblock.piece-int = piPiece-int
          and cblock.lig = piLig
          and cblock.dacre = pdaDacre
          and cblock.hcre = piHcre:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cblock:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCblock no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCblock:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cblock 
    Notes  : service externe. Critère pdaDacre = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcJou-cd    as character  no-undo.
    define input parameter piPrd-cd    as integer    no-undo.
    define input parameter piPrd-num   as integer    no-undo.
    define input parameter piPiece-int as integer    no-undo.
    define input parameter piLig       as integer    no-undo.
    define input parameter pdaDacre     as date       no-undo.
    define input parameter table-handle phttCblock.
    define variable vhttBuffer as handle  no-undo.
    define buffer cblock for cblock.

    vhttBuffer = phttCblock:default-buffer-handle.
    if pdaDacre = ?
    then for each cblock no-lock
        where cblock.soc-cd = piSoc-cd
          and cblock.etab-cd = piEtab-cd
          and cblock.jou-cd = pcJou-cd
          and cblock.prd-cd = piPrd-cd
          and cblock.prd-num = piPrd-num
          and cblock.piece-int = piPiece-int
          and cblock.lig = piLig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cblock:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cblock no-lock
        where cblock.soc-cd = piSoc-cd
          and cblock.etab-cd = piEtab-cd
          and cblock.jou-cd = pcJou-cd
          and cblock.prd-cd = piPrd-cd
          and cblock.prd-num = piPrd-num
          and cblock.piece-int = piPiece-int
          and cblock.lig = piLig
          and cblock.dacre = pdaDacre:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cblock:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCblock no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCblock private:
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
    define variable vhPiece-int    as handle  no-undo.
    define variable vhLig    as handle  no-undo.
    define variable vhDacre    as handle  no-undo.
    define variable vhHcre    as handle  no-undo.
    define buffer cblock for cblock.

    create query vhttquery.
    vhttBuffer = ghttCblock:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCblock:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-int, output vhLig, output vhDacre, output vhHcre).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cblock exclusive-lock
                where rowid(cblock) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cblock:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig/dacre/hcre: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-int:buffer-value(), vhLig:buffer-value(), vhDacre:buffer-value(), vhHcre:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cblock:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCblock private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cblock for cblock.

    create query vhttquery.
    vhttBuffer = ghttCblock:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCblock:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cblock.
            if not outils:copyValidField(buffer cblock:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCblock private:
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
    define variable vhPiece-int    as handle  no-undo.
    define variable vhLig    as handle  no-undo.
    define variable vhDacre    as handle  no-undo.
    define variable vhHcre    as handle  no-undo.
    define buffer cblock for cblock.

    create query vhttquery.
    vhttBuffer = ghttCblock:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCblock:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-int, output vhLig, output vhDacre, output vhHcre).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cblock exclusive-lock
                where rowid(Cblock) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cblock:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig/dacre/hcre: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-int:buffer-value(), vhLig:buffer-value(), vhDacre:buffer-value(), vhHcre:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cblock no-error.
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

