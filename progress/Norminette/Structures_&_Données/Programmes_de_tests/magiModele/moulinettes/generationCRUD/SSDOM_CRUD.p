/*------------------------------------------------------------------------
File        : SSDOM_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table SSDOM
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/SSDOM.i}
{application/include/error.i}
define variable ghttSSDOM as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdsdo as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cdsdo, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cdsdo' then phCdsdo = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSsdom private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSsdom.
    run updateSsdom.
    run createSsdom.
end procedure.

procedure setSsdom:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSsdom.
    ghttSsdom = phttSsdom.
    run crudSsdom.
    delete object phttSsdom.
end procedure.

procedure readSsdom:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table SSDOM Sous-domaine
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdsdo as character  no-undo.
    define input parameter table-handle phttSsdom.
    define variable vhttBuffer as handle no-undo.
    define buffer SSDOM for SSDOM.

    vhttBuffer = phttSsdom:default-buffer-handle.
    for first SSDOM no-lock
        where SSDOM.cdsdo = pcCdsdo:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer SSDOM:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSsdom no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSsdom:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table SSDOM Sous-domaine
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSsdom.
    define variable vhttBuffer as handle  no-undo.
    define buffer SSDOM for SSDOM.

    vhttBuffer = phttSsdom:default-buffer-handle.
    for each SSDOM no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer SSDOM:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSsdom no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSsdom private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdsdo    as handle  no-undo.
    define buffer SSDOM for SSDOM.

    create query vhttquery.
    vhttBuffer = ghttSsdom:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSsdom:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdsdo).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first SSDOM exclusive-lock
                where rowid(SSDOM) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer SSDOM:handle, 'cdsdo: ', substitute('&1', vhCdsdo:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer SSDOM:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSsdom private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer SSDOM for SSDOM.

    create query vhttquery.
    vhttBuffer = ghttSsdom:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSsdom:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create SSDOM.
            if not outils:copyValidField(buffer SSDOM:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSsdom private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdsdo    as handle  no-undo.
    define buffer SSDOM for SSDOM.

    create query vhttquery.
    vhttBuffer = ghttSsdom:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSsdom:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdsdo).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first SSDOM exclusive-lock
                where rowid(Ssdom) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer SSDOM:handle, 'cdsdo: ', substitute('&1', vhCdsdo:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete SSDOM no-error.
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

