/*------------------------------------------------------------------------
File        : cpardt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cpardt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cpardt.i}
{application/include/error.i}
define variable ghttcpardt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phOrdre-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/ordre-num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'ordre-num' then phOrdre-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCpardt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCpardt.
    run updateCpardt.
    run createCpardt.
end procedure.

procedure setCpardt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCpardt.
    ghttCpardt = phttCpardt.
    run crudCpardt.
    delete object phttCpardt.
end procedure.

procedure readCpardt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cpardt Fichier parametres encaisst/debit TVA
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piOrdre-num as integer    no-undo.
    define input parameter table-handle phttCpardt.
    define variable vhttBuffer as handle no-undo.
    define buffer cpardt for cpardt.

    vhttBuffer = phttCpardt:default-buffer-handle.
    for first cpardt no-lock
        where cpardt.soc-cd = piSoc-cd
          and cpardt.ordre-num = piOrdre-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cpardt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCpardt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCpardt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cpardt Fichier parametres encaisst/debit TVA
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter table-handle phttCpardt.
    define variable vhttBuffer as handle  no-undo.
    define buffer cpardt for cpardt.

    vhttBuffer = phttCpardt:default-buffer-handle.
    if piSoc-cd = ?
    then for each cpardt no-lock
        where cpardt.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cpardt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cpardt no-lock
        where cpardt.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cpardt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCpardt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCpardt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhOrdre-num    as handle  no-undo.
    define buffer cpardt for cpardt.

    create query vhttquery.
    vhttBuffer = ghttCpardt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCpardt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhOrdre-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cpardt exclusive-lock
                where rowid(cpardt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cpardt:handle, 'soc-cd/ordre-num: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhOrdre-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cpardt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCpardt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cpardt for cpardt.

    create query vhttquery.
    vhttBuffer = ghttCpardt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCpardt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cpardt.
            if not outils:copyValidField(buffer cpardt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCpardt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhOrdre-num    as handle  no-undo.
    define buffer cpardt for cpardt.

    create query vhttquery.
    vhttBuffer = ghttCpardt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCpardt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhOrdre-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cpardt exclusive-lock
                where rowid(Cpardt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cpardt:handle, 'soc-cd/ordre-num: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhOrdre-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cpardt no-error.
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

