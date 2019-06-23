/*------------------------------------------------------------------------
File        : milli_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table milli
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/milli.i}
{application/include/error.i}
define variable ghttmilli as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoimm as handle, output phCdcle as handle, output phNorep as handle, output phNolot as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noimm/cdcle/norep/nolot, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noimm' then phNoimm = phBuffer:buffer-field(vi).
            when 'cdcle' then phCdcle = phBuffer:buffer-field(vi).
            when 'norep' then phNorep = phBuffer:buffer-field(vi).
            when 'nolot' then phNolot = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudMilli private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteMilli.
    run updateMilli.
    run createMilli.
end procedure.

procedure setMilli:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttMilli.
    ghttMilli = phttMilli.
    run crudMilli.
    delete object phttMilli.
end procedure.

procedure readMilli:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table milli 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoimm as integer    no-undo.
    define input parameter pcCdcle as character  no-undo.
    define input parameter piNorep as integer    no-undo.
    define input parameter piNolot as integer    no-undo.
    define input parameter table-handle phttMilli.
    define variable vhttBuffer as handle no-undo.
    define buffer milli for milli.

    vhttBuffer = phttMilli:default-buffer-handle.
    for first milli no-lock
        where milli.noimm = piNoimm
          and milli.cdcle = pcCdcle
          and milli.norep = piNorep
          and milli.nolot = piNolot:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer milli:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMilli no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getMilli:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table milli 
    Notes  : service externe. Critère piNorep = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoimm as integer    no-undo.
    define input parameter pcCdcle as character  no-undo.
    define input parameter piNorep as integer    no-undo.
    define input parameter table-handle phttMilli.
    define variable vhttBuffer as handle  no-undo.
    define buffer milli for milli.

    vhttBuffer = phttMilli:default-buffer-handle.
    if piNorep = ?
    then for each milli no-lock
        where milli.noimm = piNoimm
          and milli.cdcle = pcCdcle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer milli:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each milli no-lock
        where milli.noimm = piNoimm
          and milli.cdcle = pcCdcle
          and milli.norep = piNorep:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer milli:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMilli no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateMilli private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhCdcle    as handle  no-undo.
    define variable vhNorep    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define buffer milli for milli.

    create query vhttquery.
    vhttBuffer = ghttMilli:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttMilli:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoimm, output vhCdcle, output vhNorep, output vhNolot).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first milli exclusive-lock
                where rowid(milli) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer milli:handle, 'noimm/cdcle/norep/nolot: ', substitute('&1/&2/&3/&4', vhNoimm:buffer-value(), vhCdcle:buffer-value(), vhNorep:buffer-value(), vhNolot:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer milli:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createMilli private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer milli for milli.

    create query vhttquery.
    vhttBuffer = ghttMilli:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttMilli:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create milli.
            if not outils:copyValidField(buffer milli:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteMilli private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhCdcle    as handle  no-undo.
    define variable vhNorep    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define buffer milli for milli.

    create query vhttquery.
    vhttBuffer = ghttMilli:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttMilli:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoimm, output vhCdcle, output vhNorep, output vhNolot).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first milli exclusive-lock
                where rowid(Milli) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer milli:handle, 'noimm/cdcle/norep/nolot: ', substitute('&1/&2/&3/&4', vhNoimm:buffer-value(), vhCdcle:buffer-value(), vhNorep:buffer-value(), vhNolot:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete milli no-error.
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

