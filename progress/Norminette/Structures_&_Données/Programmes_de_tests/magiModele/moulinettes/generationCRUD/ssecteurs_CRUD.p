/*------------------------------------------------------------------------
File        : ssecteurs_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ssecteurs
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ssecteurs.i}
{application/include/error.i}
define variable ghttssecteurs as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur , 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
       end case.
    end.
end function.

procedure crudSsecteurs private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSsecteurs.
    run updateSsecteurs.
    run createSsecteurs.
end procedure.

procedure setSsecteurs:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSsecteurs.
    ghttSsecteurs = phttSsecteurs.
    run crudSsecteurs.
    delete object phttSsecteurs.
end procedure.

procedure readSsecteurs:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ssecteurs 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSsecteurs.
    define variable vhttBuffer as handle no-undo.
    define buffer ssecteurs for ssecteurs.

    vhttBuffer = phttSsecteurs:default-buffer-handle.
    for first ssecteurs no-lock
        where :
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ssecteurs:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSsecteurs no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSsecteurs:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ssecteurs 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSsecteurs.
    define variable vhttBuffer as handle  no-undo.
    define buffer ssecteurs for ssecteurs.

    vhttBuffer = phttSsecteurs:default-buffer-handle.
    for each ssecteurs no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ssecteurs:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSsecteurs no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSsecteurs private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ssecteurs for ssecteurs.

    create query vhttquery.
    vhttBuffer = ghttSsecteurs:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSsecteurs:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ssecteurs exclusive-lock
                where rowid(ssecteurs) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ssecteurs:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ssecteurs:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSsecteurs private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ssecteurs for ssecteurs.

    create query vhttquery.
    vhttBuffer = ghttSsecteurs:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSsecteurs:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ssecteurs.
            if not outils:copyValidField(buffer ssecteurs:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSsecteurs private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ssecteurs for ssecteurs.

    create query vhttquery.
    vhttBuffer = ghttSsecteurs:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSsecteurs:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ssecteurs exclusive-lock
                where rowid(Ssecteurs) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ssecteurs:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ssecteurs no-error.
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

