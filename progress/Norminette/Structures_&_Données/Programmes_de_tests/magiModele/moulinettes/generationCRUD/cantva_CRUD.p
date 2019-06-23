/*------------------------------------------------------------------------
File        : cantva_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cantva
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cantva.i}
{application/include/error.i}
define variable ghttcantva as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phSscoll-cle as handle, output phCpt-cd as handle, output phPiece-compta as handle, output phRef-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/sscoll-cle/cpt-cd/piece-compta/ref-num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'sscoll-cle' then phSscoll-cle = phBuffer:buffer-field(vi).
            when 'cpt-cd' then phCpt-cd = phBuffer:buffer-field(vi).
            when 'piece-compta' then phPiece-compta = phBuffer:buffer-field(vi).
            when 'ref-num' then phRef-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCantva private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCantva.
    run updateCantva.
    run createCantva.
end procedure.

procedure setCantva:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCantva.
    ghttCantva = phttCantva.
    run crudCantva.
    delete object phttCantva.
end procedure.

procedure readCantva:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cantva TVA sur encaissement
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd       as integer    no-undo.
    define input parameter piEtab-cd      as integer    no-undo.
    define input parameter pcSscoll-cle   as character  no-undo.
    define input parameter pcCpt-cd       as character  no-undo.
    define input parameter piPiece-compta as integer    no-undo.
    define input parameter pcRef-num      as character  no-undo.
    define input parameter table-handle phttCantva.
    define variable vhttBuffer as handle no-undo.
    define buffer cantva for cantva.

    vhttBuffer = phttCantva:default-buffer-handle.
    for first cantva no-lock
        where cantva.soc-cd = piSoc-cd
          and cantva.etab-cd = piEtab-cd
          and cantva.sscoll-cle = pcSscoll-cle
          and cantva.cpt-cd = pcCpt-cd
          and cantva.piece-compta = piPiece-compta
          and cantva.ref-num = pcRef-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cantva:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCantva no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCantva:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cantva TVA sur encaissement
    Notes  : service externe. Critère piPiece-compta = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd       as integer    no-undo.
    define input parameter piEtab-cd      as integer    no-undo.
    define input parameter pcSscoll-cle   as character  no-undo.
    define input parameter pcCpt-cd       as character  no-undo.
    define input parameter piPiece-compta as integer    no-undo.
    define input parameter table-handle phttCantva.
    define variable vhttBuffer as handle  no-undo.
    define buffer cantva for cantva.

    vhttBuffer = phttCantva:default-buffer-handle.
    if piPiece-compta = ?
    then for each cantva no-lock
        where cantva.soc-cd = piSoc-cd
          and cantva.etab-cd = piEtab-cd
          and cantva.sscoll-cle = pcSscoll-cle
          and cantva.cpt-cd = pcCpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cantva:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cantva no-lock
        where cantva.soc-cd = piSoc-cd
          and cantva.etab-cd = piEtab-cd
          and cantva.sscoll-cle = pcSscoll-cle
          and cantva.cpt-cd = pcCpt-cd
          and cantva.piece-compta = piPiece-compta:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cantva:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCantva no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCantva private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhSscoll-cle    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define variable vhPiece-compta    as handle  no-undo.
    define variable vhRef-num    as handle  no-undo.
    define buffer cantva for cantva.

    create query vhttquery.
    vhttBuffer = ghttCantva:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCantva:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhSscoll-cle, output vhCpt-cd, output vhPiece-compta, output vhRef-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cantva exclusive-lock
                where rowid(cantva) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cantva:handle, 'soc-cd/etab-cd/sscoll-cle/cpt-cd/piece-compta/ref-num: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhSscoll-cle:buffer-value(), vhCpt-cd:buffer-value(), vhPiece-compta:buffer-value(), vhRef-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cantva:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCantva private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cantva for cantva.

    create query vhttquery.
    vhttBuffer = ghttCantva:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCantva:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cantva.
            if not outils:copyValidField(buffer cantva:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCantva private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhSscoll-cle    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define variable vhPiece-compta    as handle  no-undo.
    define variable vhRef-num    as handle  no-undo.
    define buffer cantva for cantva.

    create query vhttquery.
    vhttBuffer = ghttCantva:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCantva:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhSscoll-cle, output vhCpt-cd, output vhPiece-compta, output vhRef-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cantva exclusive-lock
                where rowid(Cantva) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cantva:handle, 'soc-cd/etab-cd/sscoll-cle/cpt-cd/piece-compta/ref-num: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhSscoll-cle:buffer-value(), vhCpt-cd:buffer-value(), vhPiece-compta:buffer-value(), vhRef-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cantva no-error.
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

