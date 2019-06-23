/*------------------------------------------------------------------------
File        : prest_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table prest
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/prest.i}
{application/include/error.i}
define variable ghttprest as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNomdt as handle, output phNoarr as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nomdt/noarr, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
            when 'noarr' then phNoarr = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPrest private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePrest.
    run updatePrest.
    run createPrest.
end procedure.

procedure setPrest:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPrest.
    ghttPrest = phttPrest.
    run crudPrest.
    delete object phttPrest.
end procedure.

procedure readPrest:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table prest 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNoarr as integer    no-undo.
    define input parameter table-handle phttPrest.
    define variable vhttBuffer as handle no-undo.
    define buffer prest for prest.

    vhttBuffer = phttPrest:default-buffer-handle.
    for first prest no-lock
        where prest.nomdt = piNomdt
          and prest.noarr = piNoarr:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer prest:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPrest no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPrest:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table prest 
    Notes  : service externe. Critère piNomdt = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNomdt as integer    no-undo.
    define input parameter table-handle phttPrest.
    define variable vhttBuffer as handle  no-undo.
    define buffer prest for prest.

    vhttBuffer = phttPrest:default-buffer-handle.
    if piNomdt = ?
    then for each prest no-lock
        where prest.nomdt = piNomdt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer prest:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each prest no-lock
        where prest.nomdt = piNomdt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer prest:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPrest no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePrest private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoarr    as handle  no-undo.
    define buffer prest for prest.

    create query vhttquery.
    vhttBuffer = ghttPrest:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPrest:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt, output vhNoarr).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first prest exclusive-lock
                where rowid(prest) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer prest:handle, 'nomdt/noarr: ', substitute('&1/&2', vhNomdt:buffer-value(), vhNoarr:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer prest:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPrest private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer prest for prest.

    create query vhttquery.
    vhttBuffer = ghttPrest:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPrest:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create prest.
            if not outils:copyValidField(buffer prest:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePrest private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoarr    as handle  no-undo.
    define buffer prest for prest.

    create query vhttquery.
    vhttBuffer = ghttPrest:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPrest:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt, output vhNoarr).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first prest exclusive-lock
                where rowid(Prest) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer prest:handle, 'nomdt/noarr: ', substitute('&1/&2', vhNomdt:buffer-value(), vhNoarr:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete prest no-error.
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

