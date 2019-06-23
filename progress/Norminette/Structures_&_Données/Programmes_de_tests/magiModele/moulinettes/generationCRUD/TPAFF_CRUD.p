/*------------------------------------------------------------------------
File        : TPAFF_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table TPAFF
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/TPAFF.i}
{application/include/error.i}
define variable ghttTPAFF as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdaff as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur CDAFF, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'CDAFF' then phCdaff = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTpaff private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTpaff.
    run updateTpaff.
    run createTpaff.
end procedure.

procedure setTpaff:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTpaff.
    ghttTpaff = phttTpaff.
    run crudTpaff.
    delete object phttTpaff.
end procedure.

procedure readTpaff:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table TPAFF 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdaff as character  no-undo.
    define input parameter table-handle phttTpaff.
    define variable vhttBuffer as handle no-undo.
    define buffer TPAFF for TPAFF.

    vhttBuffer = phttTpaff:default-buffer-handle.
    for first TPAFF no-lock
        where TPAFF.CDAFF = pcCdaff:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer TPAFF:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTpaff no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTpaff:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table TPAFF 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTpaff.
    define variable vhttBuffer as handle  no-undo.
    define buffer TPAFF for TPAFF.

    vhttBuffer = phttTpaff:default-buffer-handle.
    for each TPAFF no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer TPAFF:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTpaff no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTpaff private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdaff    as handle  no-undo.
    define buffer TPAFF for TPAFF.

    create query vhttquery.
    vhttBuffer = ghttTpaff:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTpaff:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdaff).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first TPAFF exclusive-lock
                where rowid(TPAFF) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer TPAFF:handle, 'CDAFF: ', substitute('&1', vhCdaff:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer TPAFF:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTpaff private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer TPAFF for TPAFF.

    create query vhttquery.
    vhttBuffer = ghttTpaff:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTpaff:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create TPAFF.
            if not outils:copyValidField(buffer TPAFF:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTpaff private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdaff    as handle  no-undo.
    define buffer TPAFF for TPAFF.

    create query vhttquery.
    vhttBuffer = ghttTpaff:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTpaff:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdaff).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first TPAFF exclusive-lock
                where rowid(Tpaff) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer TPAFF:handle, 'CDAFF: ', substitute('&1', vhCdaff:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete TPAFF no-error.
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

