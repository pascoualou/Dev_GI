/*------------------------------------------------------------------------
File        : cbalecr_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cbalecr
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cbalecr.i}
{application/include/error.i}
define variable ghttcbalecr as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phGi-ttyid as handle, output phNoord as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur gi-ttyid/noord, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'gi-ttyid' then phGi-ttyid = phBuffer:buffer-field(vi).
            when 'noord' then phNoord = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCbalecr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCbalecr.
    run updateCbalecr.
    run createCbalecr.
end procedure.

procedure setCbalecr:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCbalecr.
    ghttCbalecr = phttCbalecr.
    run crudCbalecr.
    delete object phttCbalecr.
end procedure.

procedure readCbalecr:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cbalecr balance ecran
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcGi-ttyid as character  no-undo.
    define input parameter piNoord    as integer    no-undo.
    define input parameter table-handle phttCbalecr.
    define variable vhttBuffer as handle no-undo.
    define buffer cbalecr for cbalecr.

    vhttBuffer = phttCbalecr:default-buffer-handle.
    for first cbalecr no-lock
        where cbalecr.gi-ttyid = pcGi-ttyid
          and cbalecr.noord = piNoord:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbalecr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCbalecr no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCbalecr:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cbalecr balance ecran
    Notes  : service externe. Critère pcGi-ttyid = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcGi-ttyid as character  no-undo.
    define input parameter table-handle phttCbalecr.
    define variable vhttBuffer as handle  no-undo.
    define buffer cbalecr for cbalecr.

    vhttBuffer = phttCbalecr:default-buffer-handle.
    if pcGi-ttyid = ?
    then for each cbalecr no-lock
        where cbalecr.gi-ttyid = pcGi-ttyid:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbalecr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cbalecr no-lock
        where cbalecr.gi-ttyid = pcGi-ttyid:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbalecr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCbalecr no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCbalecr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhGi-ttyid    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer cbalecr for cbalecr.

    create query vhttquery.
    vhttBuffer = ghttCbalecr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCbalecr:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhGi-ttyid, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cbalecr exclusive-lock
                where rowid(cbalecr) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cbalecr:handle, 'gi-ttyid/noord: ', substitute('&1/&2', vhGi-ttyid:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cbalecr:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCbalecr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cbalecr for cbalecr.

    create query vhttquery.
    vhttBuffer = ghttCbalecr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCbalecr:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cbalecr.
            if not outils:copyValidField(buffer cbalecr:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCbalecr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhGi-ttyid    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer cbalecr for cbalecr.

    create query vhttquery.
    vhttBuffer = ghttCbalecr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCbalecr:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhGi-ttyid, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cbalecr exclusive-lock
                where rowid(Cbalecr) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cbalecr:handle, 'gi-ttyid/noord: ', substitute('&1/&2', vhGi-ttyid:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cbalecr no-error.
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

