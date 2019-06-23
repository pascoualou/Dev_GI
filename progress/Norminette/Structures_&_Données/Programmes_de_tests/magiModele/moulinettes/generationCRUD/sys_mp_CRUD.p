/*------------------------------------------------------------------------
File        : sys_mp_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table sys_mp
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/sys_mp.i}
{application/include/error.i}
define variable ghttsys_mp as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdmen as handle, output phNoord as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cdmen/noord, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cdmen' then phCdmen = phBuffer:buffer-field(vi).
            when 'noord' then phNoord = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSys_mp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSys_mp.
    run updateSys_mp.
    run createSys_mp.
end procedure.

procedure setSys_mp:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSys_mp.
    ghttSys_mp = phttSys_mp.
    run crudSys_mp.
    delete object phttSys_mp.
end procedure.

procedure readSys_mp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table sys_mp 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdmen as character  no-undo.
    define input parameter piNoord as integer    no-undo.
    define input parameter table-handle phttSys_mp.
    define variable vhttBuffer as handle no-undo.
    define buffer sys_mp for sys_mp.

    vhttBuffer = phttSys_mp:default-buffer-handle.
    for first sys_mp no-lock
        where sys_mp.cdmen = pcCdmen
          and sys_mp.noord = piNoord:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer sys_mp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSys_mp no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSys_mp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table sys_mp 
    Notes  : service externe. Critère pcCdmen = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCdmen as character  no-undo.
    define input parameter table-handle phttSys_mp.
    define variable vhttBuffer as handle  no-undo.
    define buffer sys_mp for sys_mp.

    vhttBuffer = phttSys_mp:default-buffer-handle.
    if pcCdmen = ?
    then for each sys_mp no-lock
        where sys_mp.cdmen = pcCdmen:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer sys_mp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each sys_mp no-lock
        where sys_mp.cdmen = pcCdmen:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer sys_mp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSys_mp no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSys_mp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdmen    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer sys_mp for sys_mp.

    create query vhttquery.
    vhttBuffer = ghttSys_mp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSys_mp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdmen, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first sys_mp exclusive-lock
                where rowid(sys_mp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer sys_mp:handle, 'cdmen/noord: ', substitute('&1/&2', vhCdmen:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer sys_mp:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSys_mp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer sys_mp for sys_mp.

    create query vhttquery.
    vhttBuffer = ghttSys_mp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSys_mp:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create sys_mp.
            if not outils:copyValidField(buffer sys_mp:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSys_mp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdmen    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer sys_mp for sys_mp.

    create query vhttquery.
    vhttBuffer = ghttSys_mp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSys_mp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdmen, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first sys_mp exclusive-lock
                where rowid(Sys_mp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer sys_mp:handle, 'cdmen/noord: ', substitute('&1/&2', vhCdmen:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete sys_mp no-error.
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

