/*------------------------------------------------------------------------
File        : iparam_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iparam
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iparam.i}
{application/include/error.i}
define variable ghttiparam as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phIserie as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur iserie, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'iserie' then phIserie = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIparam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIparam.
    run updateIparam.
    run createIparam.
end procedure.

procedure setIparam:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIparam.
    ghttIparam = phttIparam.
    run crudIparam.
    delete object phttIparam.
end procedure.

procedure readIparam:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iparam Renseigenements concernant le produit installe.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcIserie as character  no-undo.
    define input parameter table-handle phttIparam.
    define variable vhttBuffer as handle no-undo.
    define buffer iparam for iparam.

    vhttBuffer = phttIparam:default-buffer-handle.
    for first iparam no-lock
        where iparam.iserie = pcIserie:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iparam:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIparam no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIparam:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iparam Renseigenements concernant le produit installe.
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIparam.
    define variable vhttBuffer as handle  no-undo.
    define buffer iparam for iparam.

    vhttBuffer = phttIparam:default-buffer-handle.
    for each iparam no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iparam:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIparam no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIparam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhIserie    as handle  no-undo.
    define buffer iparam for iparam.

    create query vhttquery.
    vhttBuffer = ghttIparam:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIparam:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhIserie).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iparam exclusive-lock
                where rowid(iparam) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iparam:handle, 'iserie: ', substitute('&1', vhIserie:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iparam:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIparam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iparam for iparam.

    create query vhttquery.
    vhttBuffer = ghttIparam:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIparam:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iparam.
            if not outils:copyValidField(buffer iparam:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIparam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhIserie    as handle  no-undo.
    define buffer iparam for iparam.

    create query vhttquery.
    vhttBuffer = ghttIparam:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIparam:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhIserie).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iparam exclusive-lock
                where rowid(Iparam) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iparam:handle, 'iserie: ', substitute('&1', vhIserie:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iparam no-error.
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

