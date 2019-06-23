/*------------------------------------------------------------------------
File        : ahon2_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ahon2
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ahon2.i}
{application/include/error.i}
define variable ghttahon2 as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoman as handle, output phNomdt as handle, output phNofac as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noman/nomdt/nofac, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noman' then phNoman = phBuffer:buffer-field(vi).
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
            when 'nofac' then phNofac = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAhon2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAhon2.
    run updateAhon2.
    run createAhon2.
end procedure.

procedure setAhon2:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAhon2.
    ghttAhon2 = phttAhon2.
    run crudAhon2.
    delete object phttAhon2.
end procedure.

procedure readAhon2:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ahon2 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoman as integer    no-undo.
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNofac as integer    no-undo.
    define input parameter table-handle phttAhon2.
    define variable vhttBuffer as handle no-undo.
    define buffer ahon2 for ahon2.

    vhttBuffer = phttAhon2:default-buffer-handle.
    for first ahon2 no-lock
        where ahon2.noman = piNoman
          and ahon2.nomdt = piNomdt
          and ahon2.nofac = piNofac:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ahon2:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAhon2 no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAhon2:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ahon2 
    Notes  : service externe. Critère piNomdt = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoman as integer    no-undo.
    define input parameter piNomdt as integer    no-undo.
    define input parameter table-handle phttAhon2.
    define variable vhttBuffer as handle  no-undo.
    define buffer ahon2 for ahon2.

    vhttBuffer = phttAhon2:default-buffer-handle.
    if piNomdt = ?
    then for each ahon2 no-lock
        where ahon2.noman = piNoman:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ahon2:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ahon2 no-lock
        where ahon2.noman = piNoman
          and ahon2.nomdt = piNomdt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ahon2:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAhon2 no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAhon2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoman    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNofac    as handle  no-undo.
    define buffer ahon2 for ahon2.

    create query vhttquery.
    vhttBuffer = ghttAhon2:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAhon2:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoman, output vhNomdt, output vhNofac).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ahon2 exclusive-lock
                where rowid(ahon2) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ahon2:handle, 'noman/nomdt/nofac: ', substitute('&1/&2/&3', vhNoman:buffer-value(), vhNomdt:buffer-value(), vhNofac:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ahon2:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAhon2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ahon2 for ahon2.

    create query vhttquery.
    vhttBuffer = ghttAhon2:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAhon2:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ahon2.
            if not outils:copyValidField(buffer ahon2:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAhon2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoman    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNofac    as handle  no-undo.
    define buffer ahon2 for ahon2.

    create query vhttquery.
    vhttBuffer = ghttAhon2:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAhon2:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoman, output vhNomdt, output vhNofac).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ahon2 exclusive-lock
                where rowid(Ahon2) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ahon2:handle, 'noman/nomdt/nofac: ', substitute('&1/&2/&3', vhNoman:buffer-value(), vhNomdt:buffer-value(), vhNofac:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ahon2 no-error.
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

