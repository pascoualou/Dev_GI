/*------------------------------------------------------------------------
File        : abur1_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table abur1
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/abur1.i}
{application/include/error.i}
define variable ghttabur1 as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudAbur1 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAbur1.
    run updateAbur1.
    run createAbur1.
end procedure.

procedure setAbur1:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAbur1.
    ghttAbur1 = phttAbur1.
    run crudAbur1.
    delete object phttAbur1.
end procedure.

procedure readAbur1:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table abur1 Historique taxe de bureau (entete)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAbur1.
    define variable vhttBuffer as handle no-undo.
    define buffer abur1 for abur1.

    vhttBuffer = phttAbur1:default-buffer-handle.
    for first abur1 no-lock
        where :
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer abur1:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAbur1 no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAbur1:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table abur1 Historique taxe de bureau (entete)
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAbur1.
    define variable vhttBuffer as handle  no-undo.
    define buffer abur1 for abur1.

    vhttBuffer = phttAbur1:default-buffer-handle.
    for each abur1 no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer abur1:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAbur1 no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAbur1 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer abur1 for abur1.

    create query vhttquery.
    vhttBuffer = ghttAbur1:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAbur1:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first abur1 exclusive-lock
                where rowid(abur1) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer abur1:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer abur1:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAbur1 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer abur1 for abur1.

    create query vhttquery.
    vhttBuffer = ghttAbur1:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAbur1:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create abur1.
            if not outils:copyValidField(buffer abur1:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAbur1 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer abur1 for abur1.

    create query vhttquery.
    vhttBuffer = ghttAbur1:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAbur1:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first abur1 exclusive-lock
                where rowid(Abur1) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer abur1:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete abur1 no-error.
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

