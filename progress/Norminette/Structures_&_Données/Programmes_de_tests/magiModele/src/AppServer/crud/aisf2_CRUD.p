/*------------------------------------------------------------------------
File        : aisf2_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table aisf2
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/09/13 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttaisf2 as handle no-undo.     // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phNomdt as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur , 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
        end case.
    end.
end function.

procedure crudAisf2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAisf2.
    run updateAisf2.
    run createAisf2.
end procedure.

procedure setAisf2:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAisf2.
    ghttAisf2 = phttAisf2.
    run crudAisf2.
    delete object phttAisf2.
end procedure.

procedure readAisf2:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table aisf2 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAisf2.
    define variable vhttBuffer as handle no-undo.
    define buffer aisf2 for aisf2.

    vhttBuffer = phttAisf2:default-buffer-handle.
    for first aisf2 no-lock
        where :
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aisf2:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAisf2 no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAisf2:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table aisf2 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAisf2.
    define variable vhttBuffer as handle  no-undo.
    define buffer aisf2 for aisf2.

    vhttBuffer = phttAisf2:default-buffer-handle.
    for each aisf2 no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aisf2:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAisf2 no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAisf2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define buffer aisf2 for aisf2.

    create query vhttquery.
    vhttBuffer = ghttAisf2:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAisf2:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aisf2 exclusive-lock
                where rowid(aisf2) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aisf2:handle, 'nomdt: ', substitute('&1', vhNomdt:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer aisf2:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAisf2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer aisf2 for aisf2.

    create query vhttquery.
    vhttBuffer = ghttAisf2:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAisf2:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create aisf2.
            if not outils:copyValidField(buffer aisf2:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAisf2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define buffer aisf2 for aisf2.

    create query vhttquery.
    vhttBuffer = ghttAisf2:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAisf2:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aisf2 exclusive-lock
                where rowid(Aisf2) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aisf2:handle, 'nomdt: ', substitute('&1', vhNomdt:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete aisf2 no-error.
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

procedure deleteAisf2SurMandat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as integer no-undo.
    
    define buffer aisf2 for aisf2.

blocTrans:
    do transaction:
        // whole-index corrige par la creation dans la version d'un index sur nomdt
        for each aisf2 exclusive-lock
            where aisf2.nomdt = piNumeroMandat:
            delete aisf2 no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
