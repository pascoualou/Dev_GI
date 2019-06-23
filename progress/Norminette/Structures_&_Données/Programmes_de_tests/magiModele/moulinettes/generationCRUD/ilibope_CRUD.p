/*------------------------------------------------------------------------
File        : ilibope_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ilibope
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ilibope.i}
{application/include/error.i}
define variable ghttilibope as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phLibope-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur libope-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'libope-cd' then phLibope-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIlibope private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIlibope.
    run updateIlibope.
    run createIlibope.
end procedure.

procedure setIlibope:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIlibope.
    ghttIlibope = phttIlibope.
    run crudIlibope.
    delete object phttIlibope.
end procedure.

procedure readIlibope:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ilibope libelles operations bancaires
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcLibope-cd as character  no-undo.
    define input parameter table-handle phttIlibope.
    define variable vhttBuffer as handle no-undo.
    define buffer ilibope for ilibope.

    vhttBuffer = phttIlibope:default-buffer-handle.
    for first ilibope no-lock
        where ilibope.libope-cd = pcLibope-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibope:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibope no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIlibope:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ilibope libelles operations bancaires
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIlibope.
    define variable vhttBuffer as handle  no-undo.
    define buffer ilibope for ilibope.

    vhttBuffer = phttIlibope:default-buffer-handle.
    for each ilibope no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibope:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibope no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIlibope private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLibope-cd    as handle  no-undo.
    define buffer ilibope for ilibope.

    create query vhttquery.
    vhttBuffer = ghttIlibope:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIlibope:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLibope-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibope exclusive-lock
                where rowid(ilibope) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibope:handle, 'libope-cd: ', substitute('&1', vhLibope-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ilibope:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIlibope private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ilibope for ilibope.

    create query vhttquery.
    vhttBuffer = ghttIlibope:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIlibope:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ilibope.
            if not outils:copyValidField(buffer ilibope:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIlibope private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLibope-cd    as handle  no-undo.
    define buffer ilibope for ilibope.

    create query vhttquery.
    vhttBuffer = ghttIlibope:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIlibope:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLibope-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibope exclusive-lock
                where rowid(Ilibope) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibope:handle, 'libope-cd: ', substitute('&1', vhLibope-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ilibope no-error.
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

