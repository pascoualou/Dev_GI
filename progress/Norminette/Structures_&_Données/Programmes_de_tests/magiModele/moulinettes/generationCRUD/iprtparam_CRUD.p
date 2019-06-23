/*------------------------------------------------------------------------
File        : iprtparam_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iprtparam
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iprtparam.i}
{application/include/error.i}
define variable ghttiprtparam as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phUtil-num as handle, output phOrder-num as handle, output phPrg-name as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur util-num/order-num/prg-name, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'util-num' then phUtil-num = phBuffer:buffer-field(vi).
            when 'order-num' then phOrder-num = phBuffer:buffer-field(vi).
            when 'prg-name' then phPrg-name = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIprtparam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIprtparam.
    run updateIprtparam.
    run createIprtparam.
end procedure.

procedure setIprtparam:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIprtparam.
    ghttIprtparam = phttIprtparam.
    run crudIprtparam.
    delete object phttIprtparam.
end procedure.

procedure readIprtparam:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iprtparam 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcUtil-num  as character  no-undo.
    define input parameter piOrder-num as integer    no-undo.
    define input parameter pcPrg-name  as character  no-undo.
    define input parameter table-handle phttIprtparam.
    define variable vhttBuffer as handle no-undo.
    define buffer iprtparam for iprtparam.

    vhttBuffer = phttIprtparam:default-buffer-handle.
    for first iprtparam no-lock
        where iprtparam.util-num = pcUtil-num
          and iprtparam.order-num = piOrder-num
          and iprtparam.prg-name = pcPrg-name:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iprtparam:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIprtparam no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIprtparam:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iprtparam 
    Notes  : service externe. Critère piOrder-num = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcUtil-num  as character  no-undo.
    define input parameter piOrder-num as integer    no-undo.
    define input parameter table-handle phttIprtparam.
    define variable vhttBuffer as handle  no-undo.
    define buffer iprtparam for iprtparam.

    vhttBuffer = phttIprtparam:default-buffer-handle.
    if piOrder-num = ?
    then for each iprtparam no-lock
        where iprtparam.util-num = pcUtil-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iprtparam:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iprtparam no-lock
        where iprtparam.util-num = pcUtil-num
          and iprtparam.order-num = piOrder-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iprtparam:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIprtparam no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIprtparam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhUtil-num    as handle  no-undo.
    define variable vhOrder-num    as handle  no-undo.
    define variable vhPrg-name    as handle  no-undo.
    define buffer iprtparam for iprtparam.

    create query vhttquery.
    vhttBuffer = ghttIprtparam:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIprtparam:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhUtil-num, output vhOrder-num, output vhPrg-name).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iprtparam exclusive-lock
                where rowid(iprtparam) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iprtparam:handle, 'util-num/order-num/prg-name: ', substitute('&1/&2/&3', vhUtil-num:buffer-value(), vhOrder-num:buffer-value(), vhPrg-name:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iprtparam:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIprtparam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iprtparam for iprtparam.

    create query vhttquery.
    vhttBuffer = ghttIprtparam:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIprtparam:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iprtparam.
            if not outils:copyValidField(buffer iprtparam:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIprtparam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhUtil-num    as handle  no-undo.
    define variable vhOrder-num    as handle  no-undo.
    define variable vhPrg-name    as handle  no-undo.
    define buffer iprtparam for iprtparam.

    create query vhttquery.
    vhttBuffer = ghttIprtparam:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIprtparam:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhUtil-num, output vhOrder-num, output vhPrg-name).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iprtparam exclusive-lock
                where rowid(Iprtparam) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iprtparam:handle, 'util-num/order-num/prg-name: ', substitute('&1/&2/&3', vhUtil-num:buffer-value(), vhOrder-num:buffer-value(), vhPrg-name:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iprtparam no-error.
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

