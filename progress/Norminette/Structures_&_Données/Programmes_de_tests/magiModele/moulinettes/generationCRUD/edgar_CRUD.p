/*------------------------------------------------------------------------
File        : edgar_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table edgar
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/edgar.i}
{application/include/error.i}
define variable ghttedgar as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur , 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
       end case.
    end.
end function.

procedure crudEdgar private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteEdgar.
    run updateEdgar.
    run createEdgar.
end procedure.

procedure setEdgar:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEdgar.
    ghttEdgar = phttEdgar.
    run crudEdgar.
    delete object phttEdgar.
end procedure.

procedure readEdgar:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table edgar 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEdgar.
    define variable vhttBuffer as handle no-undo.
    define buffer edgar for edgar.

    vhttBuffer = phttEdgar:default-buffer-handle.
    for first edgar no-lock
        where :
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer edgar:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEdgar no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getEdgar:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table edgar 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEdgar.
    define variable vhttBuffer as handle  no-undo.
    define buffer edgar for edgar.

    vhttBuffer = phttEdgar:default-buffer-handle.
    for each edgar no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer edgar:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEdgar no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateEdgar private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer edgar for edgar.

    create query vhttquery.
    vhttBuffer = ghttEdgar:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttEdgar:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first edgar exclusive-lock
                where rowid(edgar) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer edgar:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer edgar:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createEdgar private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer edgar for edgar.

    create query vhttquery.
    vhttBuffer = ghttEdgar:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttEdgar:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create edgar.
            if not outils:copyValidField(buffer edgar:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteEdgar private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer edgar for edgar.

    create query vhttquery.
    vhttBuffer = ghttEdgar:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttEdgar:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first edgar exclusive-lock
                where rowid(Edgar) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer edgar:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete edgar no-error.
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

