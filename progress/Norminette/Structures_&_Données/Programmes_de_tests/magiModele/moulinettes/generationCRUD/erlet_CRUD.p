/*------------------------------------------------------------------------
File        : erlet_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table erlet
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/erlet.i}
{application/include/error.i}
define variable ghtterlet as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNorli as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur norli, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'norli' then phNorli = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudErlet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteErlet.
    run updateErlet.
    run createErlet.
end procedure.

procedure setErlet:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttErlet.
    ghttErlet = phttErlet.
    run crudErlet.
    delete object phttErlet.
end procedure.

procedure readErlet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table erlet 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNorli as integer    no-undo.
    define input parameter table-handle phttErlet.
    define variable vhttBuffer as handle no-undo.
    define buffer erlet for erlet.

    vhttBuffer = phttErlet:default-buffer-handle.
    for first erlet no-lock
        where erlet.norli = piNorli:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer erlet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttErlet no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getErlet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table erlet 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttErlet.
    define variable vhttBuffer as handle  no-undo.
    define buffer erlet for erlet.

    vhttBuffer = phttErlet:default-buffer-handle.
    for each erlet no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer erlet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttErlet no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateErlet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNorli    as handle  no-undo.
    define buffer erlet for erlet.

    create query vhttquery.
    vhttBuffer = ghttErlet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttErlet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNorli).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first erlet exclusive-lock
                where rowid(erlet) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer erlet:handle, 'norli: ', substitute('&1', vhNorli:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer erlet:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createErlet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer erlet for erlet.

    create query vhttquery.
    vhttBuffer = ghttErlet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttErlet:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create erlet.
            if not outils:copyValidField(buffer erlet:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteErlet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNorli    as handle  no-undo.
    define buffer erlet for erlet.

    create query vhttquery.
    vhttBuffer = ghttErlet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttErlet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNorli).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first erlet exclusive-lock
                where rowid(Erlet) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer erlet:handle, 'norli: ', substitute('&1', vhNorli:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete erlet no-error.
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

