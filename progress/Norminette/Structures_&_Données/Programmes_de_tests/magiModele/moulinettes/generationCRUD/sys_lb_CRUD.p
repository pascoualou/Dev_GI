/*------------------------------------------------------------------------
File        : sys_lb_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table sys_lb
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/sys_lb.i}
{application/include/error.i}
define variable ghttsys_lb as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNomes as handle, output phCdlng as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nomes/cdlng, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nomes' then phNomes = phBuffer:buffer-field(vi).
            when 'cdlng' then phCdlng = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSys_lb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSys_lb.
    run updateSys_lb.
    run createSys_lb.
end procedure.

procedure setSys_lb:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSys_lb.
    ghttSys_lb = phttSys_lb.
    run crudSys_lb.
    delete object phttSys_lb.
end procedure.

procedure readSys_lb:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table sys_lb 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNomes as integer    no-undo.
    define input parameter piCdlng as integer    no-undo.
    define input parameter table-handle phttSys_lb.
    define variable vhttBuffer as handle no-undo.
    define buffer sys_lb for sys_lb.

    vhttBuffer = phttSys_lb:default-buffer-handle.
    for first sys_lb no-lock
        where sys_lb.nomes = piNomes
          and sys_lb.cdlng = piCdlng:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer sys_lb:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSys_lb no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSys_lb:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table sys_lb 
    Notes  : service externe. Critère piNomes = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNomes as integer    no-undo.
    define input parameter table-handle phttSys_lb.
    define variable vhttBuffer as handle  no-undo.
    define buffer sys_lb for sys_lb.

    vhttBuffer = phttSys_lb:default-buffer-handle.
    if piNomes = ?
    then for each sys_lb no-lock
        where sys_lb.nomes = piNomes:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer sys_lb:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each sys_lb no-lock
        where sys_lb.nomes = piNomes:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer sys_lb:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSys_lb no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSys_lb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomes    as handle  no-undo.
    define variable vhCdlng    as handle  no-undo.
    define buffer sys_lb for sys_lb.

    create query vhttquery.
    vhttBuffer = ghttSys_lb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSys_lb:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomes, output vhCdlng).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first sys_lb exclusive-lock
                where rowid(sys_lb) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer sys_lb:handle, 'nomes/cdlng: ', substitute('&1/&2', vhNomes:buffer-value(), vhCdlng:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer sys_lb:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSys_lb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer sys_lb for sys_lb.

    create query vhttquery.
    vhttBuffer = ghttSys_lb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSys_lb:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create sys_lb.
            if not outils:copyValidField(buffer sys_lb:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSys_lb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomes    as handle  no-undo.
    define variable vhCdlng    as handle  no-undo.
    define buffer sys_lb for sys_lb.

    create query vhttquery.
    vhttBuffer = ghttSys_lb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSys_lb:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomes, output vhCdlng).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first sys_lb exclusive-lock
                where rowid(Sys_lb) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer sys_lb:handle, 'nomes/cdlng: ', substitute('&1/&2', vhNomes:buffer-value(), vhCdlng:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete sys_lb no-error.
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

