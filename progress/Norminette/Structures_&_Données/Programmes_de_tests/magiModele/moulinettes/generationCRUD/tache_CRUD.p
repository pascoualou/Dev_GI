/*------------------------------------------------------------------------
File        : tache_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table tache
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/tache.i}
{application/include/error.i}
define variable ghtttache as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(
    phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phTptac as handle, output phNotac as handle, output phNoita as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noita, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'tptac' then phTptac = phBuffer:buffer-field(vi).
            when 'notac' then phNotac = phBuffer:buffer-field(vi).
            when 'noita' then phNoita = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTache private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTache.
    run updateTache.
    run createTache.
end procedure.

procedure setTache:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTache.
    ghttTache = phttTache.
    run crudTache.
    delete object phttTache.
end procedure.

procedure readTache:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table tache 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoita as int64      no-undo.
    define input parameter table-handle phttTache.
    define variable vhttBuffer as handle no-undo.
    define buffer tache for tache.

    vhttBuffer = phttTache:default-buffer-handle.
    for first tache no-lock
        where tache.noita = piNoita:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tache:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTache no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTache:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table tache 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTache.
    define variable vhttBuffer as handle  no-undo.
    define buffer tache for tache.

    vhttBuffer = phttTache:default-buffer-handle.
    for each tache no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tache:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTache no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTache private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhTptac    as handle  no-undo.
    define variable vhNotac    as handle  no-undo.
    define variable vhNoita    as handle  no-undo.
    define variable viNoita    as int64   no-undo.
    define variable viNotac    as integer no-undo.
    define buffer tache for tache.

    create query vhttquery.
    vhttBuffer = ghttTache:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTache:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhTptac, output vhNotac, output vhNoita).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tache exclusive-lock
                where rowid(tache) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tache:handle,
                                'tpcon/nocon/tptac/notac: ',
                                substitute('&1/&2/&3/&4', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhTptac:buffer-value(), vhNotac:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer tache:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTache private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhTptac    as handle  no-undo.
    define variable vhNotac    as handle  no-undo.
    define variable vhNoita    as handle  no-undo.
    define variable viNoita    as int64   no-undo.
    define variable viNotac    as integer no-undo.
    define buffer tache for tache.

    create query vhttquery.
    vhttBuffer = ghttTache:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTache:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhTptac, output vhNotac, output vhNoita).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            run getNextTache(vhTpcon:buffer-value(), vhNocon:buffer-value(), vhTptac:buffer-value(),
                             output viNoita, output viNotac).
            assign
                vhNoita:buffer-value() = viNoita
                vhNotac:buffer-value() = viNotac
            .
            create tache.
            if not outils:copyValidField(buffer tache:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTache private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhTptac    as handle  no-undo.
    define variable vhNotac    as handle  no-undo.
    define variable vhNoita    as handle  no-undo.
    define variable viNoita    as int64   no-undo.
    define variable viNotac    as integer no-undo.
    define buffer tache for tache.

    create query vhttquery.
    vhttBuffer = ghttTache:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTache:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhTptac, output vhNotac, output vhNoita).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tache exclusive-lock
                where rowid(Tache) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tache:handle,
                                'tpcon/nocon/tptac/notac: ',
                                substitute('&1/&2/&3/&4', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhTptac:buffer-value(), vhNotac:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete tache no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.
