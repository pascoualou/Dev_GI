/*-----------------------------------------------------------------------------
File        : acpte_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table acpte
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/04/27 - phm: OK
-----------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttacpte as handle no-undo.     // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phNorol as handle, output phNoacp as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur , 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.

    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when "tpcon" then phTpcon = phBuffer:buffer-field(vi).
            when "nocon" then phNocon = phBuffer:buffer-field(vi).
            when "norol" then phNorol = phBuffer:buffer-field(vi).
            when "noacp" then phNoacp = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAcpte private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAcpte.
    run updateAcpte.
    run createAcpte.
end procedure.

procedure setAcpte:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAcpte.
    ghttAcpte = phttAcpte.
    run crudAcpte.
    delete object phttAcpte.
end procedure.

procedure readAcpte:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table acpte 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character no-undo.
    define input parameter piNocon as integer   no-undo.
    define input parameter piNorol as integer   no-undo.
    define input parameter piNoacp as integer   no-undo.
    define input parameter table-handle phttAcpte.
    define variable vhttBuffer as handle no-undo.
    define buffer acpte for acpte.

    vhttBuffer = phttAcpte:default-buffer-handle.
    for first acpte no-lock
        where acpte.tpcon = pcTpcon
          and acpte.nocon = piNocon
          and acpte.norol = piNorol
          and acpte.noacp = piNoacp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer acpte:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAcpte no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAcpte:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table acpte 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character no-undo.
    define input parameter piNocon as integer   no-undo.
    define input parameter piNorol as integer   no-undo.
    define input parameter table-handle phttAcpte.
    define variable vhttBuffer as handle  no-undo.
    define buffer acpte for acpte.

    vhttBuffer = phttAcpte:default-buffer-handle.
    if piNorol = ?
    then for each acpte no-lock
        where acpte.tpcon = pcTpcon
          and acpte.nocon = piNocon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer acpte:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each acpte no-lock
        where acpte.tpcon = pcTpcon
          and acpte.nocon = piNocon
          and acpte.norol = piNorol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer acpte:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAcpte no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAcpte private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhNoacp    as handle  no-undo.
    define buffer acpte for acpte.

    create query vhttquery.
    vhttBuffer = ghttAcpte:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAcpte:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon,output vhNorol,output vhNoacp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first acpte exclusive-lock
                where rowid(acpte) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer acpte:handle, 'tpcon/nocon/norol/noacp: ', substitute('&1/&2/&3/&4', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNorol:buffer-value(), vhNoacp:buffer-value()), vhttBuffer::dtTimestamp) 
            or not outils:copyValidField(buffer acpte:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAcpte private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer acpte for acpte.

    create query vhttquery.
    vhttBuffer = ghttAcpte:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAcpte:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create acpte.
            if not outils:copyValidField(buffer acpte:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAcpte private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhNoacp    as handle  no-undo.
    define buffer acpte for acpte.

    create query vhttquery.
    vhttBuffer = ghttAcpte:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAcpte:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon,output vhNorol,output vhNoacp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first acpte exclusive-lock
                where rowid(Acpte) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer acpte:handle, 'tpcon/nocon/norol/noacp: ', substitute('&1/&2/&3/&4', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNorol:buffer-value(), vhNoacp:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete acpte no-error.
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

procedure deleteAcpteSurContrat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as integer   no-undo.
    
    define buffer acpte for acpte.

message "deleteAcpteSurContrat "  pcTypeContrat "// " piNumeroContrat.

blocTrans:
    do transaction:
        for each acpte exclusive-lock
           where acpte.tpcon = pcTypeContrat
             and acpte.nocon = piNumeroContrat:
            delete acpte no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
