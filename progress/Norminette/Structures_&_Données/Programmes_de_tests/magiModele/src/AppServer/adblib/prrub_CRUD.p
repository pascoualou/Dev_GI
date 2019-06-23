/*------------------------------------------------------------------------
File        : prrub_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table prrub
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/05/14 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttprrub as handle no-undo.     // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phCdrub as handle, output phCdlib as handle, output phNoloc as handle, output phMsqtt as handle, output phNoqtt as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cdrub/cdlib/noloc/msqtt/noqtt, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cdrub' then phCdrub = phBuffer:buffer-field(vi).
            when 'cdlib' then phCdlib = phBuffer:buffer-field(vi).
            when 'noloc' then phNoloc = phBuffer:buffer-field(vi).
            when 'msqtt' then phMsqtt = phBuffer:buffer-field(vi).
            when 'noqtt' then phNoqtt = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPrrub private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePrrub.
    run updatePrrub.
    run createPrrub.
end procedure.

procedure setPrrub:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPrrub.
    ghttPrrub = phttPrrub.
    run crudPrrub.
    delete object phttPrrub.
end procedure.

procedure readPrrub:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table prrub 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piCdrub as integer  no-undo.
    define input parameter piCdlib as integer  no-undo.
    define input parameter piNoloc as int64    no-undo.
    define input parameter piMsqtt as integer  no-undo.
    define input parameter piNoqtt as integer  no-undo.
    define input parameter table-handle phttPrrub.
    define variable vhttBuffer as handle no-undo.
    define buffer prrub for prrub.

    vhttBuffer = phttPrrub:default-buffer-handle.
    for first prrub no-lock
        where prrub.cdrub = piCdrub
          and prrub.cdlib = piCdlib
          and prrub.noloc = piNoloc
          and prrub.msqtt = piMsqtt
          and prrub.noqtt = piNoqtt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer prrub:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPrrub no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPrrub:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table prrub 
    Notes  : service externe. Critère piMsqtt = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piCdrub as integer  no-undo.
    define input parameter piCdlib as integer  no-undo.
    define input parameter piNoloc as int64    no-undo.
    define input parameter piMsqtt as integer  no-undo.
    define input parameter table-handle phttPrrub.
    define variable vhttBuffer as handle  no-undo.
    define buffer prrub for prrub.

    vhttBuffer = phttPrrub:default-buffer-handle.
    if piMsqtt = ?
    then for each prrub no-lock
        where prrub.cdrub = piCdrub
          and prrub.cdlib = piCdlib
          and prrub.noloc = piNoloc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer prrub:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each prrub no-lock
        where prrub.cdrub = piCdrub
          and prrub.cdlib = piCdlib
          and prrub.noloc = piNoloc
          and prrub.msqtt = piMsqtt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer prrub:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPrrub no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePrrub private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhCdrub    as handle  no-undo.
    define variable vhCdlib    as handle  no-undo.
    define variable vhNoloc    as handle  no-undo.
    define variable vhMsqtt    as handle  no-undo.
    define variable vhNoqtt    as handle  no-undo.
    define buffer prrub for prrub.

    create query vhttquery.
    vhttBuffer = ghttPrrub:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPrrub:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdrub, output vhCdlib, output vhNoloc, output vhMsqtt, output vhNoqtt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first prrub exclusive-lock
                where rowid(prrub) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer prrub:handle, 'cdrub/cdlib/noloc/msqtt/noqtt: ', substitute('&1/&2/&3/&4/&5', vhCdrub:buffer-value(), vhCdlib:buffer-value(), vhNoloc:buffer-value(), vhMsqtt:buffer-value(), vhNoqtt:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer prrub:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPrrub private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer prrub for prrub.

    create query vhttquery.
    vhttBuffer = ghttPrrub:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPrrub:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create prrub.
            if not outils:copyValidField(buffer prrub:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePrrub private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhCdrub    as handle  no-undo.
    define variable vhCdlib    as handle  no-undo.
    define variable vhNoloc    as handle  no-undo.
    define variable vhMsqtt    as handle  no-undo.
    define variable vhNoqtt    as handle  no-undo.
    define buffer prrub for prrub.

    create query vhttquery.
    vhttBuffer = ghttPrrub:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPrrub:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdrub, output vhCdlib, output vhNoloc, output vhMsqtt, output vhNoqtt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first prrub exclusive-lock
                where rowid(Prrub) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer prrub:handle, 'cdrub/cdlib/noloc/msqtt/noqtt: ', substitute('&1/&2/&3/&4/&5', vhCdrub:buffer-value(), vhCdlib:buffer-value(), vhNoloc:buffer-value(), vhMsqtt:buffer-value(), vhNoqtt:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete prrub no-error.
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
