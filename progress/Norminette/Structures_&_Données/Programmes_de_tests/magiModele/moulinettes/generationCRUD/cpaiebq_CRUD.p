/*------------------------------------------------------------------------
File        : cpaiebq_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cpaiebq
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cpaiebq.i}
{application/include/error.i}
define variable ghttcpaiebq as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phChrono as handle, output phOrder-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/chrono/order-num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'chrono' then phChrono = phBuffer:buffer-field(vi).
            when 'order-num' then phOrder-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCpaiebq private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCpaiebq.
    run updateCpaiebq.
    run createCpaiebq.
end procedure.

procedure setCpaiebq:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCpaiebq.
    ghttCpaiebq = phttCpaiebq.
    run crudCpaiebq.
    delete object phttCpaiebq.
end procedure.

procedure readCpaiebq:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cpaiebq Fichier Repartition par Banque (Prepaparation des paiements fournisseurs)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter piChrono    as integer    no-undo.
    define input parameter piOrder-num as integer    no-undo.
    define input parameter table-handle phttCpaiebq.
    define variable vhttBuffer as handle no-undo.
    define buffer cpaiebq for cpaiebq.

    vhttBuffer = phttCpaiebq:default-buffer-handle.
    for first cpaiebq no-lock
        where cpaiebq.soc-cd = piSoc-cd
          and cpaiebq.etab-cd = piEtab-cd
          and cpaiebq.chrono = piChrono
          and cpaiebq.order-num = piOrder-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cpaiebq:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCpaiebq no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCpaiebq:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cpaiebq Fichier Repartition par Banque (Prepaparation des paiements fournisseurs)
    Notes  : service externe. Critère piChrono = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter piChrono    as integer    no-undo.
    define input parameter table-handle phttCpaiebq.
    define variable vhttBuffer as handle  no-undo.
    define buffer cpaiebq for cpaiebq.

    vhttBuffer = phttCpaiebq:default-buffer-handle.
    if piChrono = ?
    then for each cpaiebq no-lock
        where cpaiebq.soc-cd = piSoc-cd
          and cpaiebq.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cpaiebq:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cpaiebq no-lock
        where cpaiebq.soc-cd = piSoc-cd
          and cpaiebq.etab-cd = piEtab-cd
          and cpaiebq.chrono = piChrono:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cpaiebq:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCpaiebq no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCpaiebq private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhChrono    as handle  no-undo.
    define variable vhOrder-num    as handle  no-undo.
    define buffer cpaiebq for cpaiebq.

    create query vhttquery.
    vhttBuffer = ghttCpaiebq:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCpaiebq:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhChrono, output vhOrder-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cpaiebq exclusive-lock
                where rowid(cpaiebq) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cpaiebq:handle, 'soc-cd/etab-cd/chrono/order-num: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhChrono:buffer-value(), vhOrder-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cpaiebq:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCpaiebq private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cpaiebq for cpaiebq.

    create query vhttquery.
    vhttBuffer = ghttCpaiebq:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCpaiebq:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cpaiebq.
            if not outils:copyValidField(buffer cpaiebq:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCpaiebq private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhChrono    as handle  no-undo.
    define variable vhOrder-num    as handle  no-undo.
    define buffer cpaiebq for cpaiebq.

    create query vhttquery.
    vhttBuffer = ghttCpaiebq:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCpaiebq:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhChrono, output vhOrder-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cpaiebq exclusive-lock
                where rowid(Cpaiebq) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cpaiebq:handle, 'soc-cd/etab-cd/chrono/order-num: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhChrono:buffer-value(), vhOrder-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cpaiebq no-error.
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

