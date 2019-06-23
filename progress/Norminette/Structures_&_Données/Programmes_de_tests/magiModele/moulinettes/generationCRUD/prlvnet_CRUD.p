/*------------------------------------------------------------------------
File        : prlvnet_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table prlvnet
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/prlvnet.i}
{application/include/error.i}
define variable ghttprlvnet as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phNoprel as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/noprel, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'noprel' then phNoprel = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPrlvnet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePrlvnet.
    run updatePrlvnet.
    run createPrlvnet.
end procedure.

procedure setPrlvnet:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPrlvnet.
    ghttPrlvnet = phttPrlvnet.
    run crudPrlvnet.
    delete object phttPrlvnet.
end procedure.

procedure readPrlvnet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table prlvnet 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd as integer    no-undo.
    define input parameter piNoprel as int64      no-undo.
    define input parameter table-handle phttPrlvnet.
    define variable vhttBuffer as handle no-undo.
    define buffer prlvnet for prlvnet.

    vhttBuffer = phttPrlvnet:default-buffer-handle.
    for first prlvnet no-lock
        where prlvnet.soc-cd = piSoc-cd
          and prlvnet.noprel = piNoprel:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer prlvnet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPrlvnet no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPrlvnet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table prlvnet 
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd as integer    no-undo.
    define input parameter table-handle phttPrlvnet.
    define variable vhttBuffer as handle  no-undo.
    define buffer prlvnet for prlvnet.

    vhttBuffer = phttPrlvnet:default-buffer-handle.
    if piSoc-cd = ?
    then for each prlvnet no-lock
        where prlvnet.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer prlvnet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each prlvnet no-lock
        where prlvnet.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer prlvnet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPrlvnet no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePrlvnet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhNoprel    as handle  no-undo.
    define buffer prlvnet for prlvnet.

    create query vhttquery.
    vhttBuffer = ghttPrlvnet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPrlvnet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhNoprel).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first prlvnet exclusive-lock
                where rowid(prlvnet) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer prlvnet:handle, 'soc-cd/noprel: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhNoprel:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer prlvnet:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPrlvnet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer prlvnet for prlvnet.

    create query vhttquery.
    vhttBuffer = ghttPrlvnet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPrlvnet:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create prlvnet.
            if not outils:copyValidField(buffer prlvnet:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePrlvnet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhNoprel    as handle  no-undo.
    define buffer prlvnet for prlvnet.

    create query vhttquery.
    vhttBuffer = ghttPrlvnet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPrlvnet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhNoprel).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first prlvnet exclusive-lock
                where rowid(Prlvnet) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer prlvnet:handle, 'soc-cd/noprel: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhNoprel:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete prlvnet no-error.
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

