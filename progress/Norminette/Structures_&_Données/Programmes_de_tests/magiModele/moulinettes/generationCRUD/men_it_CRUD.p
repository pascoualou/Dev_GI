/*------------------------------------------------------------------------
File        : men_it_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table men_it
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/men_it.i}
{application/include/error.i}
define variable ghttmen_it as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoite as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noite, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noite' then phNoite = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudMen_it private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteMen_it.
    run updateMen_it.
    run createMen_it.
end procedure.

procedure setMen_it:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttMen_it.
    ghttMen_it = phttMen_it.
    run crudMen_it.
    delete object phttMen_it.
end procedure.

procedure readMen_it:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table men_it 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoite as integer    no-undo.
    define input parameter table-handle phttMen_it.
    define variable vhttBuffer as handle no-undo.
    define buffer men_it for men_it.

    vhttBuffer = phttMen_it:default-buffer-handle.
    for first men_it no-lock
        where men_it.noite = piNoite:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer men_it:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMen_it no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getMen_it:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table men_it 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttMen_it.
    define variable vhttBuffer as handle  no-undo.
    define buffer men_it for men_it.

    vhttBuffer = phttMen_it:default-buffer-handle.
    for each men_it no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer men_it:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMen_it no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateMen_it private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoite    as handle  no-undo.
    define buffer men_it for men_it.

    create query vhttquery.
    vhttBuffer = ghttMen_it:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttMen_it:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoite).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first men_it exclusive-lock
                where rowid(men_it) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer men_it:handle, 'noite: ', substitute('&1', vhNoite:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer men_it:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createMen_it private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer men_it for men_it.

    create query vhttquery.
    vhttBuffer = ghttMen_it:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttMen_it:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create men_it.
            if not outils:copyValidField(buffer men_it:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteMen_it private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoite    as handle  no-undo.
    define buffer men_it for men_it.

    create query vhttquery.
    vhttBuffer = ghttMen_it:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttMen_it:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoite).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first men_it exclusive-lock
                where rowid(Men_it) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer men_it:handle, 'noite: ', substitute('&1', vhNoite:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete men_it no-error.
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

