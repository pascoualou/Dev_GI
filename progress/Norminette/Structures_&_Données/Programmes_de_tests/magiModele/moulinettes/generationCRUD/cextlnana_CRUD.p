/*------------------------------------------------------------------------
File        : cextlnana_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cextlnana
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cextlnana.i}
{application/include/error.i}
define variable ghttcextlnana as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudCextlnana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCextlnana.
    run updateCextlnana.
    run createCextlnana.
end procedure.

procedure setCextlnana:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCextlnana.
    ghttCextlnana = phttCextlnana.
    run crudCextlnana.
    delete object phttCextlnana.
end procedure.

procedure readCextlnana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cextlnana Fichier des lignes d'ecritures analytiques
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
    define input parameter table-handle phttCextlnana.
    define variable vhttBuffer as handle no-undo.
    define buffer cextlnana for cextlnana.

    vhttBuffer = phttCextlnana:default-buffer-handle.
    for first cextlnana no-lock
        where cextlnana.soc-cd = piSoc-cd
          and cextlnana.etab-cd = piEtab-cd
          and cextlnana.jou-cd = pcJou-cd
          and cextlnana.prd-cd = piPrd-cd
          and cextlnana.prd-num = piPrd-num
          and cextlnana.piece-int = piPiece-int
          and cextlnana.lig = piLig
          and cextlnana.pos = piPos
          and cextlnana.ana-cd = pcAna-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cextlnana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCextlnana no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCextlnana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cextlnana Fichier des lignes d'ecritures analytiques
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
    define input parameter table-handle phttCextlnana.
    define variable vhttBuffer as handle  no-undo.
    define buffer cextlnana for cextlnana.

    vhttBuffer = phttCextlnana:default-buffer-handle.
    if piPos = ?
    then for each cextlnana no-lock
        where cextlnana.soc-cd = piSoc-cd
          and cextlnana.etab-cd = piEtab-cd
          and cextlnana.jou-cd = pcJou-cd
          and cextlnana.prd-cd = piPrd-cd
          and cextlnana.prd-num = piPrd-num
          and cextlnana.piece-int = piPiece-int
          and cextlnana.lig = piLig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cextlnana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cextlnana no-lock
        where cextlnana.soc-cd = piSoc-cd
          and cextlnana.etab-cd = piEtab-cd
          and cextlnana.jou-cd = pcJou-cd
          and cextlnana.prd-cd = piPrd-cd
          and cextlnana.prd-num = piPrd-num
          and cextlnana.piece-int = piPiece-int
          and cextlnana.lig = piLig
          and cextlnana.pos = piPos:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cextlnana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCextlnana no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCextlnana private:
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
    define buffer cextlnana for cextlnana.

    create query vhttquery.
    vhttBuffer = ghttCextlnana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCextlnana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-int, output vhLig, output vhPos, output vhAna-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cextlnana exclusive-lock
                where rowid(cextlnana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cextlnana:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig/pos/ana-cd: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-int:buffer-value(), vhLig:buffer-value(), vhPos:buffer-value(), vhAna-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cextlnana:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCextlnana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cextlnana for cextlnana.

    create query vhttquery.
    vhttBuffer = ghttCextlnana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCextlnana:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cextlnana.
            if not outils:copyValidField(buffer cextlnana:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCextlnana private:
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
    define buffer cextlnana for cextlnana.

    create query vhttquery.
    vhttBuffer = ghttCextlnana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCextlnana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-int, output vhLig, output vhPos, output vhAna-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cextlnana exclusive-lock
                where rowid(Cextlnana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cextlnana:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig/pos/ana-cd: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-int:buffer-value(), vhLig:buffer-value(), vhPos:buffer-value(), vhAna-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cextlnana no-error.
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

