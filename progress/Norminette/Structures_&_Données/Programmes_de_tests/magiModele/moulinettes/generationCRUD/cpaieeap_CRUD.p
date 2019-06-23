/*------------------------------------------------------------------------
File        : cpaieeap_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cpaieeap
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cpaieeap.i}
{application/include/error.i}
define variable ghttcpaieeap as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phJou-cd as handle, output phPrd-cd as handle, output phPrd-num as handle, output phPiece-int as handle, output phLig-tot as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig-tot, 
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
            when 'lig-tot' then phLig-tot = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCpaieeap private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCpaieeap.
    run updateCpaieeap.
    run createCpaieeap.
end procedure.

procedure setCpaieeap:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCpaieeap.
    ghttCpaieeap = phttCpaieeap.
    run crudCpaieeap.
    delete object phttCpaieeap.
end procedure.

procedure readCpaieeap:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cpaieeap Fichier Preparation des Paiements Fournisseurs (E.A.P.)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcJou-cd    as character  no-undo.
    define input parameter piPrd-cd    as integer    no-undo.
    define input parameter piPrd-num   as integer    no-undo.
    define input parameter piPiece-int as integer    no-undo.
    define input parameter piLig-tot   as integer    no-undo.
    define input parameter table-handle phttCpaieeap.
    define variable vhttBuffer as handle no-undo.
    define buffer cpaieeap for cpaieeap.

    vhttBuffer = phttCpaieeap:default-buffer-handle.
    for first cpaieeap no-lock
        where cpaieeap.soc-cd = piSoc-cd
          and cpaieeap.etab-cd = piEtab-cd
          and cpaieeap.jou-cd = pcJou-cd
          and cpaieeap.prd-cd = piPrd-cd
          and cpaieeap.prd-num = piPrd-num
          and cpaieeap.piece-int = piPiece-int
          and cpaieeap.lig-tot = piLig-tot:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cpaieeap:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCpaieeap no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCpaieeap:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cpaieeap Fichier Preparation des Paiements Fournisseurs (E.A.P.)
    Notes  : service externe. Critère piPiece-int = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcJou-cd    as character  no-undo.
    define input parameter piPrd-cd    as integer    no-undo.
    define input parameter piPrd-num   as integer    no-undo.
    define input parameter piPiece-int as integer    no-undo.
    define input parameter table-handle phttCpaieeap.
    define variable vhttBuffer as handle  no-undo.
    define buffer cpaieeap for cpaieeap.

    vhttBuffer = phttCpaieeap:default-buffer-handle.
    if piPiece-int = ?
    then for each cpaieeap no-lock
        where cpaieeap.soc-cd = piSoc-cd
          and cpaieeap.etab-cd = piEtab-cd
          and cpaieeap.jou-cd = pcJou-cd
          and cpaieeap.prd-cd = piPrd-cd
          and cpaieeap.prd-num = piPrd-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cpaieeap:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cpaieeap no-lock
        where cpaieeap.soc-cd = piSoc-cd
          and cpaieeap.etab-cd = piEtab-cd
          and cpaieeap.jou-cd = pcJou-cd
          and cpaieeap.prd-cd = piPrd-cd
          and cpaieeap.prd-num = piPrd-num
          and cpaieeap.piece-int = piPiece-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cpaieeap:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCpaieeap no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCpaieeap private:
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
    define variable vhLig-tot    as handle  no-undo.
    define buffer cpaieeap for cpaieeap.

    create query vhttquery.
    vhttBuffer = ghttCpaieeap:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCpaieeap:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-int, output vhLig-tot).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cpaieeap exclusive-lock
                where rowid(cpaieeap) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cpaieeap:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig-tot: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-int:buffer-value(), vhLig-tot:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cpaieeap:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCpaieeap private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cpaieeap for cpaieeap.

    create query vhttquery.
    vhttBuffer = ghttCpaieeap:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCpaieeap:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cpaieeap.
            if not outils:copyValidField(buffer cpaieeap:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCpaieeap private:
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
    define variable vhLig-tot    as handle  no-undo.
    define buffer cpaieeap for cpaieeap.

    create query vhttquery.
    vhttBuffer = ghttCpaieeap:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCpaieeap:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-int, output vhLig-tot).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cpaieeap exclusive-lock
                where rowid(Cpaieeap) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cpaieeap:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig-tot: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-int:buffer-value(), vhLig-tot:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cpaieeap no-error.
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

