/*------------------------------------------------------------------------
File        : cimoinv_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cimoinv
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cimoinv.i}
{application/include/error.i}
define variable ghttcimoinv as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phNum-int as handle, output phInvest-cle as handle, output phMat-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/num-int/invest-cle/mat-num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'num-int' then phNum-int = phBuffer:buffer-field(vi).
            when 'invest-cle' then phInvest-cle = phBuffer:buffer-field(vi).
            when 'mat-num' then phMat-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCimoinv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCimoinv.
    run updateCimoinv.
    run createCimoinv.
end procedure.

procedure setCimoinv:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCimoinv.
    ghttCimoinv = phttCimoinv.
    run crudCimoinv.
    delete object phttCimoinv.
end procedure.

procedure readCimoinv:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cimoinv inventaire immo
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter piNum-int    as integer    no-undo.
    define input parameter pcInvest-cle as character  no-undo.
    define input parameter pcMat-num    as character  no-undo.
    define input parameter table-handle phttCimoinv.
    define variable vhttBuffer as handle no-undo.
    define buffer cimoinv for cimoinv.

    vhttBuffer = phttCimoinv:default-buffer-handle.
    for first cimoinv no-lock
        where cimoinv.soc-cd = piSoc-cd
          and cimoinv.etab-cd = piEtab-cd
          and cimoinv.num-int = piNum-int
          and cimoinv.invest-cle = pcInvest-cle
          and cimoinv.mat-num = pcMat-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cimoinv:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCimoinv no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCimoinv:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cimoinv inventaire immo
    Notes  : service externe. Critère pcInvest-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter piNum-int    as integer    no-undo.
    define input parameter pcInvest-cle as character  no-undo.
    define input parameter table-handle phttCimoinv.
    define variable vhttBuffer as handle  no-undo.
    define buffer cimoinv for cimoinv.

    vhttBuffer = phttCimoinv:default-buffer-handle.
    if pcInvest-cle = ?
    then for each cimoinv no-lock
        where cimoinv.soc-cd = piSoc-cd
          and cimoinv.etab-cd = piEtab-cd
          and cimoinv.num-int = piNum-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cimoinv:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cimoinv no-lock
        where cimoinv.soc-cd = piSoc-cd
          and cimoinv.etab-cd = piEtab-cd
          and cimoinv.num-int = piNum-int
          and cimoinv.invest-cle = pcInvest-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cimoinv:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCimoinv no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCimoinv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define variable vhInvest-cle    as handle  no-undo.
    define variable vhMat-num    as handle  no-undo.
    define buffer cimoinv for cimoinv.

    create query vhttquery.
    vhttBuffer = ghttCimoinv:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCimoinv:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNum-int, output vhInvest-cle, output vhMat-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cimoinv exclusive-lock
                where rowid(cimoinv) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cimoinv:handle, 'soc-cd/etab-cd/num-int/invest-cle/mat-num: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNum-int:buffer-value(), vhInvest-cle:buffer-value(), vhMat-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cimoinv:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCimoinv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cimoinv for cimoinv.

    create query vhttquery.
    vhttBuffer = ghttCimoinv:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCimoinv:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cimoinv.
            if not outils:copyValidField(buffer cimoinv:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCimoinv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define variable vhInvest-cle    as handle  no-undo.
    define variable vhMat-num    as handle  no-undo.
    define buffer cimoinv for cimoinv.

    create query vhttquery.
    vhttBuffer = ghttCimoinv:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCimoinv:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNum-int, output vhInvest-cle, output vhMat-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cimoinv exclusive-lock
                where rowid(Cimoinv) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cimoinv:handle, 'soc-cd/etab-cd/num-int/invest-cle/mat-num: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNum-int:buffer-value(), vhInvest-cle:buffer-value(), vhMat-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cimoinv no-error.
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

