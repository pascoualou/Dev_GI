/*------------------------------------------------------------------------
File        : pnatscen_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table pnatscen
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/pnatscen.i}
{application/include/error.i}
define variable ghttpnatscen as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNatscen-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur natscen-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'natscen-cd' then phNatscen-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPnatscen private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePnatscen.
    run updatePnatscen.
    run createPnatscen.
end procedure.

procedure setPnatscen:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPnatscen.
    ghttPnatscen = phttPnatscen.
    run crudPnatscen.
    delete object phttPnatscen.
end procedure.

procedure readPnatscen:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table pnatscen Fichier nature du scenario
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNatscen-cd as integer    no-undo.
    define input parameter table-handle phttPnatscen.
    define variable vhttBuffer as handle no-undo.
    define buffer pnatscen for pnatscen.

    vhttBuffer = phttPnatscen:default-buffer-handle.
    for first pnatscen no-lock
        where pnatscen.natscen-cd = piNatscen-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pnatscen:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPnatscen no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPnatscen:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table pnatscen Fichier nature du scenario
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPnatscen.
    define variable vhttBuffer as handle  no-undo.
    define buffer pnatscen for pnatscen.

    vhttBuffer = phttPnatscen:default-buffer-handle.
    for each pnatscen no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pnatscen:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPnatscen no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePnatscen private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNatscen-cd    as handle  no-undo.
    define buffer pnatscen for pnatscen.

    create query vhttquery.
    vhttBuffer = ghttPnatscen:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPnatscen:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNatscen-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pnatscen exclusive-lock
                where rowid(pnatscen) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pnatscen:handle, 'natscen-cd: ', substitute('&1', vhNatscen-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer pnatscen:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPnatscen private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer pnatscen for pnatscen.

    create query vhttquery.
    vhttBuffer = ghttPnatscen:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPnatscen:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create pnatscen.
            if not outils:copyValidField(buffer pnatscen:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePnatscen private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNatscen-cd    as handle  no-undo.
    define buffer pnatscen for pnatscen.

    create query vhttquery.
    vhttBuffer = ghttPnatscen:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPnatscen:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNatscen-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pnatscen exclusive-lock
                where rowid(Pnatscen) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pnatscen:handle, 'natscen-cd: ', substitute('&1', vhNatscen-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete pnatscen no-error.
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

