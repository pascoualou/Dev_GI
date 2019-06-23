/*------------------------------------------------------------------------
File        : itvamode_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table itvamode
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/itvamode.i}
{application/include/error.i}
define variable ghttitvamode as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phLibtva-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur libtva-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'libtva-cd' then phLibtva-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudItvamode private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteItvamode.
    run updateItvamode.
    run createItvamode.
end procedure.

procedure setItvamode:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttItvamode.
    ghttItvamode = phttItvamode.
    run crudItvamode.
    delete object phttItvamode.
end procedure.

procedure readItvamode:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table itvamode Liste des differents modes de tva.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piLibtva-cd as integer    no-undo.
    define input parameter table-handle phttItvamode.
    define variable vhttBuffer as handle no-undo.
    define buffer itvamode for itvamode.

    vhttBuffer = phttItvamode:default-buffer-handle.
    for first itvamode no-lock
        where itvamode.libtva-cd = piLibtva-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itvamode:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttItvamode no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getItvamode:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table itvamode Liste des differents modes de tva.
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttItvamode.
    define variable vhttBuffer as handle  no-undo.
    define buffer itvamode for itvamode.

    vhttBuffer = phttItvamode:default-buffer-handle.
    for each itvamode no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itvamode:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttItvamode no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateItvamode private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLibtva-cd    as handle  no-undo.
    define buffer itvamode for itvamode.

    create query vhttquery.
    vhttBuffer = ghttItvamode:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttItvamode:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLibtva-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first itvamode exclusive-lock
                where rowid(itvamode) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer itvamode:handle, 'libtva-cd: ', substitute('&1', vhLibtva-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer itvamode:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createItvamode private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer itvamode for itvamode.

    create query vhttquery.
    vhttBuffer = ghttItvamode:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttItvamode:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create itvamode.
            if not outils:copyValidField(buffer itvamode:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteItvamode private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLibtva-cd    as handle  no-undo.
    define buffer itvamode for itvamode.

    create query vhttquery.
    vhttBuffer = ghttItvamode:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttItvamode:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLibtva-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first itvamode exclusive-lock
                where rowid(Itvamode) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer itvamode:handle, 'libtva-cd: ', substitute('&1', vhLibtva-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete itvamode no-error.
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

