/*------------------------------------------------------------------------
File        : adb_cm_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table adb_cm
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/adb_cm.i}
{application/include/error.i}
define variable ghttadb_cm as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdmsp as handle, output phNomen as handle, output phCdisp as handle, output phNoite as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cdmsp/nomen/cdisp/noite, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cdmsp' then phCdmsp = phBuffer:buffer-field(vi).
            when 'nomen' then phNomen = phBuffer:buffer-field(vi).
            when 'cdisp' then phCdisp = phBuffer:buffer-field(vi).
            when 'noite' then phNoite = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAdb_cm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAdb_cm.
    run updateAdb_cm.
    run createAdb_cm.
end procedure.

procedure setAdb_cm:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAdb_cm.
    ghttAdb_cm = phttAdb_cm.
    run crudAdb_cm.
    delete object phttAdb_cm.
end procedure.

procedure readAdb_cm:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table adb_cm 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdmsp as character  no-undo.
    define input parameter piNomen as integer    no-undo.
    define input parameter pcCdisp as character  no-undo.
    define input parameter piNoite as integer    no-undo.
    define input parameter table-handle phttAdb_cm.
    define variable vhttBuffer as handle no-undo.
    define buffer adb_cm for adb_cm.

    vhttBuffer = phttAdb_cm:default-buffer-handle.
    for first adb_cm no-lock
        where adb_cm.cdmsp = pcCdmsp
          and adb_cm.nomen = piNomen
          and adb_cm.cdisp = pcCdisp
          and adb_cm.noite = piNoite:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer adb_cm:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAdb_cm no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAdb_cm:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table adb_cm 
    Notes  : service externe. Critère pcCdisp = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCdmsp as character  no-undo.
    define input parameter piNomen as integer    no-undo.
    define input parameter pcCdisp as character  no-undo.
    define input parameter table-handle phttAdb_cm.
    define variable vhttBuffer as handle  no-undo.
    define buffer adb_cm for adb_cm.

    vhttBuffer = phttAdb_cm:default-buffer-handle.
    if pcCdisp = ?
    then for each adb_cm no-lock
        where adb_cm.cdmsp = pcCdmsp
          and adb_cm.nomen = piNomen:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer adb_cm:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each adb_cm no-lock
        where adb_cm.cdmsp = pcCdmsp
          and adb_cm.nomen = piNomen
          and adb_cm.cdisp = pcCdisp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer adb_cm:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAdb_cm no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAdb_cm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdmsp    as handle  no-undo.
    define variable vhNomen    as handle  no-undo.
    define variable vhCdisp    as handle  no-undo.
    define variable vhNoite    as handle  no-undo.
    define buffer adb_cm for adb_cm.

    create query vhttquery.
    vhttBuffer = ghttAdb_cm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAdb_cm:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdmsp, output vhNomen, output vhCdisp, output vhNoite).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first adb_cm exclusive-lock
                where rowid(adb_cm) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer adb_cm:handle, 'cdmsp/nomen/cdisp/noite: ', substitute('&1/&2/&3/&4', vhCdmsp:buffer-value(), vhNomen:buffer-value(), vhCdisp:buffer-value(), vhNoite:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer adb_cm:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAdb_cm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer adb_cm for adb_cm.

    create query vhttquery.
    vhttBuffer = ghttAdb_cm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAdb_cm:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create adb_cm.
            if not outils:copyValidField(buffer adb_cm:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAdb_cm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdmsp    as handle  no-undo.
    define variable vhNomen    as handle  no-undo.
    define variable vhCdisp    as handle  no-undo.
    define variable vhNoite    as handle  no-undo.
    define buffer adb_cm for adb_cm.

    create query vhttquery.
    vhttBuffer = ghttAdb_cm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAdb_cm:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdmsp, output vhNomen, output vhCdisp, output vhNoite).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first adb_cm exclusive-lock
                where rowid(Adb_cm) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer adb_cm:handle, 'cdmsp/nomen/cdisp/noite: ', substitute('&1/&2/&3/&4', vhCdmsp:buffer-value(), vhNomen:buffer-value(), vhCdisp:buffer-value(), vhNoite:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete adb_cm no-error.
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

