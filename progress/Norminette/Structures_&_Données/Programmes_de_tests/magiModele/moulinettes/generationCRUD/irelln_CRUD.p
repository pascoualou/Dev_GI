/*------------------------------------------------------------------------
File        : irelln_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table irelln
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/irelln.i}
{application/include/error.i}
define variable ghttirelln as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phJou-cd as handle, output phPrd-cd as handle, output phPrd-num as handle, output phPiece-int as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int, 
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
       end case.
    end.
end function.

procedure crudIrelln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIrelln.
    run updateIrelln.
    run createIrelln.
end procedure.

procedure setIrelln:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIrelln.
    ghttIrelln = phttIrelln.
    run crudIrelln.
    delete object phttIrelln.
end procedure.

procedure readIrelln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table irelln Lettres de relances a editer
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcJou-cd    as character  no-undo.
    define input parameter piPrd-cd    as integer    no-undo.
    define input parameter piPrd-num   as integer    no-undo.
    define input parameter piPiece-int as integer    no-undo.
    define input parameter table-handle phttIrelln.
    define variable vhttBuffer as handle no-undo.
    define buffer irelln for irelln.

    vhttBuffer = phttIrelln:default-buffer-handle.
    for first irelln no-lock
        where irelln.soc-cd = piSoc-cd
          and irelln.etab-cd = piEtab-cd
          and irelln.jou-cd = pcJou-cd
          and irelln.prd-cd = piPrd-cd
          and irelln.prd-num = piPrd-num
          and irelln.piece-int = piPiece-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer irelln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIrelln no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIrelln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table irelln Lettres de relances a editer
    Notes  : service externe. Critère piPrd-num = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcJou-cd    as character  no-undo.
    define input parameter piPrd-cd    as integer    no-undo.
    define input parameter piPrd-num   as integer    no-undo.
    define input parameter table-handle phttIrelln.
    define variable vhttBuffer as handle  no-undo.
    define buffer irelln for irelln.

    vhttBuffer = phttIrelln:default-buffer-handle.
    if piPrd-num = ?
    then for each irelln no-lock
        where irelln.soc-cd = piSoc-cd
          and irelln.etab-cd = piEtab-cd
          and irelln.jou-cd = pcJou-cd
          and irelln.prd-cd = piPrd-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer irelln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each irelln no-lock
        where irelln.soc-cd = piSoc-cd
          and irelln.etab-cd = piEtab-cd
          and irelln.jou-cd = pcJou-cd
          and irelln.prd-cd = piPrd-cd
          and irelln.prd-num = piPrd-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer irelln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIrelln no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIrelln private:
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
    define buffer irelln for irelln.

    create query vhttquery.
    vhttBuffer = ghttIrelln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIrelln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-int).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first irelln exclusive-lock
                where rowid(irelln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer irelln:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-int:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer irelln:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIrelln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer irelln for irelln.

    create query vhttquery.
    vhttBuffer = ghttIrelln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIrelln:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create irelln.
            if not outils:copyValidField(buffer irelln:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIrelln private:
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
    define buffer irelln for irelln.

    create query vhttquery.
    vhttBuffer = ghttIrelln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIrelln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-int).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first irelln exclusive-lock
                where rowid(Irelln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer irelln:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-int:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete irelln no-error.
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

