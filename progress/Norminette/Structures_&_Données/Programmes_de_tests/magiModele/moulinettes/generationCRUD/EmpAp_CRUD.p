/*------------------------------------------------------------------------
File        : EmpAp_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table EmpAp
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/EmpAp.i}
{application/include/error.i}
define variable ghttEmpAp as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phTpemp as handle, output phNoemp as handle, output phNoapp as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur TpCon/NoCon/TpEmp/NoEmp/NoApp, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'TpCon' then phTpcon = phBuffer:buffer-field(vi).
            when 'NoCon' then phNocon = phBuffer:buffer-field(vi).
            when 'TpEmp' then phTpemp = phBuffer:buffer-field(vi).
            when 'NoEmp' then phNoemp = phBuffer:buffer-field(vi).
            when 'NoApp' then phNoapp = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudEmpap private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteEmpap.
    run updateEmpap.
    run createEmpap.
end procedure.

procedure setEmpap:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEmpap.
    ghttEmpap = phttEmpap.
    run crudEmpap.
    delete object phttEmpap.
end procedure.

procedure readEmpap:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table EmpAp Emprunts : Table des n° d'appel de fond
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as integer    no-undo.
    define input parameter pcTpemp as character  no-undo.
    define input parameter piNoemp as integer    no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter table-handle phttEmpap.
    define variable vhttBuffer as handle no-undo.
    define buffer EmpAp for EmpAp.

    vhttBuffer = phttEmpap:default-buffer-handle.
    for first EmpAp no-lock
        where EmpAp.TpCon = pcTpcon
          and EmpAp.NoCon = piNocon
          and EmpAp.TpEmp = pcTpemp
          and EmpAp.NoEmp = piNoemp
          and EmpAp.NoApp = piNoapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer EmpAp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEmpap no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getEmpap:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table EmpAp Emprunts : Table des n° d'appel de fond
    Notes  : service externe. Critère piNoemp = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as integer    no-undo.
    define input parameter pcTpemp as character  no-undo.
    define input parameter piNoemp as integer    no-undo.
    define input parameter table-handle phttEmpap.
    define variable vhttBuffer as handle  no-undo.
    define buffer EmpAp for EmpAp.

    vhttBuffer = phttEmpap:default-buffer-handle.
    if piNoemp = ?
    then for each EmpAp no-lock
        where EmpAp.TpCon = pcTpcon
          and EmpAp.NoCon = piNocon
          and EmpAp.TpEmp = pcTpemp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer EmpAp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each EmpAp no-lock
        where EmpAp.TpCon = pcTpcon
          and EmpAp.NoCon = piNocon
          and EmpAp.TpEmp = pcTpemp
          and EmpAp.NoEmp = piNoemp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer EmpAp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEmpap no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateEmpap private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhTpemp    as handle  no-undo.
    define variable vhNoemp    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define buffer EmpAp for EmpAp.

    create query vhttquery.
    vhttBuffer = ghttEmpap:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttEmpap:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhTpemp, output vhNoemp, output vhNoapp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first EmpAp exclusive-lock
                where rowid(EmpAp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer EmpAp:handle, 'TpCon/NoCon/TpEmp/NoEmp/NoApp: ', substitute('&1/&2/&3/&4/&5', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhTpemp:buffer-value(), vhNoemp:buffer-value(), vhNoapp:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer EmpAp:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createEmpap private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer EmpAp for EmpAp.

    create query vhttquery.
    vhttBuffer = ghttEmpap:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttEmpap:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create EmpAp.
            if not outils:copyValidField(buffer EmpAp:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteEmpap private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhTpemp    as handle  no-undo.
    define variable vhNoemp    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define buffer EmpAp for EmpAp.

    create query vhttquery.
    vhttBuffer = ghttEmpap:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttEmpap:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhTpemp, output vhNoemp, output vhNoapp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first EmpAp exclusive-lock
                where rowid(Empap) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer EmpAp:handle, 'TpCon/NoCon/TpEmp/NoEmp/NoApp: ', substitute('&1/&2/&3/&4/&5', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhTpemp:buffer-value(), vhNoemp:buffer-value(), vhNoapp:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete EmpAp no-error.
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

