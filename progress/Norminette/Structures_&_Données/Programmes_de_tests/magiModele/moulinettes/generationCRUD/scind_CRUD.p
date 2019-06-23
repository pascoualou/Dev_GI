/*------------------------------------------------------------------------
File        : scind_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table scind
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/scind.i}
{application/include/error.i}
define variable ghttscind as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoind as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noind, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noind' then phNoind = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudScind private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteScind.
    run updateScind.
    run createScind.
end procedure.

procedure setScind:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttScind.
    ghttScind = phttScind.
    run crudScind.
    delete object phttScind.
end procedure.

procedure readScind:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table scind Liste des indivisions
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoind as integer    no-undo.
    define input parameter table-handle phttScind.
    define variable vhttBuffer as handle no-undo.
    define buffer scind for scind.

    vhttBuffer = phttScind:default-buffer-handle.
    for first scind no-lock
        where scind.noind = piNoind:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer scind:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttScind no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getScind:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table scind Liste des indivisions
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttScind.
    define variable vhttBuffer as handle  no-undo.
    define buffer scind for scind.

    vhttBuffer = phttScind:default-buffer-handle.
    for each scind no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer scind:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttScind no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateScind private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoind    as handle  no-undo.
    define buffer scind for scind.

    create query vhttquery.
    vhttBuffer = ghttScind:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttScind:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoind).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first scind exclusive-lock
                where rowid(scind) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer scind:handle, 'noind: ', substitute('&1', vhNoind:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer scind:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createScind private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer scind for scind.

    create query vhttquery.
    vhttBuffer = ghttScind:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttScind:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create scind.
            if not outils:copyValidField(buffer scind:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteScind private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoind    as handle  no-undo.
    define buffer scind for scind.

    create query vhttquery.
    vhttBuffer = ghttScind:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttScind:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoind).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first scind exclusive-lock
                where rowid(Scind) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer scind:handle, 'noind: ', substitute('&1', vhNoind:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete scind no-error.
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

