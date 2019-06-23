/*------------------------------------------------------------------------
File        : RqChpDet_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table RqChpDet
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/RqChpDet.i}
{application/include/error.i}
define variable ghttRqChpDet as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur , 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
       end case.
    end.
end function.

procedure crudRqchpdet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteRqchpdet.
    run updateRqchpdet.
    run createRqchpdet.
end procedure.

procedure setRqchpdet:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRqchpdet.
    ghttRqchpdet = phttRqchpdet.
    run crudRqchpdet.
    delete object phttRqchpdet.
end procedure.

procedure readRqchpdet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table RqChpDet Détails du champ : chaque enregistrement correspond à une colonne du browse correspondant
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRqchpdet.
    define variable vhttBuffer as handle no-undo.
    define buffer RqChpDet for RqChpDet.

    vhttBuffer = phttRqchpdet:default-buffer-handle.
    for first RqChpDet no-lock
        where :
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer RqChpDet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRqchpdet no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getRqchpdet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table RqChpDet Détails du champ : chaque enregistrement correspond à une colonne du browse correspondant
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRqchpdet.
    define variable vhttBuffer as handle  no-undo.
    define buffer RqChpDet for RqChpDet.

    vhttBuffer = phttRqchpdet:default-buffer-handle.
    for each RqChpDet no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer RqChpDet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRqchpdet no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateRqchpdet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer RqChpDet for RqChpDet.

    create query vhttquery.
    vhttBuffer = ghttRqchpdet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttRqchpdet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first RqChpDet exclusive-lock
                where rowid(RqChpDet) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer RqChpDet:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer RqChpDet:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createRqchpdet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer RqChpDet for RqChpDet.

    create query vhttquery.
    vhttBuffer = ghttRqchpdet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttRqchpdet:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create RqChpDet.
            if not outils:copyValidField(buffer RqChpDet:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteRqchpdet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer RqChpDet for RqChpDet.

    create query vhttquery.
    vhttBuffer = ghttRqchpdet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttRqchpdet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first RqChpDet exclusive-lock
                where rowid(Rqchpdet) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer RqChpDet:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete RqChpDet no-error.
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

