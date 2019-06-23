/*------------------------------------------------------------------------
File        : ctmplnana_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ctmplnana
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ctmplnana.i}
{application/include/error.i}
define variable ghttctmplnana as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phJou-cd as handle, output phPrd-cd as handle, output phPrd-num as handle, output phPiece-int as handle, output phLig as handle, output phPos as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig/pos, 
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
       end case.
    end.
end function.

procedure crudCtmplnana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCtmplnana.
    run updateCtmplnana.
    run createCtmplnana.
end procedure.

procedure setCtmplnana:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCtmplnana.
    ghttCtmplnana = phttCtmplnana.
    run crudCtmplnana.
    delete object phttCtmplnana.
end procedure.

procedure readCtmplnana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ctmplnana Ligne analytique saisie des écritures nouvelle ergonomie
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
    define input parameter table-handle phttCtmplnana.
    define variable vhttBuffer as handle no-undo.
    define buffer ctmplnana for ctmplnana.

    vhttBuffer = phttCtmplnana:default-buffer-handle.
    for first ctmplnana no-lock
        where ctmplnana.soc-cd = piSoc-cd
          and ctmplnana.etab-cd = piEtab-cd
          and ctmplnana.jou-cd = pcJou-cd
          and ctmplnana.prd-cd = piPrd-cd
          and ctmplnana.prd-num = piPrd-num
          and ctmplnana.piece-int = piPiece-int
          and ctmplnana.lig = piLig
          and ctmplnana.pos = piPos:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ctmplnana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCtmplnana no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCtmplnana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ctmplnana Ligne analytique saisie des écritures nouvelle ergonomie
    Notes  : service externe. Critère piLig = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcJou-cd    as character  no-undo.
    define input parameter piPrd-cd    as integer    no-undo.
    define input parameter piPrd-num   as integer    no-undo.
    define input parameter piPiece-int as integer    no-undo.
    define input parameter piLig       as integer    no-undo.
    define input parameter table-handle phttCtmplnana.
    define variable vhttBuffer as handle  no-undo.
    define buffer ctmplnana for ctmplnana.

    vhttBuffer = phttCtmplnana:default-buffer-handle.
    if piLig = ?
    then for each ctmplnana no-lock
        where ctmplnana.soc-cd = piSoc-cd
          and ctmplnana.etab-cd = piEtab-cd
          and ctmplnana.jou-cd = pcJou-cd
          and ctmplnana.prd-cd = piPrd-cd
          and ctmplnana.prd-num = piPrd-num
          and ctmplnana.piece-int = piPiece-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ctmplnana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ctmplnana no-lock
        where ctmplnana.soc-cd = piSoc-cd
          and ctmplnana.etab-cd = piEtab-cd
          and ctmplnana.jou-cd = pcJou-cd
          and ctmplnana.prd-cd = piPrd-cd
          and ctmplnana.prd-num = piPrd-num
          and ctmplnana.piece-int = piPiece-int
          and ctmplnana.lig = piLig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ctmplnana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCtmplnana no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCtmplnana private:
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
    define buffer ctmplnana for ctmplnana.

    create query vhttquery.
    vhttBuffer = ghttCtmplnana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCtmplnana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-int, output vhLig, output vhPos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ctmplnana exclusive-lock
                where rowid(ctmplnana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ctmplnana:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig/pos: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-int:buffer-value(), vhLig:buffer-value(), vhPos:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ctmplnana:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCtmplnana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ctmplnana for ctmplnana.

    create query vhttquery.
    vhttBuffer = ghttCtmplnana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCtmplnana:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ctmplnana.
            if not outils:copyValidField(buffer ctmplnana:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCtmplnana private:
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
    define buffer ctmplnana for ctmplnana.

    create query vhttquery.
    vhttBuffer = ghttCtmplnana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCtmplnana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-int, output vhLig, output vhPos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ctmplnana exclusive-lock
                where rowid(Ctmplnana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ctmplnana:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig/pos: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-int:buffer-value(), vhLig:buffer-value(), vhPos:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ctmplnana no-error.
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

