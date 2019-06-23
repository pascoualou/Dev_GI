/*------------------------------------------------------------------------
File        : csdsel_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table csdsel
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/csdsel.i}
{application/include/error.i}
define variable ghttcsdsel as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phOrder-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/order-num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'order-num' then phOrder-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCsdsel private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCsdsel.
    run updateCsdsel.
    run createCsdsel.
end procedure.

procedure setCsdsel:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCsdsel.
    ghttCsdsel = phttCsdsel.
    run crudCsdsel.
    delete object phttCsdsel.
end procedure.

procedure readCsdsel:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table csdsel Solde des dossiers: ecran de selection
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter piOrder-num as integer    no-undo.
    define input parameter table-handle phttCsdsel.
    define variable vhttBuffer as handle no-undo.
    define buffer csdsel for csdsel.

    vhttBuffer = phttCsdsel:default-buffer-handle.
    for first csdsel no-lock
        where csdsel.soc-cd = piSoc-cd
          and csdsel.etab-cd = piEtab-cd
          and csdsel.order-num = piOrder-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer csdsel:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCsdsel no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCsdsel:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table csdsel Solde des dossiers: ecran de selection
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter table-handle phttCsdsel.
    define variable vhttBuffer as handle  no-undo.
    define buffer csdsel for csdsel.

    vhttBuffer = phttCsdsel:default-buffer-handle.
    if piEtab-cd = ?
    then for each csdsel no-lock
        where csdsel.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer csdsel:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each csdsel no-lock
        where csdsel.soc-cd = piSoc-cd
          and csdsel.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer csdsel:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCsdsel no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCsdsel private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhOrder-num    as handle  no-undo.
    define buffer csdsel for csdsel.

    create query vhttquery.
    vhttBuffer = ghttCsdsel:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCsdsel:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhOrder-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first csdsel exclusive-lock
                where rowid(csdsel) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer csdsel:handle, 'soc-cd/etab-cd/order-num: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhOrder-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer csdsel:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCsdsel private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer csdsel for csdsel.

    create query vhttquery.
    vhttBuffer = ghttCsdsel:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCsdsel:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create csdsel.
            if not outils:copyValidField(buffer csdsel:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCsdsel private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhOrder-num    as handle  no-undo.
    define buffer csdsel for csdsel.

    create query vhttquery.
    vhttBuffer = ghttCsdsel:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCsdsel:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhOrder-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first csdsel exclusive-lock
                where rowid(Csdsel) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer csdsel:handle, 'soc-cd/etab-cd/order-num: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhOrder-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete csdsel no-error.
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

