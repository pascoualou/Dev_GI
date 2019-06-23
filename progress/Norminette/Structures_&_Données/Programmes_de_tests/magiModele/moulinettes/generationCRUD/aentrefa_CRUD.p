/*------------------------------------------------------------------------
File        : aentrefa_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table aentrefa
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/aentrefa.i}
{application/include/error.i}
define variable ghttaentrefa as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phJou-cd as handle, output phPrd-cd as handle, output phPrd-num as handle, output phPiece-int as handle, output phLig as handle, output phPos as handle, output phNum-int as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig/pos/num-int, 
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

procedure crudAentrefa private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAentrefa.
    run updateAentrefa.
    run createAentrefa.
end procedure.

procedure setAentrefa:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAentrefa.
    ghttAentrefa = phttAentrefa.
    run crudAentrefa.
    delete object phttAentrefa.
end procedure.

procedure readAentrefa:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table aentrefa 
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
    define input parameter table-handle phttAentrefa.
    define variable vhttBuffer as handle no-undo.
    define buffer aentrefa for aentrefa.

    vhttBuffer = phttAentrefa:default-buffer-handle.
    for first aentrefa no-lock
        where aentrefa.soc-cd = piSoc-cd
          and aentrefa.etab-cd = piEtab-cd
          and aentrefa.jou-cd = pcJou-cd
          and aentrefa.prd-cd = piPrd-cd
          and aentrefa.prd-num = piPrd-num
          and aentrefa.piece-int = piPiece-int
          and aentrefa.lig = piLig
          and aentrefa.pos = piPos
          and aentrefa.num-int = piNum-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aentrefa:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAentrefa no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAentrefa:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table aentrefa 
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
    define input parameter table-handle phttAentrefa.
    define variable vhttBuffer as handle  no-undo.
    define buffer aentrefa for aentrefa.

    vhttBuffer = phttAentrefa:default-buffer-handle.
    if piPos = ?
    then for each aentrefa no-lock
        where aentrefa.soc-cd = piSoc-cd
          and aentrefa.etab-cd = piEtab-cd
          and aentrefa.jou-cd = pcJou-cd
          and aentrefa.prd-cd = piPrd-cd
          and aentrefa.prd-num = piPrd-num
          and aentrefa.piece-int = piPiece-int
          and aentrefa.lig = piLig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aentrefa:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each aentrefa no-lock
        where aentrefa.soc-cd = piSoc-cd
          and aentrefa.etab-cd = piEtab-cd
          and aentrefa.jou-cd = pcJou-cd
          and aentrefa.prd-cd = piPrd-cd
          and aentrefa.prd-num = piPrd-num
          and aentrefa.piece-int = piPiece-int
          and aentrefa.lig = piLig
          and aentrefa.pos = piPos:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aentrefa:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAentrefa no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAentrefa private:
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
    define buffer aentrefa for aentrefa.

    create query vhttquery.
    vhttBuffer = ghttAentrefa:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAentrefa:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-int, output vhLig, output vhPos, output vhNum-int).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aentrefa exclusive-lock
                where rowid(aentrefa) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aentrefa:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig/pos/num-int: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-int:buffer-value(), vhLig:buffer-value(), vhPos:buffer-value(), vhNum-int:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer aentrefa:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAentrefa private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer aentrefa for aentrefa.

    create query vhttquery.
    vhttBuffer = ghttAentrefa:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAentrefa:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create aentrefa.
            if not outils:copyValidField(buffer aentrefa:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAentrefa private:
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
    define buffer aentrefa for aentrefa.

    create query vhttquery.
    vhttBuffer = ghttAentrefa:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAentrefa:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-int, output vhLig, output vhPos, output vhNum-int).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aentrefa exclusive-lock
                where rowid(Aentrefa) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aentrefa:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig/pos/num-int: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-int:buffer-value(), vhLig:buffer-value(), vhPos:buffer-value(), vhNum-int:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete aentrefa no-error.
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

