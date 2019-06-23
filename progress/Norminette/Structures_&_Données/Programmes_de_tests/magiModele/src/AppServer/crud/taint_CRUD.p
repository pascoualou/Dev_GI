/*------------------------------------------------------------------------
File        : taint_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table taint
Author(s)   : npo  -  2018/05/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/06/25 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghtttaint as handle no-undo.     // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phTptac as handle, output phNotac as handle, output phTpidt as handle, output phNoidt as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcon/nocon/tptac/notac/tpidt/noidt, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'tptac' then phTptac = phBuffer:buffer-field(vi).
            when 'notac' then phNotac = phBuffer:buffer-field(vi).
            when 'tpidt' then phTpidt = phBuffer:buffer-field(vi).
            when 'noidt' then phNoidt = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTaint private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTaint.
    run updateTaint.
    run createTaint.
end procedure.

procedure setTaint:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTaint.
    ghttTaint = phttTaint.
    run crudTaint.
    delete object phttTaint.
end procedure.

procedure readTaint:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table taint 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as int64      no-undo.
    define input parameter pcTptac as character  no-undo.
    define input parameter piNotac as integer    no-undo.
    define input parameter pcTpidt as character  no-undo.
    define input parameter piNoidt as int64      no-undo.
    define input parameter table-handle phttTaint.
    define variable vhttBuffer as handle no-undo.
    define buffer taint for taint.

    vhttBuffer = phttTaint:default-buffer-handle.
    for first taint no-lock
        where taint.tpcon = pcTpcon
          and taint.nocon = piNocon
          and taint.tptac = pcTptac
          and taint.notac = piNotac
          and taint.tpidt = pcTpidt
          and taint.noidt = piNoidt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer taint:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTaint no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTaint:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table taint 
    Notes  : service externe. Critère pcTpidt = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as int64      no-undo.
    define input parameter pcTptac as character  no-undo.
    define input parameter piNotac as integer    no-undo.
    define input parameter pcTpidt as character  no-undo.
    define input parameter table-handle phttTaint.
    define variable vhttBuffer as handle  no-undo.
    define buffer taint for taint.

    vhttBuffer = phttTaint:default-buffer-handle.
    if pcTpidt = ?
    then for each taint no-lock
        where taint.tpcon = pcTpcon
          and taint.nocon = piNocon
          and taint.tptac = pcTptac
          and taint.notac = piNotac:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer taint:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each taint no-lock
        where taint.tpcon = pcTpcon
          and taint.nocon = piNocon
          and taint.tptac = pcTptac
          and taint.notac = piNotac
          and taint.tpidt = pcTpidt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer taint:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTaint no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTaint private:
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
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define buffer taint for taint.

    create query vhttquery.
    vhttBuffer = ghttTaint:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTaint:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhTptac, output vhNotac, output vhTpidt, output vhNoidt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first taint exclusive-lock
                where rowid(taint) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer taint:handle, 'tpcon/nocon/tptac/notac/tpidt/noidt: ', substitute('&1/&2/&3/&4/&5/&6', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhTptac:buffer-value(), vhNotac:buffer-value(), vhTpidt:buffer-value(), vhNoidt:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer taint:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTaint private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer taint for taint.

    create query vhttquery.
    vhttBuffer = ghttTaint:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTaint:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create taint.
            if not outils:copyValidField(buffer taint:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTaint private:
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
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define buffer taint for taint.

    create query vhttquery.
    vhttBuffer = ghttTaint:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTaint:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhTptac, output vhNotac, output vhTpidt, output vhNoidt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first taint exclusive-lock
                where rowid(Taint) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer taint:handle, 'tpcon/nocon/tptac/notac/tpidt/noidt: ', substitute('&1/&2/&3/&4/&5/&6', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhTptac:buffer-value(), vhNotac:buffer-value(), vhTpidt:buffer-value(), vhNoidt:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete taint no-error.
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

