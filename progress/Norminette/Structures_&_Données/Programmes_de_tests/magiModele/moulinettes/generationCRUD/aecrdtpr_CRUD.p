/*------------------------------------------------------------------------
File        : aecrdtpr_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table aecrdtpr
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/aecrdtpr.i}
{application/include/error.i}
define variable ghttaecrdtpr as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phJou-cd as handle, output phPrd-cd as handle, output phPrd-num as handle, output phPiece-int as handle, output phLig as handle, output phCdrub as handle, output phCdlib as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig/cdrub/cdlib, 
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
            when 'cdrub' then phCdrub = phBuffer:buffer-field(vi).
            when 'cdlib' then phCdlib = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAecrdtpr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAecrdtpr.
    run updateAecrdtpr.
    run createAecrdtpr.
end procedure.

procedure setAecrdtpr:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAecrdtpr.
    ghttAecrdtpr = phttAecrdtpr.
    run crudAecrdtpr.
    delete object phttAecrdtpr.
end procedure.

procedure readAecrdtpr:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table aecrdtpr Détails d'écritures Provisions
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcJou-cd    as character  no-undo.
    define input parameter piPrd-cd    as integer    no-undo.
    define input parameter piPrd-num   as integer    no-undo.
    define input parameter piPiece-int as integer    no-undo.
    define input parameter piLig       as integer    no-undo.
    define input parameter piCdrub     as integer    no-undo.
    define input parameter piCdlib     as integer    no-undo.
    define input parameter table-handle phttAecrdtpr.
    define variable vhttBuffer as handle no-undo.
    define buffer aecrdtpr for aecrdtpr.

    vhttBuffer = phttAecrdtpr:default-buffer-handle.
    for first aecrdtpr no-lock
        where aecrdtpr.soc-cd = piSoc-cd
          and aecrdtpr.etab-cd = piEtab-cd
          and aecrdtpr.jou-cd = pcJou-cd
          and aecrdtpr.prd-cd = piPrd-cd
          and aecrdtpr.prd-num = piPrd-num
          and aecrdtpr.piece-int = piPiece-int
          and aecrdtpr.lig = piLig
          and aecrdtpr.cdrub = piCdrub
          and aecrdtpr.cdlib = piCdlib:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aecrdtpr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAecrdtpr no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAecrdtpr:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table aecrdtpr Détails d'écritures Provisions
    Notes  : service externe. Critère piCdrub = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcJou-cd    as character  no-undo.
    define input parameter piPrd-cd    as integer    no-undo.
    define input parameter piPrd-num   as integer    no-undo.
    define input parameter piPiece-int as integer    no-undo.
    define input parameter piLig       as integer    no-undo.
    define input parameter piCdrub     as integer    no-undo.
    define input parameter table-handle phttAecrdtpr.
    define variable vhttBuffer as handle  no-undo.
    define buffer aecrdtpr for aecrdtpr.

    vhttBuffer = phttAecrdtpr:default-buffer-handle.
    if piCdrub = ?
    then for each aecrdtpr no-lock
        where aecrdtpr.soc-cd = piSoc-cd
          and aecrdtpr.etab-cd = piEtab-cd
          and aecrdtpr.jou-cd = pcJou-cd
          and aecrdtpr.prd-cd = piPrd-cd
          and aecrdtpr.prd-num = piPrd-num
          and aecrdtpr.piece-int = piPiece-int
          and aecrdtpr.lig = piLig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aecrdtpr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each aecrdtpr no-lock
        where aecrdtpr.soc-cd = piSoc-cd
          and aecrdtpr.etab-cd = piEtab-cd
          and aecrdtpr.jou-cd = pcJou-cd
          and aecrdtpr.prd-cd = piPrd-cd
          and aecrdtpr.prd-num = piPrd-num
          and aecrdtpr.piece-int = piPiece-int
          and aecrdtpr.lig = piLig
          and aecrdtpr.cdrub = piCdrub:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aecrdtpr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAecrdtpr no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAecrdtpr private:
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
    define variable vhCdrub    as handle  no-undo.
    define variable vhCdlib    as handle  no-undo.
    define buffer aecrdtpr for aecrdtpr.

    create query vhttquery.
    vhttBuffer = ghttAecrdtpr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAecrdtpr:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-int, output vhLig, output vhCdrub, output vhCdlib).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aecrdtpr exclusive-lock
                where rowid(aecrdtpr) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aecrdtpr:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig/cdrub/cdlib: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-int:buffer-value(), vhLig:buffer-value(), vhCdrub:buffer-value(), vhCdlib:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer aecrdtpr:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAecrdtpr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer aecrdtpr for aecrdtpr.

    create query vhttquery.
    vhttBuffer = ghttAecrdtpr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAecrdtpr:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create aecrdtpr.
            if not outils:copyValidField(buffer aecrdtpr:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAecrdtpr private:
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
    define variable vhCdrub    as handle  no-undo.
    define variable vhCdlib    as handle  no-undo.
    define buffer aecrdtpr for aecrdtpr.

    create query vhttquery.
    vhttBuffer = ghttAecrdtpr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAecrdtpr:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-int, output vhLig, output vhCdrub, output vhCdlib).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aecrdtpr exclusive-lock
                where rowid(Aecrdtpr) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aecrdtpr:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig/cdrub/cdlib: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-int:buffer-value(), vhLig:buffer-value(), vhCdrub:buffer-value(), vhCdlib:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete aecrdtpr no-error.
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

