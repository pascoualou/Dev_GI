/*------------------------------------------------------------------------
File        : men_mn_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table men_mn
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/men_mn.i}
{application/include/error.i}
define variable ghttmen_mn as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNomen as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nomen, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nomen' then phNomen = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudMen_mn private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteMen_mn.
    run updateMen_mn.
    run createMen_mn.
end procedure.

procedure setMen_mn:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttMen_mn.
    ghttMen_mn = phttMen_mn.
    run crudMen_mn.
    delete object phttMen_mn.
end procedure.

procedure readMen_mn:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table men_mn 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNomen as integer    no-undo.
    define input parameter table-handle phttMen_mn.
    define variable vhttBuffer as handle no-undo.
    define buffer men_mn for men_mn.

    vhttBuffer = phttMen_mn:default-buffer-handle.
    for first men_mn no-lock
        where men_mn.nomen = piNomen:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer men_mn:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMen_mn no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getMen_mn:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table men_mn 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttMen_mn.
    define variable vhttBuffer as handle  no-undo.
    define buffer men_mn for men_mn.

    vhttBuffer = phttMen_mn:default-buffer-handle.
    for each men_mn no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer men_mn:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMen_mn no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateMen_mn private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomen    as handle  no-undo.
    define buffer men_mn for men_mn.

    create query vhttquery.
    vhttBuffer = ghttMen_mn:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttMen_mn:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomen).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first men_mn exclusive-lock
                where rowid(men_mn) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer men_mn:handle, 'nomen: ', substitute('&1', vhNomen:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer men_mn:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createMen_mn private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer men_mn for men_mn.

    create query vhttquery.
    vhttBuffer = ghttMen_mn:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttMen_mn:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create men_mn.
            if not outils:copyValidField(buffer men_mn:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteMen_mn private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomen    as handle  no-undo.
    define buffer men_mn for men_mn.

    create query vhttquery.
    vhttBuffer = ghttMen_mn:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttMen_mn:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomen).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first men_mn exclusive-lock
                where rowid(Men_mn) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer men_mn:handle, 'nomen: ', substitute('&1', vhNomen:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete men_mn no-error.
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

