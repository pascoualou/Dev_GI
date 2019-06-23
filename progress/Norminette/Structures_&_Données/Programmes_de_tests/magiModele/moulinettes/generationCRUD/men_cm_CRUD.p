/*------------------------------------------------------------------------
File        : men_cm_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table men_cm
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/men_cm.i}
{application/include/error.i}
define variable ghttmen_cm as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNomen as handle, output phNoord as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nomen/noord, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nomen' then phNomen = phBuffer:buffer-field(vi).
            when 'noord' then phNoord = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudMen_cm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteMen_cm.
    run updateMen_cm.
    run createMen_cm.
end procedure.

procedure setMen_cm:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttMen_cm.
    ghttMen_cm = phttMen_cm.
    run crudMen_cm.
    delete object phttMen_cm.
end procedure.

procedure readMen_cm:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table men_cm 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNomen as integer    no-undo.
    define input parameter piNoord as integer    no-undo.
    define input parameter table-handle phttMen_cm.
    define variable vhttBuffer as handle no-undo.
    define buffer men_cm for men_cm.

    vhttBuffer = phttMen_cm:default-buffer-handle.
    for first men_cm no-lock
        where men_cm.nomen = piNomen
          and men_cm.noord = piNoord:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer men_cm:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMen_cm no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getMen_cm:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table men_cm 
    Notes  : service externe. Critère piNomen = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNomen as integer    no-undo.
    define input parameter table-handle phttMen_cm.
    define variable vhttBuffer as handle  no-undo.
    define buffer men_cm for men_cm.

    vhttBuffer = phttMen_cm:default-buffer-handle.
    if piNomen = ?
    then for each men_cm no-lock
        where men_cm.nomen = piNomen:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer men_cm:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each men_cm no-lock
        where men_cm.nomen = piNomen:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer men_cm:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMen_cm no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateMen_cm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomen    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer men_cm for men_cm.

    create query vhttquery.
    vhttBuffer = ghttMen_cm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttMen_cm:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomen, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first men_cm exclusive-lock
                where rowid(men_cm) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer men_cm:handle, 'nomen/noord: ', substitute('&1/&2', vhNomen:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer men_cm:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createMen_cm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer men_cm for men_cm.

    create query vhttquery.
    vhttBuffer = ghttMen_cm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttMen_cm:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create men_cm.
            if not outils:copyValidField(buffer men_cm:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteMen_cm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomen    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer men_cm for men_cm.

    create query vhttquery.
    vhttBuffer = ghttMen_cm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttMen_cm:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomen, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first men_cm exclusive-lock
                where rowid(Men_cm) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer men_cm:handle, 'nomen/noord: ', substitute('&1/&2', vhNomen:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete men_cm no-error.
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

