/*------------------------------------------------------------------------
File        : cinces_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cinces
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cinces.i}
{application/include/error.i}
define variable ghttcinces as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCession-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cession-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cession-cle' then phCession-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCinces private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCinces.
    run updateCinces.
    run createCinces.
end procedure.

procedure setCinces:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCinces.
    ghttCinces = phttCinces.
    run crudCinces.
    delete object phttCinces.
end procedure.

procedure readCinces:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cinces Type de cession
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCession-cle as character  no-undo.
    define input parameter table-handle phttCinces.
    define variable vhttBuffer as handle no-undo.
    define buffer cinces for cinces.

    vhttBuffer = phttCinces:default-buffer-handle.
    for first cinces no-lock
        where cinces.cession-cle = pcCession-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinces:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCinces no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCinces:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cinces Type de cession
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCinces.
    define variable vhttBuffer as handle  no-undo.
    define buffer cinces for cinces.

    vhttBuffer = phttCinces:default-buffer-handle.
    for each cinces no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinces:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCinces no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCinces private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCession-cle    as handle  no-undo.
    define buffer cinces for cinces.

    create query vhttquery.
    vhttBuffer = ghttCinces:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCinces:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCession-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cinces exclusive-lock
                where rowid(cinces) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cinces:handle, 'cession-cle: ', substitute('&1', vhCession-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cinces:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCinces private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cinces for cinces.

    create query vhttquery.
    vhttBuffer = ghttCinces:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCinces:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cinces.
            if not outils:copyValidField(buffer cinces:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCinces private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCession-cle    as handle  no-undo.
    define buffer cinces for cinces.

    create query vhttquery.
    vhttBuffer = ghttCinces:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCinces:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCession-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cinces exclusive-lock
                where rowid(Cinces) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cinces:handle, 'cession-cle: ', substitute('&1', vhCession-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cinces no-error.
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

