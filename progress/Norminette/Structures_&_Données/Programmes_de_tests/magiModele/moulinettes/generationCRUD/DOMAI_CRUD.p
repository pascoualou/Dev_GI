/*------------------------------------------------------------------------
File        : DOMAI_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table DOMAI
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/DOMAI.i}
{application/include/error.i}
define variable ghttDOMAI as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCddom as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cddom, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cddom' then phCddom = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudDomai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteDomai.
    run updateDomai.
    run createDomai.
end procedure.

procedure setDomai:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttDomai.
    ghttDomai = phttDomai.
    run crudDomai.
    delete object phttDomai.
end procedure.

procedure readDomai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table DOMAI Domaine
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCddom as character  no-undo.
    define input parameter table-handle phttDomai.
    define variable vhttBuffer as handle no-undo.
    define buffer DOMAI for DOMAI.

    vhttBuffer = phttDomai:default-buffer-handle.
    for first DOMAI no-lock
        where DOMAI.cddom = pcCddom:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DOMAI:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDomai no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getDomai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table DOMAI Domaine
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttDomai.
    define variable vhttBuffer as handle  no-undo.
    define buffer DOMAI for DOMAI.

    vhttBuffer = phttDomai:default-buffer-handle.
    for each DOMAI no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DOMAI:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDomai no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateDomai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCddom    as handle  no-undo.
    define buffer DOMAI for DOMAI.

    create query vhttquery.
    vhttBuffer = ghttDomai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttDomai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCddom).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first DOMAI exclusive-lock
                where rowid(DOMAI) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer DOMAI:handle, 'cddom: ', substitute('&1', vhCddom:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer DOMAI:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createDomai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer DOMAI for DOMAI.

    create query vhttquery.
    vhttBuffer = ghttDomai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttDomai:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create DOMAI.
            if not outils:copyValidField(buffer DOMAI:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteDomai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCddom    as handle  no-undo.
    define buffer DOMAI for DOMAI.

    create query vhttquery.
    vhttBuffer = ghttDomai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttDomai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCddom).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first DOMAI exclusive-lock
                where rowid(Domai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer DOMAI:handle, 'cddom: ', substitute('&1', vhCddom:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete DOMAI no-error.
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

