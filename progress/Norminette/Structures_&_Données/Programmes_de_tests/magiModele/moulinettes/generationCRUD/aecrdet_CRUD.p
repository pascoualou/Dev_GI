/*------------------------------------------------------------------------
File        : aecrdet_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table aecrdet
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/aecrdet.i}
{application/include/error.i}
define variable ghttaecrdet as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phJou-cd as handle, output phPrd-cd as handle, output phPrd-num as handle, output phPiece-int as handle, output phLig as handle, output phCdfam as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig/cdfam, 
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
            when 'cdfam' then phCdfam = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAecrdet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAecrdet.
    run updateAecrdet.
    run createAecrdet.
end procedure.

procedure setAecrdet:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAecrdet.
    ghttAecrdet = phttAecrdet.
    run crudAecrdet.
    delete object phttAecrdet.
end procedure.

procedure readAecrdet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table aecrdet Détails d'écritures
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcJou-cd    as character  no-undo.
    define input parameter piPrd-cd    as integer    no-undo.
    define input parameter piPrd-num   as integer    no-undo.
    define input parameter piPiece-int as integer    no-undo.
    define input parameter piLig       as integer    no-undo.
    define input parameter piCdfam     as integer    no-undo.
    define input parameter table-handle phttAecrdet.
    define variable vhttBuffer as handle no-undo.
    define buffer aecrdet for aecrdet.

    vhttBuffer = phttAecrdet:default-buffer-handle.
    for first aecrdet no-lock
        where aecrdet.soc-cd = piSoc-cd
          and aecrdet.etab-cd = piEtab-cd
          and aecrdet.jou-cd = pcJou-cd
          and aecrdet.prd-cd = piPrd-cd
          and aecrdet.prd-num = piPrd-num
          and aecrdet.piece-int = piPiece-int
          and aecrdet.lig = piLig
          and aecrdet.cdfam = piCdfam:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aecrdet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAecrdet no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAecrdet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table aecrdet Détails d'écritures
    Notes  : service externe. Critère piLig = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcJou-cd    as character  no-undo.
    define input parameter piPrd-cd    as integer    no-undo.
    define input parameter piPrd-num   as integer    no-undo.
    define input parameter piPiece-int as integer    no-undo.
    define input parameter piLig       as integer    no-undo.
    define input parameter table-handle phttAecrdet.
    define variable vhttBuffer as handle  no-undo.
    define buffer aecrdet for aecrdet.

    vhttBuffer = phttAecrdet:default-buffer-handle.
    if piLig = ?
    then for each aecrdet no-lock
        where aecrdet.soc-cd = piSoc-cd
          and aecrdet.etab-cd = piEtab-cd
          and aecrdet.jou-cd = pcJou-cd
          and aecrdet.prd-cd = piPrd-cd
          and aecrdet.prd-num = piPrd-num
          and aecrdet.piece-int = piPiece-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aecrdet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each aecrdet no-lock
        where aecrdet.soc-cd = piSoc-cd
          and aecrdet.etab-cd = piEtab-cd
          and aecrdet.jou-cd = pcJou-cd
          and aecrdet.prd-cd = piPrd-cd
          and aecrdet.prd-num = piPrd-num
          and aecrdet.piece-int = piPiece-int
          and aecrdet.lig = piLig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aecrdet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAecrdet no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAecrdet private:
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
    define variable vhCdfam    as handle  no-undo.
    define buffer aecrdet for aecrdet.

    create query vhttquery.
    vhttBuffer = ghttAecrdet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAecrdet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-int, output vhLig, output vhCdfam).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aecrdet exclusive-lock
                where rowid(aecrdet) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aecrdet:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig/cdfam: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-int:buffer-value(), vhLig:buffer-value(), vhCdfam:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer aecrdet:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAecrdet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer aecrdet for aecrdet.

    create query vhttquery.
    vhttBuffer = ghttAecrdet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAecrdet:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create aecrdet.
            if not outils:copyValidField(buffer aecrdet:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAecrdet private:
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
    define variable vhCdfam    as handle  no-undo.
    define buffer aecrdet for aecrdet.

    create query vhttquery.
    vhttBuffer = ghttAecrdet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAecrdet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-int, output vhLig, output vhCdfam).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aecrdet exclusive-lock
                where rowid(Aecrdet) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aecrdet:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig/cdfam: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-int:buffer-value(), vhLig:buffer-value(), vhCdfam:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete aecrdet no-error.
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

