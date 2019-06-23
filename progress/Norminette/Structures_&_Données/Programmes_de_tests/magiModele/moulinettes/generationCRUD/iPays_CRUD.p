/*------------------------------------------------------------------------
File        : iPays_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iPays
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iPays.i}
{application/include/error.i}
define variable ghttiPays as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdiso3 as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cdiso3, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cdiso3' then phCdiso3 = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIpays private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIpays.
    run updateIpays.
    run createIpays.
end procedure.

procedure setIpays:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIpays.
    ghttIpays = phttIpays.
    run crudIpays.
    delete object phttIpays.
end procedure.

procedure readIpays:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iPays Code ISO du pays
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdiso3 as character  no-undo.
    define input parameter table-handle phttIpays.
    define variable vhttBuffer as handle no-undo.
    define buffer iPays for iPays.

    vhttBuffer = phttIpays:default-buffer-handle.
    for first iPays no-lock
        where iPays.cdiso3 = pcCdiso3:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iPays:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIpays no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIpays:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iPays Code ISO du pays
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIpays.
    define variable vhttBuffer as handle  no-undo.
    define buffer iPays for iPays.

    vhttBuffer = phttIpays:default-buffer-handle.
    for each iPays no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iPays:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIpays no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIpays private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdiso3    as handle  no-undo.
    define buffer iPays for iPays.

    create query vhttquery.
    vhttBuffer = ghttIpays:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIpays:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdiso3).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iPays exclusive-lock
                where rowid(iPays) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iPays:handle, 'cdiso3: ', substitute('&1', vhCdiso3:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iPays:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIpays private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iPays for iPays.

    create query vhttquery.
    vhttBuffer = ghttIpays:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIpays:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iPays.
            if not outils:copyValidField(buffer iPays:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIpays private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdiso3    as handle  no-undo.
    define buffer iPays for iPays.

    create query vhttquery.
    vhttBuffer = ghttIpays:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIpays:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdiso3).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iPays exclusive-lock
                where rowid(Ipays) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iPays:handle, 'cdiso3: ', substitute('&1', vhCdiso3:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iPays no-error.
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

