/*------------------------------------------------------------------------
File        : difcum_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table difcum
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/06/18 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttdifcum as handle no-undo.     // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phTprol as handle, output phNorol as handle, output phNoexo as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tprol/norol/noexo, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tprol' then phTprol = phBuffer:buffer-field(vi).
            when 'norol' then phNorol = phBuffer:buffer-field(vi).
            when 'noexo' then phNoexo = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudDifcum private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteDifcum.
    run updateDifcum.
    run createDifcum.
end procedure.

procedure setDifcum:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttDifcum.
    ghttDifcum = phttDifcum.
    run crudDifcum.
    delete object phttDifcum.
end procedure.

procedure readDifcum:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table difcum SalariÃ©s : DIF - cumuls
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTprol as character no-undo.
    define input parameter piNorol as int64     no-undo.
    define input parameter piNoexo as integer   no-undo.
    define input parameter table-handle phttDifcum.

    define variable vhttBuffer as handle no-undo.
    define buffer difcum for difcum.

    vhttBuffer = phttDifcum:default-buffer-handle.
    for first difcum no-lock
        where difcum.tprol = pcTprol
          and difcum.norol = piNorol
          and difcum.noexo = piNoexo:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer difcum:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDifcum no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getDifcum:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table difcum SalariÃ©s : DIF - cumuls
    Notes  : service externe. Critère piNorol = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTprol as character no-undo.
    define input parameter piNorol as int64     no-undo.
    define input parameter table-handle phttDifcum.

    define variable vhttBuffer as handle  no-undo.
    define buffer difcum for difcum.

    vhttBuffer = phttDifcum:default-buffer-handle.
    if piNorol = ?
    then for each difcum no-lock
        where difcum.tprol = pcTprol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer difcum:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each difcum no-lock
        where difcum.tprol = pcTprol
          and difcum.norol = piNorol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer difcum:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDifcum no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateDifcum private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhNoexo    as handle  no-undo.
    define buffer difcum for difcum.

    create query vhttquery.
    vhttBuffer = ghttDifcum:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttDifcum:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTprol, output vhNorol, output vhNoexo).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first difcum exclusive-lock
                where rowid(difcum) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer difcum:handle, 'tprol/norol/noexo: ', substitute('&1/&2/&3', vhTprol:buffer-value(), vhNorol:buffer-value(), vhNoexo:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer difcum:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createDifcum private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer difcum for difcum.

    create query vhttquery.
    vhttBuffer = ghttDifcum:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttDifcum:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create difcum.
            if not outils:copyValidField(buffer difcum:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteDifcum private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhNoexo    as handle  no-undo.
    define buffer difcum for difcum.

    create query vhttquery.
    vhttBuffer = ghttDifcum:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttDifcum:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTprol, output vhNorol, output vhNoexo).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first difcum exclusive-lock
                where rowid(Difcum) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer difcum:handle, 'tprol/norol/noexo: ', substitute('&1/&2/&3', vhTprol:buffer-value(), vhNorol:buffer-value(), vhNoexo:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete difcum no-error.
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

procedure deleteDifcumSurRole:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeRole   as character no-undo.
    define input parameter piNumeroRole as int64     no-undo.

    define buffer difcum for difcum.

blocTrans:
    do transaction:
        for each difcum exclusive-lock
            where difcum.tprol = pcTypeRole
              and difcum.norol = piNumeroRole:  
            delete difcum no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
