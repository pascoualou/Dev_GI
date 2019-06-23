/*------------------------------------------------------------------------
File        : scsoc_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table scsoc
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/scsoc.i}
{application/include/error.i}
define variable ghttscsoc as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNosoc as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nosoc, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nosoc' then phNosoc = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudScsoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteScsoc.
    run updateScsoc.
    run createScsoc.
end procedure.

procedure setScsoc:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttScsoc.
    ghttScsoc = phttScsoc.
    run crudScsoc.
    delete object phttScsoc.
end procedure.

procedure readScsoc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table scsoc Informations diverses sur la société : elles apparaisent dans la fiche tiers
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNosoc as integer    no-undo.
    define input parameter table-handle phttScsoc.
    define variable vhttBuffer as handle no-undo.
    define buffer scsoc for scsoc.

    vhttBuffer = phttScsoc:default-buffer-handle.
    for first scsoc no-lock
        where scsoc.nosoc = piNosoc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer scsoc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttScsoc no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getScsoc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table scsoc Informations diverses sur la société : elles apparaisent dans la fiche tiers
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttScsoc.
    define variable vhttBuffer as handle  no-undo.
    define buffer scsoc for scsoc.

    vhttBuffer = phttScsoc:default-buffer-handle.
    for each scsoc no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer scsoc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttScsoc no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateScsoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNosoc    as handle  no-undo.
    define buffer scsoc for scsoc.

    create query vhttquery.
    vhttBuffer = ghttScsoc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttScsoc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNosoc).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first scsoc exclusive-lock
                where rowid(scsoc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer scsoc:handle, 'nosoc: ', substitute('&1', vhNosoc:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer scsoc:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createScsoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer scsoc for scsoc.

    create query vhttquery.
    vhttBuffer = ghttScsoc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttScsoc:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create scsoc.
            if not outils:copyValidField(buffer scsoc:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteScsoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNosoc    as handle  no-undo.
    define buffer scsoc for scsoc.

    create query vhttquery.
    vhttBuffer = ghttScsoc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttScsoc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNosoc).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first scsoc exclusive-lock
                where rowid(Scsoc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer scsoc:handle, 'nosoc: ', substitute('&1', vhNosoc:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete scsoc no-error.
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

