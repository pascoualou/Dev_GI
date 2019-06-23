/*------------------------------------------------------------------------
File        : ctmpln_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ctmpln
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ctmpln.i}
{application/include/error.i}
define variable ghttctmpln as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phJou-cd as handle, output phPrd-cd as handle, output phPrd-num as handle, output phPiece-int as handle, output phLig as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig, 
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
       end case.
    end.
end function.

procedure crudCtmpln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCtmpln.
    run updateCtmpln.
    run createCtmpln.
end procedure.

procedure setCtmpln:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCtmpln.
    ghttCtmpln = phttCtmpln.
    run crudCtmpln.
    delete object phttCtmpln.
end procedure.

procedure readCtmpln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ctmpln Ligne saisie des écritures nouvelle ergonomie
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcJou-cd    as character  no-undo.
    define input parameter piPrd-cd    as integer    no-undo.
    define input parameter piPrd-num   as integer    no-undo.
    define input parameter piPiece-int as integer    no-undo.
    define input parameter piLig       as integer    no-undo.
    define input parameter table-handle phttCtmpln.
    define variable vhttBuffer as handle no-undo.
    define buffer ctmpln for ctmpln.

    vhttBuffer = phttCtmpln:default-buffer-handle.
    for first ctmpln no-lock
        where ctmpln.soc-cd = piSoc-cd
          and ctmpln.etab-cd = piEtab-cd
          and ctmpln.jou-cd = pcJou-cd
          and ctmpln.prd-cd = piPrd-cd
          and ctmpln.prd-num = piPrd-num
          and ctmpln.piece-int = piPiece-int
          and ctmpln.lig = piLig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ctmpln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCtmpln no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCtmpln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ctmpln Ligne saisie des écritures nouvelle ergonomie
    Notes  : service externe. Critère piPiece-int = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcJou-cd    as character  no-undo.
    define input parameter piPrd-cd    as integer    no-undo.
    define input parameter piPrd-num   as integer    no-undo.
    define input parameter piPiece-int as integer    no-undo.
    define input parameter table-handle phttCtmpln.
    define variable vhttBuffer as handle  no-undo.
    define buffer ctmpln for ctmpln.

    vhttBuffer = phttCtmpln:default-buffer-handle.
    if piPiece-int = ?
    then for each ctmpln no-lock
        where ctmpln.soc-cd = piSoc-cd
          and ctmpln.etab-cd = piEtab-cd
          and ctmpln.jou-cd = pcJou-cd
          and ctmpln.prd-cd = piPrd-cd
          and ctmpln.prd-num = piPrd-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ctmpln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ctmpln no-lock
        where ctmpln.soc-cd = piSoc-cd
          and ctmpln.etab-cd = piEtab-cd
          and ctmpln.jou-cd = pcJou-cd
          and ctmpln.prd-cd = piPrd-cd
          and ctmpln.prd-num = piPrd-num
          and ctmpln.piece-int = piPiece-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ctmpln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCtmpln no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCtmpln private:
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
    define buffer ctmpln for ctmpln.

    create query vhttquery.
    vhttBuffer = ghttCtmpln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCtmpln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-int, output vhLig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ctmpln exclusive-lock
                where rowid(ctmpln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ctmpln:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-int:buffer-value(), vhLig:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ctmpln:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCtmpln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ctmpln for ctmpln.

    create query vhttquery.
    vhttBuffer = ghttCtmpln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCtmpln:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ctmpln.
            if not outils:copyValidField(buffer ctmpln:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCtmpln private:
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
    define buffer ctmpln for ctmpln.

    create query vhttquery.
    vhttBuffer = ghttCtmpln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCtmpln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-int, output vhLig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ctmpln exclusive-lock
                where rowid(Ctmpln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ctmpln:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-int:buffer-value(), vhLig:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ctmpln no-error.
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

