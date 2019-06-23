/*------------------------------------------------------------------------
File        : aligrefa_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table aligrefa
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/aligrefa.i}
{application/include/error.i}
define variable ghttaligrefa as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phJou-cd as handle, output phPrd-cd as handle, output phPrd-num as handle, output phPiece-int as handle, output phLig as handle, output phPos as handle, output phNum-int as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig/pos/num-int/noloc, 
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
            when 'num-int' then phNum-int = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAligrefa private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAligrefa.
    run updateAligrefa.
    run createAligrefa.
end procedure.

procedure setAligrefa:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAligrefa.
    ghttAligrefa = phttAligrefa.
    run crudAligrefa.
    delete object phttAligrefa.
end procedure.

procedure readAligrefa:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table aligrefa 
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
    define input parameter piNum-int   as integer    no-undo.
    define input parameter table-handle phttAligrefa.
    define variable vhttBuffer as handle no-undo.
    define buffer aligrefa for aligrefa.

    vhttBuffer = phttAligrefa:default-buffer-handle.
    for first aligrefa no-lock
        where aligrefa.soc-cd = piSoc-cd
          and aligrefa.etab-cd = piEtab-cd
          and aligrefa.jou-cd = pcJou-cd
          and aligrefa.prd-cd = piPrd-cd
          and aligrefa.prd-num = piPrd-num
          and aligrefa.piece-int = piPiece-int
          and aligrefa.lig = piLig
          and aligrefa.pos = piPos
          and aligrefa.num-int = piNum-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aligrefa:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAligrefa no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAligrefa:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table aligrefa 
    Notes  : service externe. Critère piNum-int = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcJou-cd    as character  no-undo.
    define input parameter piPrd-cd    as integer    no-undo.
    define input parameter piPrd-num   as integer    no-undo.
    define input parameter piPiece-int as integer    no-undo.
    define input parameter piLig       as integer    no-undo.
    define input parameter piPos       as integer    no-undo.
    define input parameter piNum-int   as integer    no-undo.
    define input parameter table-handle phttAligrefa.
    define variable vhttBuffer as handle  no-undo.
    define buffer aligrefa for aligrefa.

    vhttBuffer = phttAligrefa:default-buffer-handle.
    if piNum-int = ?
    then for each aligrefa no-lock
        where aligrefa.soc-cd = piSoc-cd
          and aligrefa.etab-cd = piEtab-cd
          and aligrefa.jou-cd = pcJou-cd
          and aligrefa.prd-cd = piPrd-cd
          and aligrefa.prd-num = piPrd-num
          and aligrefa.piece-int = piPiece-int
          and aligrefa.lig = piLig
          and aligrefa.pos = piPos:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aligrefa:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each aligrefa no-lock
        where aligrefa.soc-cd = piSoc-cd
          and aligrefa.etab-cd = piEtab-cd
          and aligrefa.jou-cd = pcJou-cd
          and aligrefa.prd-cd = piPrd-cd
          and aligrefa.prd-num = piPrd-num
          and aligrefa.piece-int = piPiece-int
          and aligrefa.lig = piLig
          and aligrefa.pos = piPos
          and aligrefa.num-int = piNum-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aligrefa:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAligrefa no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAligrefa private:
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
    define variable vhNum-int    as handle  no-undo.
    define buffer aligrefa for aligrefa.

    create query vhttquery.
    vhttBuffer = ghttAligrefa:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAligrefa:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-int, output vhLig, output vhPos, output vhNum-int).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aligrefa exclusive-lock
                where rowid(aligrefa) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aligrefa:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig/pos/num-int/noloc: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-int:buffer-value(), vhLig:buffer-value(), vhPos:buffer-value(), vhNum-int:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer aligrefa:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAligrefa private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer aligrefa for aligrefa.

    create query vhttquery.
    vhttBuffer = ghttAligrefa:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAligrefa:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create aligrefa.
            if not outils:copyValidField(buffer aligrefa:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAligrefa private:
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
    define variable vhNum-int    as handle  no-undo.
    define buffer aligrefa for aligrefa.

    create query vhttquery.
    vhttBuffer = ghttAligrefa:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAligrefa:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-int, output vhLig, output vhPos, output vhNum-int).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aligrefa exclusive-lock
                where rowid(Aligrefa) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aligrefa:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig/pos/num-int/noloc: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-int:buffer-value(), vhLig:buffer-value(), vhPos:buffer-value(), vhNum-int:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete aligrefa no-error.
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

