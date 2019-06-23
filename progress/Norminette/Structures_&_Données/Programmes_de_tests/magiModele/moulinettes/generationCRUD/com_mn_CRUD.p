/*------------------------------------------------------------------------
File        : com_mn_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table com_mn
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/com_mn.i}
{application/include/error.i}
define variable ghttcom_mn as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudCom_mn private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCom_mn.
    run updateCom_mn.
    run createCom_mn.
end procedure.

procedure setCom_mn:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCom_mn.
    ghttCom_mn = phttCom_mn.
    run crudCom_mn.
    delete object phttCom_mn.
end procedure.

procedure readCom_mn:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table com_mn 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdmsp as character  no-undo.
    define input parameter piNomen as integer    no-undo.
    define input parameter table-handle phttCom_mn.
    define variable vhttBuffer as handle no-undo.
    define buffer com_mn for com_mn.

    vhttBuffer = phttCom_mn:default-buffer-handle.
    for first com_mn no-lock
        where com_mn.cdmsp = pcCdmsp
          and com_mn.nomen = piNomen:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer com_mn:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCom_mn no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCom_mn:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table com_mn 
    Notes  : service externe. Critère pcCdmsp = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCdmsp as character  no-undo.
    define input parameter table-handle phttCom_mn.
    define variable vhttBuffer as handle  no-undo.
    define buffer com_mn for com_mn.

    vhttBuffer = phttCom_mn:default-buffer-handle.
    if pcCdmsp = ?
    then for each com_mn no-lock
        where com_mn.cdmsp = pcCdmsp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer com_mn:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each com_mn no-lock
        where com_mn.cdmsp = pcCdmsp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer com_mn:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCom_mn no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCom_mn private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdmsp    as handle  no-undo.
    define variable vhNomen    as handle  no-undo.
    define buffer com_mn for com_mn.

    create query vhttquery.
    vhttBuffer = ghttCom_mn:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCom_mn:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdmsp, output vhNomen).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first com_mn exclusive-lock
                where rowid(com_mn) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer com_mn:handle, 'cdmsp/nomen: ', substitute('&1/&2', vhCdmsp:buffer-value(), vhNomen:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer com_mn:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCom_mn private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer com_mn for com_mn.

    create query vhttquery.
    vhttBuffer = ghttCom_mn:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCom_mn:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create com_mn.
            if not outils:copyValidField(buffer com_mn:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCom_mn private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdmsp    as handle  no-undo.
    define variable vhNomen    as handle  no-undo.
    define buffer com_mn for com_mn.

    create query vhttquery.
    vhttBuffer = ghttCom_mn:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCom_mn:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdmsp, output vhNomen).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first com_mn exclusive-lock
                where rowid(Com_mn) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer com_mn:handle, 'cdmsp/nomen: ', substitute('&1/&2', vhCdmsp:buffer-value(), vhNomen:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete com_mn no-error.
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

