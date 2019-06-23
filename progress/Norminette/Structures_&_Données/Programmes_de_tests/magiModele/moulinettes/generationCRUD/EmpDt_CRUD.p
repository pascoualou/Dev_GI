/*------------------------------------------------------------------------
File        : EmpDt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table EmpDt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/EmpDt.i}
{application/include/error.i}
define variable ghttEmpDt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNolie as handle, output phNoapp as handle, output phCdcle as handle, output phNocop as handle, output phNolot as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nolie/NoApp/Cdcle/NoCop/NoLot, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nolie' then phNolie = phBuffer:buffer-field(vi).
            when 'NoApp' then phNoapp = phBuffer:buffer-field(vi).
            when 'Cdcle' then phCdcle = phBuffer:buffer-field(vi).
            when 'NoCop' then phNocop = phBuffer:buffer-field(vi).
            when 'NoLot' then phNolot = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudEmpdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteEmpdt.
    run updateEmpdt.
    run createEmpdt.
end procedure.

procedure setEmpdt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEmpdt.
    ghttEmpdt = phttEmpdt.
    run crudEmpdt.
    delete object phttEmpdt.
end procedure.

procedure readEmpdt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table EmpDt Emprunts : Detail appel de fond Emprunt
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNolie as integer    no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter pcCdcle as character  no-undo.
    define input parameter piNocop as integer    no-undo.
    define input parameter piNolot as integer    no-undo.
    define input parameter table-handle phttEmpdt.
    define variable vhttBuffer as handle no-undo.
    define buffer EmpDt for EmpDt.

    vhttBuffer = phttEmpdt:default-buffer-handle.
    for first EmpDt no-lock
        where EmpDt.nolie = piNolie
          and EmpDt.NoApp = piNoapp
          and EmpDt.Cdcle = pcCdcle
          and EmpDt.NoCop = piNocop
          and EmpDt.NoLot = piNolot:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer EmpDt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEmpdt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getEmpdt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table EmpDt Emprunts : Detail appel de fond Emprunt
    Notes  : service externe. Critère piNocop = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNolie as integer    no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter pcCdcle as character  no-undo.
    define input parameter piNocop as integer    no-undo.
    define input parameter table-handle phttEmpdt.
    define variable vhttBuffer as handle  no-undo.
    define buffer EmpDt for EmpDt.

    vhttBuffer = phttEmpdt:default-buffer-handle.
    if piNocop = ?
    then for each EmpDt no-lock
        where EmpDt.nolie = piNolie
          and EmpDt.NoApp = piNoapp
          and EmpDt.Cdcle = pcCdcle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer EmpDt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each EmpDt no-lock
        where EmpDt.nolie = piNolie
          and EmpDt.NoApp = piNoapp
          and EmpDt.Cdcle = pcCdcle
          and EmpDt.NoCop = piNocop:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer EmpDt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEmpdt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateEmpdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNolie    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define variable vhCdcle    as handle  no-undo.
    define variable vhNocop    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define buffer EmpDt for EmpDt.

    create query vhttquery.
    vhttBuffer = ghttEmpdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttEmpdt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNolie, output vhNoapp, output vhCdcle, output vhNocop, output vhNolot).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first EmpDt exclusive-lock
                where rowid(EmpDt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer EmpDt:handle, 'nolie/NoApp/Cdcle/NoCop/NoLot: ', substitute('&1/&2/&3/&4/&5', vhNolie:buffer-value(), vhNoapp:buffer-value(), vhCdcle:buffer-value(), vhNocop:buffer-value(), vhNolot:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer EmpDt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createEmpdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer EmpDt for EmpDt.

    create query vhttquery.
    vhttBuffer = ghttEmpdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttEmpdt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create EmpDt.
            if not outils:copyValidField(buffer EmpDt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteEmpdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNolie    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define variable vhCdcle    as handle  no-undo.
    define variable vhNocop    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define buffer EmpDt for EmpDt.

    create query vhttquery.
    vhttBuffer = ghttEmpdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttEmpdt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNolie, output vhNoapp, output vhCdcle, output vhNocop, output vhNolot).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first EmpDt exclusive-lock
                where rowid(Empdt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer EmpDt:handle, 'nolie/NoApp/Cdcle/NoCop/NoLot: ', substitute('&1/&2/&3/&4/&5', vhNolie:buffer-value(), vhNoapp:buffer-value(), vhCdcle:buffer-value(), vhNocop:buffer-value(), vhNolot:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete EmpDt no-error.
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

