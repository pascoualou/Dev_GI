/*------------------------------------------------------------------------
File        : cintyp_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cintyp
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cintyp.i}
{application/include/error.i}
define variable ghttcintyp as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phType-invest as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur type-invest, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'type-invest' then phType-invest = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCintyp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCintyp.
    run updateCintyp.
    run createCintyp.
end procedure.

procedure setCintyp:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCintyp.
    ghttCintyp = phttCintyp.
    run crudCintyp.
    delete object phttCintyp.
end procedure.

procedure readCintyp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cintyp fichier type d'investissement
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piType-invest as integer    no-undo.
    define input parameter table-handle phttCintyp.
    define variable vhttBuffer as handle no-undo.
    define buffer cintyp for cintyp.

    vhttBuffer = phttCintyp:default-buffer-handle.
    for first cintyp no-lock
        where cintyp.type-invest = piType-invest:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cintyp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCintyp no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCintyp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cintyp fichier type d'investissement
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCintyp.
    define variable vhttBuffer as handle  no-undo.
    define buffer cintyp for cintyp.

    vhttBuffer = phttCintyp:default-buffer-handle.
    for each cintyp no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cintyp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCintyp no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCintyp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhType-invest    as handle  no-undo.
    define buffer cintyp for cintyp.

    create query vhttquery.
    vhttBuffer = ghttCintyp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCintyp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhType-invest).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cintyp exclusive-lock
                where rowid(cintyp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cintyp:handle, 'type-invest: ', substitute('&1', vhType-invest:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cintyp:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCintyp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cintyp for cintyp.

    create query vhttquery.
    vhttBuffer = ghttCintyp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCintyp:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cintyp.
            if not outils:copyValidField(buffer cintyp:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCintyp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhType-invest    as handle  no-undo.
    define buffer cintyp for cintyp.

    create query vhttquery.
    vhttBuffer = ghttCintyp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCintyp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhType-invest).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cintyp exclusive-lock
                where rowid(Cintyp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cintyp:handle, 'type-invest: ', substitute('&1', vhType-invest:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cintyp no-error.
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

