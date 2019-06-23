/*------------------------------------------------------------------------
File        : DosEt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table DosEt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/DosEt.i}
{application/include/error.i}
define variable ghttDosEt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoidt as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur NoIdt, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'NoIdt' then phNoidt = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudDoset private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteDoset.
    run updateDoset.
    run createDoset.
end procedure.

procedure setDoset:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttDoset.
    ghttDoset = phttDoset.
    run crudDoset.
    delete object phttDoset.
end procedure.

procedure readDoset:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table DosEt Chaine Travaux : Entete appel de fond travaux
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoidt as integer    no-undo.
    define input parameter table-handle phttDoset.
    define variable vhttBuffer as handle no-undo.
    define buffer DosEt for DosEt.

    vhttBuffer = phttDoset:default-buffer-handle.
    for first DosEt no-lock
        where DosEt.NoIdt = piNoidt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DosEt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDoset no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getDoset:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table DosEt Chaine Travaux : Entete appel de fond travaux
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttDoset.
    define variable vhttBuffer as handle  no-undo.
    define buffer DosEt for DosEt.

    vhttBuffer = phttDoset:default-buffer-handle.
    for each DosEt no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DosEt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDoset no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateDoset private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoidt    as handle  no-undo.
    define buffer DosEt for DosEt.

    create query vhttquery.
    vhttBuffer = ghttDoset:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttDoset:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoidt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first DosEt exclusive-lock
                where rowid(DosEt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer DosEt:handle, 'NoIdt: ', substitute('&1', vhNoidt:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer DosEt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createDoset private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer DosEt for DosEt.

    create query vhttquery.
    vhttBuffer = ghttDoset:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttDoset:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create DosEt.
            if not outils:copyValidField(buffer DosEt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteDoset private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoidt    as handle  no-undo.
    define buffer DosEt for DosEt.

    create query vhttquery.
    vhttBuffer = ghttDoset:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttDoset:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoidt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first DosEt exclusive-lock
                where rowid(Doset) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer DosEt:handle, 'NoIdt: ', substitute('&1', vhNoidt:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete DosEt no-error.
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

