/*------------------------------------------------------------------------
File        : burea_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table burea
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/burea.i}
{application/include/error.i}
define variable ghttburea as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNobud as handle, output phCdcle as handle, output phCdrub as handle, output phCdsrb as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nobud/cdcle/cdrub/cdsrb, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nobud' then phNobud = phBuffer:buffer-field(vi).
            when 'cdcle' then phCdcle = phBuffer:buffer-field(vi).
            when 'cdrub' then phCdrub = phBuffer:buffer-field(vi).
            when 'cdsrb' then phCdsrb = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudBurea private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteBurea.
    run updateBurea.
    run createBurea.
end procedure.

procedure setBurea:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttBurea.
    ghttBurea = phttBurea.
    run crudBurea.
    delete object phttBurea.
end procedure.

procedure readBurea:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table burea 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNobud as int64      no-undo.
    define input parameter pcCdcle as character  no-undo.
    define input parameter piCdrub as integer    no-undo.
    define input parameter piCdsrb as integer    no-undo.
    define input parameter table-handle phttBurea.
    define variable vhttBuffer as handle no-undo.
    define buffer burea for burea.

    vhttBuffer = phttBurea:default-buffer-handle.
    for first burea no-lock
        where burea.nobud = piNobud
          and burea.cdcle = pcCdcle
          and burea.cdrub = piCdrub
          and burea.cdsrb = piCdsrb:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer burea:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttBurea no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getBurea:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table burea 
    Notes  : service externe. Critère piCdrub = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNobud as int64      no-undo.
    define input parameter pcCdcle as character  no-undo.
    define input parameter piCdrub as integer    no-undo.
    define input parameter table-handle phttBurea.
    define variable vhttBuffer as handle  no-undo.
    define buffer burea for burea.

    vhttBuffer = phttBurea:default-buffer-handle.
    if piCdrub = ?
    then for each burea no-lock
        where burea.nobud = piNobud
          and burea.cdcle = pcCdcle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer burea:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each burea no-lock
        where burea.nobud = piNobud
          and burea.cdcle = pcCdcle
          and burea.cdrub = piCdrub:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer burea:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttBurea no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateBurea private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNobud    as handle  no-undo.
    define variable vhCdcle    as handle  no-undo.
    define variable vhCdrub    as handle  no-undo.
    define variable vhCdsrb    as handle  no-undo.
    define buffer burea for burea.

    create query vhttquery.
    vhttBuffer = ghttBurea:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttBurea:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNobud, output vhCdcle, output vhCdrub, output vhCdsrb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first burea exclusive-lock
                where rowid(burea) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer burea:handle, 'nobud/cdcle/cdrub/cdsrb: ', substitute('&1/&2/&3/&4', vhNobud:buffer-value(), vhCdcle:buffer-value(), vhCdrub:buffer-value(), vhCdsrb:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer burea:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createBurea private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer burea for burea.

    create query vhttquery.
    vhttBuffer = ghttBurea:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttBurea:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create burea.
            if not outils:copyValidField(buffer burea:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteBurea private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNobud    as handle  no-undo.
    define variable vhCdcle    as handle  no-undo.
    define variable vhCdrub    as handle  no-undo.
    define variable vhCdsrb    as handle  no-undo.
    define buffer burea for burea.

    create query vhttquery.
    vhttBuffer = ghttBurea:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttBurea:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNobud, output vhCdcle, output vhCdrub, output vhCdsrb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first burea exclusive-lock
                where rowid(Burea) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer burea:handle, 'nobud/cdcle/cdrub/cdsrb: ', substitute('&1/&2/&3/&4', vhNobud:buffer-value(), vhCdcle:buffer-value(), vhCdrub:buffer-value(), vhCdsrb:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete burea no-error.
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

