/*------------------------------------------------------------------------
File        : avenant_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table avenant
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/avenant.i}
{application/include/error.i}
define variable ghttavenant as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTppar as handle, output phNoave as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tppar/noave, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tppar' then phTppar = phBuffer:buffer-field(vi).
            when 'noave' then phNoave = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAvenant private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAvenant.
    run updateAvenant.
    run createAvenant.
end procedure.

procedure setAvenant:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAvenant.
    ghttAvenant = phttAvenant.
    run crudAvenant.
    delete object phttAvenant.
end procedure.

procedure readAvenant:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table avenant 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTppar as character  no-undo.
    define input parameter piNoave as integer    no-undo.
    define input parameter table-handle phttAvenant.
    define variable vhttBuffer as handle no-undo.
    define buffer avenant for avenant.

    vhttBuffer = phttAvenant:default-buffer-handle.
    for first avenant no-lock
        where avenant.tppar = pcTppar
          and avenant.noave = piNoave:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer avenant:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAvenant no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAvenant:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table avenant 
    Notes  : service externe. Critère pcTppar = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTppar as character  no-undo.
    define input parameter table-handle phttAvenant.
    define variable vhttBuffer as handle  no-undo.
    define buffer avenant for avenant.

    vhttBuffer = phttAvenant:default-buffer-handle.
    if pcTppar = ?
    then for each avenant no-lock
        where avenant.tppar = pcTppar:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer avenant:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each avenant no-lock
        where avenant.tppar = pcTppar:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer avenant:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAvenant no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAvenant private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTppar    as handle  no-undo.
    define variable vhNoave    as handle  no-undo.
    define buffer avenant for avenant.

    create query vhttquery.
    vhttBuffer = ghttAvenant:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAvenant:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTppar, output vhNoave).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first avenant exclusive-lock
                where rowid(avenant) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer avenant:handle, 'tppar/noave: ', substitute('&1/&2', vhTppar:buffer-value(), vhNoave:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer avenant:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAvenant private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer avenant for avenant.

    create query vhttquery.
    vhttBuffer = ghttAvenant:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAvenant:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create avenant.
            if not outils:copyValidField(buffer avenant:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAvenant private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTppar    as handle  no-undo.
    define variable vhNoave    as handle  no-undo.
    define buffer avenant for avenant.

    create query vhttquery.
    vhttBuffer = ghttAvenant:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAvenant:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTppar, output vhNoave).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first avenant exclusive-lock
                where rowid(Avenant) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer avenant:handle, 'tppar/noave: ', substitute('&1/&2', vhTppar:buffer-value(), vhNoave:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete avenant no-error.
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

