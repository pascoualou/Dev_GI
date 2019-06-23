/*------------------------------------------------------------------------
File        : clerol_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table clerol
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/clerol.i}
{application/include/error.i}
define variable ghttclerol as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phNoord as handle, output phCdcle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcon/nocon/noord/cdcle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'noord' then phNoord = phBuffer:buffer-field(vi).
            when 'cdcle' then phCdcle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudClerol private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteClerol.
    run updateClerol.
    run createClerol.
end procedure.

procedure setClerol:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttClerol.
    ghttClerol = phttClerol.
    run crudClerol.
    delete object phttClerol.
end procedure.

procedure readClerol:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table clerol 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as int64      no-undo.
    define input parameter piNoord as integer    no-undo.
    define input parameter pcCdcle as character  no-undo.
    define input parameter table-handle phttClerol.
    define variable vhttBuffer as handle no-undo.
    define buffer clerol for clerol.

    vhttBuffer = phttClerol:default-buffer-handle.
    for first clerol no-lock
        where clerol.tpcon = pcTpcon
          and clerol.nocon = piNocon
          and clerol.noord = piNoord
          and clerol.cdcle = pcCdcle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer clerol:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttClerol no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getClerol:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table clerol 
    Notes  : service externe. Critère piNoord = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as int64      no-undo.
    define input parameter piNoord as integer    no-undo.
    define input parameter table-handle phttClerol.
    define variable vhttBuffer as handle  no-undo.
    define buffer clerol for clerol.

    vhttBuffer = phttClerol:default-buffer-handle.
    if piNoord = ?
    then for each clerol no-lock
        where clerol.tpcon = pcTpcon
          and clerol.nocon = piNocon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer clerol:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each clerol no-lock
        where clerol.tpcon = pcTpcon
          and clerol.nocon = piNocon
          and clerol.noord = piNoord:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer clerol:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttClerol no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateClerol private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define variable vhCdcle    as handle  no-undo.
    define buffer clerol for clerol.

    create query vhttquery.
    vhttBuffer = ghttClerol:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttClerol:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNoord, output vhCdcle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first clerol exclusive-lock
                where rowid(clerol) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer clerol:handle, 'tpcon/nocon/noord/cdcle: ', substitute('&1/&2/&3/&4', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNoord:buffer-value(), vhCdcle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer clerol:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createClerol private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer clerol for clerol.

    create query vhttquery.
    vhttBuffer = ghttClerol:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttClerol:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create clerol.
            if not outils:copyValidField(buffer clerol:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteClerol private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define variable vhCdcle    as handle  no-undo.
    define buffer clerol for clerol.

    create query vhttquery.
    vhttBuffer = ghttClerol:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttClerol:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNoord, output vhCdcle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first clerol exclusive-lock
                where rowid(Clerol) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer clerol:handle, 'tpcon/nocon/noord/cdcle: ', substitute('&1/&2/&3/&4', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNoord:buffer-value(), vhCdcle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete clerol no-error.
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

