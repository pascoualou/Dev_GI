/*------------------------------------------------------------------------
File        : adb_mn_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table adb_mn
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/adb_mn.i}
{application/include/error.i}
define variable ghttadb_mn as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdmsp as handle, output phNomen as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cdmsp/nomen, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cdmsp' then phCdmsp = phBuffer:buffer-field(vi).
            when 'nomen' then phNomen = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAdb_mn private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAdb_mn.
    run updateAdb_mn.
    run createAdb_mn.
end procedure.

procedure setAdb_mn:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAdb_mn.
    ghttAdb_mn = phttAdb_mn.
    run crudAdb_mn.
    delete object phttAdb_mn.
end procedure.

procedure readAdb_mn:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table adb_mn 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdmsp as character  no-undo.
    define input parameter piNomen as integer    no-undo.
    define input parameter table-handle phttAdb_mn.
    define variable vhttBuffer as handle no-undo.
    define buffer adb_mn for adb_mn.

    vhttBuffer = phttAdb_mn:default-buffer-handle.
    for first adb_mn no-lock
        where adb_mn.cdmsp = pcCdmsp
          and adb_mn.nomen = piNomen:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer adb_mn:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAdb_mn no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAdb_mn:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table adb_mn 
    Notes  : service externe. Critère pcCdmsp = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCdmsp as character  no-undo.
    define input parameter table-handle phttAdb_mn.
    define variable vhttBuffer as handle  no-undo.
    define buffer adb_mn for adb_mn.

    vhttBuffer = phttAdb_mn:default-buffer-handle.
    if pcCdmsp = ?
    then for each adb_mn no-lock
        where adb_mn.cdmsp = pcCdmsp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer adb_mn:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each adb_mn no-lock
        where adb_mn.cdmsp = pcCdmsp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer adb_mn:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAdb_mn no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAdb_mn private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdmsp    as handle  no-undo.
    define variable vhNomen    as handle  no-undo.
    define buffer adb_mn for adb_mn.

    create query vhttquery.
    vhttBuffer = ghttAdb_mn:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAdb_mn:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdmsp, output vhNomen).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first adb_mn exclusive-lock
                where rowid(adb_mn) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer adb_mn:handle, 'cdmsp/nomen: ', substitute('&1/&2', vhCdmsp:buffer-value(), vhNomen:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer adb_mn:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAdb_mn private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer adb_mn for adb_mn.

    create query vhttquery.
    vhttBuffer = ghttAdb_mn:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAdb_mn:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create adb_mn.
            if not outils:copyValidField(buffer adb_mn:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAdb_mn private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdmsp    as handle  no-undo.
    define variable vhNomen    as handle  no-undo.
    define buffer adb_mn for adb_mn.

    create query vhttquery.
    vhttBuffer = ghttAdb_mn:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAdb_mn:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdmsp, output vhNomen).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first adb_mn exclusive-lock
                where rowid(Adb_mn) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer adb_mn:handle, 'cdmsp/nomen: ', substitute('&1/&2', vhCdmsp:buffer-value(), vhNomen:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete adb_mn no-error.
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

