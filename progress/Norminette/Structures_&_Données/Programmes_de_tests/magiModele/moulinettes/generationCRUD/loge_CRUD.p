/*------------------------------------------------------------------------
File        : loge_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table loge
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/loge.i}
{application/include/error.i}
define variable ghttloge as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNolog as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nolog, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nolog' then phNolog = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudLoge private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteLoge.
    run updateLoge.
    run createLoge.
end procedure.

procedure setLoge:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttLoge.
    ghttLoge = phttLoge.
    run crudLoge.
    delete object phttLoge.
end procedure.

procedure readLoge:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table loge Loges de l'immeuble
0913/0130 Gardien(s) par batiment
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNolog as integer    no-undo.
    define input parameter table-handle phttLoge.
    define variable vhttBuffer as handle no-undo.
    define buffer loge for loge.

    vhttBuffer = phttLoge:default-buffer-handle.
    for first loge no-lock
        where loge.nolog = piNolog:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer loge:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLoge no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getLoge:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table loge Loges de l'immeuble
0913/0130 Gardien(s) par batiment
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttLoge.
    define variable vhttBuffer as handle  no-undo.
    define buffer loge for loge.

    vhttBuffer = phttLoge:default-buffer-handle.
    for each loge no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer loge:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLoge no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateLoge private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNolog    as handle  no-undo.
    define buffer loge for loge.

    create query vhttquery.
    vhttBuffer = ghttLoge:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttLoge:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNolog).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first loge exclusive-lock
                where rowid(loge) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer loge:handle, 'nolog: ', substitute('&1', vhNolog:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer loge:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createLoge private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer loge for loge.

    create query vhttquery.
    vhttBuffer = ghttLoge:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttLoge:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create loge.
            if not outils:copyValidField(buffer loge:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteLoge private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNolog    as handle  no-undo.
    define buffer loge for loge.

    create query vhttquery.
    vhttBuffer = ghttLoge:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttLoge:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNolog).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first loge exclusive-lock
                where rowid(Loge) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer loge:handle, 'nolog: ', substitute('&1', vhNolog:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete loge no-error.
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

