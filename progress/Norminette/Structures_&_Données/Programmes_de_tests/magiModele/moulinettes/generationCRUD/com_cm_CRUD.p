/*------------------------------------------------------------------------
File        : com_cm_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table com_cm
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/com_cm.i}
{application/include/error.i}
define variable ghttcom_cm as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudCom_cm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCom_cm.
    run updateCom_cm.
    run createCom_cm.
end procedure.

procedure setCom_cm:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCom_cm.
    ghttCom_cm = phttCom_cm.
    run crudCom_cm.
    delete object phttCom_cm.
end procedure.

procedure readCom_cm:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table com_cm 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdmsp as character  no-undo.
    define input parameter piNomen as integer    no-undo.
    define input parameter pcCdisp as character  no-undo.
    define input parameter piNoite as integer    no-undo.
    define input parameter table-handle phttCom_cm.
    define variable vhttBuffer as handle no-undo.
    define buffer com_cm for com_cm.

    vhttBuffer = phttCom_cm:default-buffer-handle.
    for first com_cm no-lock
        where com_cm.cdmsp = pcCdmsp
          and com_cm.nomen = piNomen
          and com_cm.cdisp = pcCdisp
          and com_cm.noite = piNoite:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer com_cm:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCom_cm no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCom_cm:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table com_cm 
    Notes  : service externe. Critère pcCdisp = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCdmsp as character  no-undo.
    define input parameter piNomen as integer    no-undo.
    define input parameter pcCdisp as character  no-undo.
    define input parameter table-handle phttCom_cm.
    define variable vhttBuffer as handle  no-undo.
    define buffer com_cm for com_cm.

    vhttBuffer = phttCom_cm:default-buffer-handle.
    if pcCdisp = ?
    then for each com_cm no-lock
        where com_cm.cdmsp = pcCdmsp
          and com_cm.nomen = piNomen:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer com_cm:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each com_cm no-lock
        where com_cm.cdmsp = pcCdmsp
          and com_cm.nomen = piNomen
          and com_cm.cdisp = pcCdisp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer com_cm:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCom_cm no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCom_cm private:
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
    define buffer com_cm for com_cm.

    create query vhttquery.
    vhttBuffer = ghttCom_cm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCom_cm:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdmsp, output vhNomen, output vhCdisp, output vhNoite).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first com_cm exclusive-lock
                where rowid(com_cm) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer com_cm:handle, 'cdmsp/nomen/cdisp/noite: ', substitute('&1/&2/&3/&4', vhCdmsp:buffer-value(), vhNomen:buffer-value(), vhCdisp:buffer-value(), vhNoite:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer com_cm:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCom_cm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer com_cm for com_cm.

    create query vhttquery.
    vhttBuffer = ghttCom_cm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCom_cm:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create com_cm.
            if not outils:copyValidField(buffer com_cm:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCom_cm private:
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
    define buffer com_cm for com_cm.

    create query vhttquery.
    vhttBuffer = ghttCom_cm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCom_cm:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdmsp, output vhNomen, output vhCdisp, output vhNoite).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first com_cm exclusive-lock
                where rowid(Com_cm) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer com_cm:handle, 'cdmsp/nomen/cdisp/noite: ', substitute('&1/&2/&3/&4', vhCdmsp:buffer-value(), vhNomen:buffer-value(), vhCdisp:buffer-value(), vhNoite:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete com_cm no-error.
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

