/*------------------------------------------------------------------------
File        : ptypechq_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ptypechq
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ptypechq.i}
{application/include/error.i}
define variable ghttptypechq as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTypechq-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur typechq-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'typechq-cd' then phTypechq-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPtypechq private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePtypechq.
    run updatePtypechq.
    run createPtypechq.
end procedure.

procedure setPtypechq:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPtypechq.
    ghttPtypechq = phttPtypechq.
    run crudPtypechq.
    delete object phttPtypechq.
end procedure.

procedure readPtypechq:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ptypechq Fichier Types de Cheque
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piTypechq-cd as integer    no-undo.
    define input parameter table-handle phttPtypechq.
    define variable vhttBuffer as handle no-undo.
    define buffer ptypechq for ptypechq.

    vhttBuffer = phttPtypechq:default-buffer-handle.
    for first ptypechq no-lock
        where ptypechq.typechq-cd = piTypechq-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ptypechq:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPtypechq no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPtypechq:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ptypechq Fichier Types de Cheque
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPtypechq.
    define variable vhttBuffer as handle  no-undo.
    define buffer ptypechq for ptypechq.

    vhttBuffer = phttPtypechq:default-buffer-handle.
    for each ptypechq no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ptypechq:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPtypechq no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePtypechq private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTypechq-cd    as handle  no-undo.
    define buffer ptypechq for ptypechq.

    create query vhttquery.
    vhttBuffer = ghttPtypechq:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPtypechq:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTypechq-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ptypechq exclusive-lock
                where rowid(ptypechq) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ptypechq:handle, 'typechq-cd: ', substitute('&1', vhTypechq-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ptypechq:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPtypechq private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ptypechq for ptypechq.

    create query vhttquery.
    vhttBuffer = ghttPtypechq:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPtypechq:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ptypechq.
            if not outils:copyValidField(buffer ptypechq:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePtypechq private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTypechq-cd    as handle  no-undo.
    define buffer ptypechq for ptypechq.

    create query vhttquery.
    vhttBuffer = ghttPtypechq:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPtypechq:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTypechq-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ptypechq exclusive-lock
                where rowid(Ptypechq) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ptypechq:handle, 'typechq-cd: ', substitute('&1', vhTypechq-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ptypechq no-error.
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

