/*------------------------------------------------------------------------
File        : ifdparam_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifdparam
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifdparam.i}
{application/include/error.i}
define variable ghttifdparam as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-dest as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-dest, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-dest' then phSoc-dest = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfdparam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfdparam.
    run updateIfdparam.
    run createIfdparam.
end procedure.

procedure setIfdparam:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfdparam.
    ghttIfdparam = phttIfdparam.
    run crudIfdparam.
    delete object phttIfdparam.
end procedure.

procedure readIfdparam:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifdparam Table des parametres facturation
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-dest as integer    no-undo.
    define input parameter table-handle phttIfdparam.
    define variable vhttBuffer as handle no-undo.
    define buffer ifdparam for ifdparam.

    vhttBuffer = phttIfdparam:default-buffer-handle.
    for first ifdparam no-lock
        where ifdparam.soc-dest = piSoc-dest:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdparam:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdparam no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfdparam:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifdparam Table des parametres facturation
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfdparam.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifdparam for ifdparam.

    vhttBuffer = phttIfdparam:default-buffer-handle.
    for each ifdparam no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdparam:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdparam no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfdparam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-dest    as handle  no-undo.
    define buffer ifdparam for ifdparam.

    create query vhttquery.
    vhttBuffer = ghttIfdparam:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfdparam:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-dest).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdparam exclusive-lock
                where rowid(ifdparam) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdparam:handle, 'soc-dest: ', substitute('&1', vhSoc-dest:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifdparam:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfdparam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifdparam for ifdparam.

    create query vhttquery.
    vhttBuffer = ghttIfdparam:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfdparam:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifdparam.
            if not outils:copyValidField(buffer ifdparam:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfdparam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-dest    as handle  no-undo.
    define buffer ifdparam for ifdparam.

    create query vhttquery.
    vhttBuffer = ghttIfdparam:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfdparam:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-dest).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdparam exclusive-lock
                where rowid(Ifdparam) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdparam:handle, 'soc-dest: ', substitute('&1', vhSoc-dest:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifdparam no-error.
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

