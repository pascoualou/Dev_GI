/*------------------------------------------------------------------------
File        : cinechm_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cinechm
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cinechm.i}
{application/include/error.i}
define variable ghttcinechm as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phType-invest as handle, output phNum-int as handle, output phOrder-num as handle, output phMat-num as handle, output phProjection as handle, output phMois-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/type-invest/num-int/order-num/mat-num/projection/mois-num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'type-invest' then phType-invest = phBuffer:buffer-field(vi).
            when 'num-int' then phNum-int = phBuffer:buffer-field(vi).
            when 'order-num' then phOrder-num = phBuffer:buffer-field(vi).
            when 'mat-num' then phMat-num = phBuffer:buffer-field(vi).
            when 'projection' then phProjection = phBuffer:buffer-field(vi).
            when 'mois-num' then phMois-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCinechm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCinechm.
    run updateCinechm.
    run createCinechm.
end procedure.

procedure setCinechm:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCinechm.
    ghttCinechm = phttCinechm.
    run crudCinechm.
    delete object phttCinechm.
end procedure.

procedure readCinechm:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cinechm echeance mensuelle
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter piType-invest as integer    no-undo.
    define input parameter piNum-int     as integer    no-undo.
    define input parameter piOrder-num   as integer    no-undo.
    define input parameter pcMat-num     as character  no-undo.
    define input parameter plProjection  as logical    no-undo.
    define input parameter piMois-num    as integer    no-undo.
    define input parameter table-handle phttCinechm.
    define variable vhttBuffer as handle no-undo.
    define buffer cinechm for cinechm.

    vhttBuffer = phttCinechm:default-buffer-handle.
    for first cinechm no-lock
        where cinechm.soc-cd = piSoc-cd
          and cinechm.etab-cd = piEtab-cd
          and cinechm.type-invest = piType-invest
          and cinechm.num-int = piNum-int
          and cinechm.order-num = piOrder-num
          and cinechm.mat-num = pcMat-num
          and cinechm.projection = plProjection
          and cinechm.mois-num = piMois-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinechm:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCinechm no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCinechm:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cinechm echeance mensuelle
    Notes  : service externe. Critère plProjection = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter piType-invest as integer    no-undo.
    define input parameter piNum-int     as integer    no-undo.
    define input parameter piOrder-num   as integer    no-undo.
    define input parameter pcMat-num     as character  no-undo.
    define input parameter plProjection  as logical    no-undo.
    define input parameter table-handle phttCinechm.
    define variable vhttBuffer as handle  no-undo.
    define buffer cinechm for cinechm.

    vhttBuffer = phttCinechm:default-buffer-handle.
    if plProjection = ?
    then for each cinechm no-lock
        where cinechm.soc-cd = piSoc-cd
          and cinechm.etab-cd = piEtab-cd
          and cinechm.type-invest = piType-invest
          and cinechm.num-int = piNum-int
          and cinechm.order-num = piOrder-num
          and cinechm.mat-num = pcMat-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinechm:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cinechm no-lock
        where cinechm.soc-cd = piSoc-cd
          and cinechm.etab-cd = piEtab-cd
          and cinechm.type-invest = piType-invest
          and cinechm.num-int = piNum-int
          and cinechm.order-num = piOrder-num
          and cinechm.mat-num = pcMat-num
          and cinechm.projection = plProjection:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinechm:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCinechm no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCinechm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhType-invest    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define variable vhOrder-num    as handle  no-undo.
    define variable vhMat-num    as handle  no-undo.
    define variable vhProjection    as handle  no-undo.
    define variable vhMois-num    as handle  no-undo.
    define buffer cinechm for cinechm.

    create query vhttquery.
    vhttBuffer = ghttCinechm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCinechm:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhType-invest, output vhNum-int, output vhOrder-num, output vhMat-num, output vhProjection, output vhMois-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cinechm exclusive-lock
                where rowid(cinechm) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cinechm:handle, 'soc-cd/etab-cd/type-invest/num-int/order-num/mat-num/projection/mois-num: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhType-invest:buffer-value(), vhNum-int:buffer-value(), vhOrder-num:buffer-value(), vhMat-num:buffer-value(), vhProjection:buffer-value(), vhMois-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cinechm:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCinechm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cinechm for cinechm.

    create query vhttquery.
    vhttBuffer = ghttCinechm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCinechm:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cinechm.
            if not outils:copyValidField(buffer cinechm:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCinechm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhType-invest    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define variable vhOrder-num    as handle  no-undo.
    define variable vhMat-num    as handle  no-undo.
    define variable vhProjection    as handle  no-undo.
    define variable vhMois-num    as handle  no-undo.
    define buffer cinechm for cinechm.

    create query vhttquery.
    vhttBuffer = ghttCinechm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCinechm:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhType-invest, output vhNum-int, output vhOrder-num, output vhMat-num, output vhProjection, output vhMois-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cinechm exclusive-lock
                where rowid(Cinechm) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cinechm:handle, 'soc-cd/etab-cd/type-invest/num-int/order-num/mat-num/projection/mois-num: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhType-invest:buffer-value(), vhNum-int:buffer-value(), vhOrder-num:buffer-value(), vhMat-num:buffer-value(), vhProjection:buffer-value(), vhMois-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cinechm no-error.
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

