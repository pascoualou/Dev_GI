/*------------------------------------------------------------------------
File        : cttac_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cttac
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cttac.i}
{application/include/error.i}
define variable ghttcttac as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phTptac as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcon/nocon/tptac, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'tptac' then phTptac = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCttac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCttac.
    run updateCttac.
    run createCttac.
end procedure.

procedure setCttac:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCttac.
    ghttCttac = phttCttac.
    run crudCttac.
    delete object phttCttac.
end procedure.

procedure readCttac:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cttac 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as int64      no-undo.
    define input parameter pcTptac as character  no-undo.
    define input parameter table-handle phttCttac.
    define variable vhttBuffer as handle no-undo.
    define buffer cttac for cttac.

    vhttBuffer = phttCttac:default-buffer-handle.
    for first cttac no-lock
        where cttac.tpcon = pcTpcon
          and cttac.nocon = piNocon
          and cttac.tptac = pcTptac:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cttac:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCttac no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCttac:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cttac 
    Notes  : service externe. Critère piNocon = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as int64      no-undo.
    define input parameter table-handle phttCttac.
    define variable vhttBuffer as handle  no-undo.
    define buffer cttac for cttac.

    vhttBuffer = phttCttac:default-buffer-handle.
    if piNocon = ?
    then for each cttac no-lock
        where cttac.tpcon = pcTpcon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cttac:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cttac no-lock
        where cttac.tpcon = pcTpcon
          and cttac.nocon = piNocon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cttac:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCttac no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCttac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhTptac    as handle  no-undo.
    define buffer cttac for cttac.

    create query vhttquery.
    vhttBuffer = ghttCttac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCttac:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhTptac).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cttac exclusive-lock
                where rowid(cttac) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cttac:handle, 'tpcon/nocon/tptac: ', substitute('&1/&2/&3', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhTptac:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cttac:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCttac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cttac for cttac.

    create query vhttquery.
    vhttBuffer = ghttCttac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCttac:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cttac.
            if not outils:copyValidField(buffer cttac:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCttac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhTptac    as handle  no-undo.
    define buffer cttac for cttac.

    create query vhttquery.
    vhttBuffer = ghttCttac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCttac:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhTptac).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cttac exclusive-lock
                where rowid(Cttac) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cttac:handle, 'tpcon/nocon/tptac: ', substitute('&1/&2/&3', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhTptac:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cttac no-error.
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

