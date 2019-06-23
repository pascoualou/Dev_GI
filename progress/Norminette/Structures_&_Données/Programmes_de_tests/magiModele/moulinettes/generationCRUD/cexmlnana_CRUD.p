/*------------------------------------------------------------------------
File        : cexmlnana_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cexmlnana
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cexmlnana.i}
{application/include/error.i}
define variable ghttcexmlnana as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phJou-cd as handle, output phPrd-cd as handle, output phPrd-num as handle, output phPiece-int as handle, output phLig as handle, output phPos as handle, output phAna-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig/pos/ana-cd, 
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
            when 'pos' then phPos = phBuffer:buffer-field(vi).
            when 'ana-cd' then phAna-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCexmlnana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCexmlnana.
    run updateCexmlnana.
    run createCexmlnana.
end procedure.

procedure setCexmlnana:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCexmlnana.
    ghttCexmlnana = phttCexmlnana.
    run crudCexmlnana.
    delete object phttCexmlnana.
end procedure.

procedure readCexmlnana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cexmlnana Analytique charges locatives mandat
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcJou-cd    as character  no-undo.
    define input parameter piPrd-cd    as integer    no-undo.
    define input parameter piPrd-num   as integer    no-undo.
    define input parameter piPiece-int as integer    no-undo.
    define input parameter piLig       as integer    no-undo.
    define input parameter piPos       as integer    no-undo.
    define input parameter pcAna-cd    as character  no-undo.
    define input parameter table-handle phttCexmlnana.
    define variable vhttBuffer as handle no-undo.
    define buffer cexmlnana for cexmlnana.

    vhttBuffer = phttCexmlnana:default-buffer-handle.
    for first cexmlnana no-lock
        where cexmlnana.soc-cd = piSoc-cd
          and cexmlnana.etab-cd = piEtab-cd
          and cexmlnana.jou-cd = pcJou-cd
          and cexmlnana.prd-cd = piPrd-cd
          and cexmlnana.prd-num = piPrd-num
          and cexmlnana.piece-int = piPiece-int
          and cexmlnana.lig = piLig
          and cexmlnana.pos = piPos
          and cexmlnana.ana-cd = pcAna-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cexmlnana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCexmlnana no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCexmlnana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cexmlnana Analytique charges locatives mandat
    Notes  : service externe. Critère piPos = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcJou-cd    as character  no-undo.
    define input parameter piPrd-cd    as integer    no-undo.
    define input parameter piPrd-num   as integer    no-undo.
    define input parameter piPiece-int as integer    no-undo.
    define input parameter piLig       as integer    no-undo.
    define input parameter piPos       as integer    no-undo.
    define input parameter table-handle phttCexmlnana.
    define variable vhttBuffer as handle  no-undo.
    define buffer cexmlnana for cexmlnana.

    vhttBuffer = phttCexmlnana:default-buffer-handle.
    if piPos = ?
    then for each cexmlnana no-lock
        where cexmlnana.soc-cd = piSoc-cd
          and cexmlnana.etab-cd = piEtab-cd
          and cexmlnana.jou-cd = pcJou-cd
          and cexmlnana.prd-cd = piPrd-cd
          and cexmlnana.prd-num = piPrd-num
          and cexmlnana.piece-int = piPiece-int
          and cexmlnana.lig = piLig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cexmlnana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cexmlnana no-lock
        where cexmlnana.soc-cd = piSoc-cd
          and cexmlnana.etab-cd = piEtab-cd
          and cexmlnana.jou-cd = pcJou-cd
          and cexmlnana.prd-cd = piPrd-cd
          and cexmlnana.prd-num = piPrd-num
          and cexmlnana.piece-int = piPiece-int
          and cexmlnana.lig = piLig
          and cexmlnana.pos = piPos:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cexmlnana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCexmlnana no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCexmlnana private:
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
    define variable vhPos    as handle  no-undo.
    define variable vhAna-cd    as handle  no-undo.
    define buffer cexmlnana for cexmlnana.

    create query vhttquery.
    vhttBuffer = ghttCexmlnana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCexmlnana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-int, output vhLig, output vhPos, output vhAna-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cexmlnana exclusive-lock
                where rowid(cexmlnana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cexmlnana:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig/pos/ana-cd: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-int:buffer-value(), vhLig:buffer-value(), vhPos:buffer-value(), vhAna-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cexmlnana:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCexmlnana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cexmlnana for cexmlnana.

    create query vhttquery.
    vhttBuffer = ghttCexmlnana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCexmlnana:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cexmlnana.
            if not outils:copyValidField(buffer cexmlnana:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCexmlnana private:
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
    define variable vhPos    as handle  no-undo.
    define variable vhAna-cd    as handle  no-undo.
    define buffer cexmlnana for cexmlnana.

    create query vhttquery.
    vhttBuffer = ghttCexmlnana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCexmlnana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-int, output vhLig, output vhPos, output vhAna-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cexmlnana exclusive-lock
                where rowid(Cexmlnana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cexmlnana:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig/pos/ana-cd: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-int:buffer-value(), vhLig:buffer-value(), vhPos:buffer-value(), vhAna-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cexmlnana no-error.
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

