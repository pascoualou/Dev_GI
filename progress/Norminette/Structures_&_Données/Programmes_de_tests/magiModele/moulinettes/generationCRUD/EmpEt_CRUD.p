/*------------------------------------------------------------------------
File        : EmpEt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table EmpEt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/EmpEt.i}
{application/include/error.i}
define variable ghttEmpEt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNolie as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nolie, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nolie' then phNolie = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudEmpet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteEmpet.
    run updateEmpet.
    run createEmpet.
end procedure.

procedure setEmpet:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEmpet.
    ghttEmpet = phttEmpet.
    run crudEmpet.
    delete object phttEmpet.
end procedure.

procedure readEmpet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table EmpEt Emprunts : Entete appel de fond Emprunt
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNolie as integer    no-undo.
    define input parameter table-handle phttEmpet.
    define variable vhttBuffer as handle no-undo.
    define buffer EmpEt for EmpEt.

    vhttBuffer = phttEmpet:default-buffer-handle.
    for first EmpEt no-lock
        where EmpEt.nolie = piNolie:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer EmpEt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEmpet no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getEmpet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table EmpEt Emprunts : Entete appel de fond Emprunt
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEmpet.
    define variable vhttBuffer as handle  no-undo.
    define buffer EmpEt for EmpEt.

    vhttBuffer = phttEmpet:default-buffer-handle.
    for each EmpEt no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer EmpEt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEmpet no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateEmpet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNolie    as handle  no-undo.
    define buffer EmpEt for EmpEt.

    create query vhttquery.
    vhttBuffer = ghttEmpet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttEmpet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNolie).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first EmpEt exclusive-lock
                where rowid(EmpEt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer EmpEt:handle, 'nolie: ', substitute('&1', vhNolie:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer EmpEt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createEmpet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer EmpEt for EmpEt.

    create query vhttquery.
    vhttBuffer = ghttEmpet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttEmpet:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create EmpEt.
            if not outils:copyValidField(buffer EmpEt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteEmpet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNolie    as handle  no-undo.
    define buffer EmpEt for EmpEt.

    create query vhttquery.
    vhttBuffer = ghttEmpet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttEmpet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNolie).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first EmpEt exclusive-lock
                where rowid(Empet) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer EmpEt:handle, 'nolie: ', substitute('&1', vhNolie:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete EmpEt no-error.
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

