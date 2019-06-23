/*------------------------------------------------------------------------
File        : itypenat_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table itypenat
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/itypenat.i}
{application/include/error.i}
define variable ghttitypenat as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTypenat-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur typenat-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'typenat-cd' then phTypenat-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudItypenat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteItypenat.
    run updateItypenat.
    run createItypenat.
end procedure.

procedure setItypenat:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttItypenat.
    ghttItypenat = phttItypenat.
    run crudItypenat.
    delete object phttItypenat.
end procedure.

procedure readItypenat:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table itypenat Fichier Nature du Mouvement
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piTypenat-cd as integer    no-undo.
    define input parameter table-handle phttItypenat.
    define variable vhttBuffer as handle no-undo.
    define buffer itypenat for itypenat.

    vhttBuffer = phttItypenat:default-buffer-handle.
    for first itypenat no-lock
        where itypenat.typenat-cd = piTypenat-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itypenat:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttItypenat no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getItypenat:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table itypenat Fichier Nature du Mouvement
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttItypenat.
    define variable vhttBuffer as handle  no-undo.
    define buffer itypenat for itypenat.

    vhttBuffer = phttItypenat:default-buffer-handle.
    for each itypenat no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itypenat:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttItypenat no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateItypenat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTypenat-cd    as handle  no-undo.
    define buffer itypenat for itypenat.

    create query vhttquery.
    vhttBuffer = ghttItypenat:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttItypenat:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTypenat-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first itypenat exclusive-lock
                where rowid(itypenat) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer itypenat:handle, 'typenat-cd: ', substitute('&1', vhTypenat-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer itypenat:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createItypenat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer itypenat for itypenat.

    create query vhttquery.
    vhttBuffer = ghttItypenat:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttItypenat:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create itypenat.
            if not outils:copyValidField(buffer itypenat:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteItypenat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTypenat-cd    as handle  no-undo.
    define buffer itypenat for itypenat.

    create query vhttquery.
    vhttBuffer = ghttItypenat:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttItypenat:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTypenat-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first itypenat exclusive-lock
                where rowid(Itypenat) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer itypenat:handle, 'typenat-cd: ', substitute('&1', vhTypenat-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete itypenat no-error.
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

