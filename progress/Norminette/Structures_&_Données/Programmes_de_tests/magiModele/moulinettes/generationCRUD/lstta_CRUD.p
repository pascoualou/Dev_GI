/*------------------------------------------------------------------------
File        : lstta_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table lstta
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/lstta.i}
{application/include/error.i}
define variable ghttlstta as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTptac as handle, output phNotac as handle, output phTpcon as handle, output phNocon as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tptac/notac/tpcon/nocon, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tptac' then phTptac = phBuffer:buffer-field(vi).
            when 'notac' then phNotac = phBuffer:buffer-field(vi).
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudLstta private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteLstta.
    run updateLstta.
    run createLstta.
end procedure.

procedure setLstta:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttLstta.
    ghttLstta = phttLstta.
    run crudLstta.
    delete object phttLstta.
end procedure.

procedure readLstta:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table lstta 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTptac as character  no-undo.
    define input parameter piNotac as integer    no-undo.
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as int64      no-undo.
    define input parameter table-handle phttLstta.
    define variable vhttBuffer as handle no-undo.
    define buffer lstta for lstta.

    vhttBuffer = phttLstta:default-buffer-handle.
    for first lstta no-lock
        where lstta.tptac = pcTptac
          and lstta.notac = piNotac
          and lstta.tpcon = pcTpcon
          and lstta.nocon = piNocon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer lstta:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLstta no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getLstta:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table lstta 
    Notes  : service externe. Critère pcTpcon = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTptac as character  no-undo.
    define input parameter piNotac as integer    no-undo.
    define input parameter pcTpcon as character  no-undo.
    define input parameter table-handle phttLstta.
    define variable vhttBuffer as handle  no-undo.
    define buffer lstta for lstta.

    vhttBuffer = phttLstta:default-buffer-handle.
    if pcTpcon = ?
    then for each lstta no-lock
        where lstta.tptac = pcTptac
          and lstta.notac = piNotac:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer lstta:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each lstta no-lock
        where lstta.tptac = pcTptac
          and lstta.notac = piNotac
          and lstta.tpcon = pcTpcon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer lstta:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLstta no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateLstta private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTptac    as handle  no-undo.
    define variable vhNotac    as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define buffer lstta for lstta.

    create query vhttquery.
    vhttBuffer = ghttLstta:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttLstta:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTptac, output vhNotac, output vhTpcon, output vhNocon).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first lstta exclusive-lock
                where rowid(lstta) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer lstta:handle, 'tptac/notac/tpcon/nocon: ', substitute('&1/&2/&3/&4', vhTptac:buffer-value(), vhNotac:buffer-value(), vhTpcon:buffer-value(), vhNocon:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer lstta:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createLstta private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer lstta for lstta.

    create query vhttquery.
    vhttBuffer = ghttLstta:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttLstta:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create lstta.
            if not outils:copyValidField(buffer lstta:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteLstta private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTptac    as handle  no-undo.
    define variable vhNotac    as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define buffer lstta for lstta.

    create query vhttquery.
    vhttBuffer = ghttLstta:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttLstta:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTptac, output vhNotac, output vhTpcon, output vhNocon).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first lstta exclusive-lock
                where rowid(Lstta) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer lstta:handle, 'tptac/notac/tpcon/nocon: ', substitute('&1/&2/&3/&4', vhTptac:buffer-value(), vhNotac:buffer-value(), vhTpcon:buffer-value(), vhNocon:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete lstta no-error.
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

