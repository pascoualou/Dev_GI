/*------------------------------------------------------------------------
File        : cpaiepre_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cpaiepre
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cpaiepre.i}
{application/include/error.i}
define variable ghttcpaiepre as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phJou-cd as handle, output phPrd-cd as handle, output phPrd-num as handle, output phPiece-int as handle, output phLig as handle, output phChrono as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig/chrono, 
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
            when 'chrono' then phChrono = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCpaiepre private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCpaiepre.
    run updateCpaiepre.
    run createCpaiepre.
end procedure.

procedure setCpaiepre:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCpaiepre.
    ghttCpaiepre = phttCpaiepre.
    run crudCpaiepre.
    delete object phttCpaiepre.
end procedure.

procedure readCpaiepre:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cpaiepre Fichier Preparation des Paiements Fournisseurs (Ecritures)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcJou-cd    as character  no-undo.
    define input parameter piPrd-cd    as integer    no-undo.
    define input parameter piPrd-num   as integer    no-undo.
    define input parameter piPiece-int as integer    no-undo.
    define input parameter piLig       as integer    no-undo.
    define input parameter piChrono    as integer    no-undo.
    define input parameter table-handle phttCpaiepre.
    define variable vhttBuffer as handle no-undo.
    define buffer cpaiepre for cpaiepre.

    vhttBuffer = phttCpaiepre:default-buffer-handle.
    for first cpaiepre no-lock
        where cpaiepre.soc-cd = piSoc-cd
          and cpaiepre.etab-cd = piEtab-cd
          and cpaiepre.jou-cd = pcJou-cd
          and cpaiepre.prd-cd = piPrd-cd
          and cpaiepre.prd-num = piPrd-num
          and cpaiepre.piece-int = piPiece-int
          and cpaiepre.lig = piLig
          and cpaiepre.chrono = piChrono:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cpaiepre:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCpaiepre no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCpaiepre:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cpaiepre Fichier Preparation des Paiements Fournisseurs (Ecritures)
    Notes  : service externe. Critère piLig = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcJou-cd    as character  no-undo.
    define input parameter piPrd-cd    as integer    no-undo.
    define input parameter piPrd-num   as integer    no-undo.
    define input parameter piPiece-int as integer    no-undo.
    define input parameter piLig       as integer    no-undo.
    define input parameter table-handle phttCpaiepre.
    define variable vhttBuffer as handle  no-undo.
    define buffer cpaiepre for cpaiepre.

    vhttBuffer = phttCpaiepre:default-buffer-handle.
    if piLig = ?
    then for each cpaiepre no-lock
        where cpaiepre.soc-cd = piSoc-cd
          and cpaiepre.etab-cd = piEtab-cd
          and cpaiepre.jou-cd = pcJou-cd
          and cpaiepre.prd-cd = piPrd-cd
          and cpaiepre.prd-num = piPrd-num
          and cpaiepre.piece-int = piPiece-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cpaiepre:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cpaiepre no-lock
        where cpaiepre.soc-cd = piSoc-cd
          and cpaiepre.etab-cd = piEtab-cd
          and cpaiepre.jou-cd = pcJou-cd
          and cpaiepre.prd-cd = piPrd-cd
          and cpaiepre.prd-num = piPrd-num
          and cpaiepre.piece-int = piPiece-int
          and cpaiepre.lig = piLig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cpaiepre:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCpaiepre no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCpaiepre private:
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
    define variable vhChrono    as handle  no-undo.
    define buffer cpaiepre for cpaiepre.

    create query vhttquery.
    vhttBuffer = ghttCpaiepre:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCpaiepre:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-int, output vhLig, output vhChrono).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cpaiepre exclusive-lock
                where rowid(cpaiepre) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cpaiepre:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig/chrono: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-int:buffer-value(), vhLig:buffer-value(), vhChrono:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cpaiepre:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCpaiepre private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cpaiepre for cpaiepre.

    create query vhttquery.
    vhttBuffer = ghttCpaiepre:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCpaiepre:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cpaiepre.
            if not outils:copyValidField(buffer cpaiepre:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCpaiepre private:
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
    define variable vhChrono    as handle  no-undo.
    define buffer cpaiepre for cpaiepre.

    create query vhttquery.
    vhttBuffer = ghttCpaiepre:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCpaiepre:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-int, output vhLig, output vhChrono).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cpaiepre exclusive-lock
                where rowid(Cpaiepre) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cpaiepre:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig/chrono: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-int:buffer-value(), vhLig:buffer-value(), vhChrono:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cpaiepre no-error.
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

