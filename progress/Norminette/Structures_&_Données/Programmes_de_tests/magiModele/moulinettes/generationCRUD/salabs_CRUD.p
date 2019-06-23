/*------------------------------------------------------------------------
File        : salabs_CRUD.p
Purpose     : Librairie contenant les procedures li�es � la mise � jour de la table salabs
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table � condition
              que les champs de l'index unique soient tous pr�sents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit �tre positionn�e juste apr�s using
//{include/salabs.i}
{application/include/error.i}
define variable ghttsalabs as handle no-undo.      // le handle de la temp table � mettre � jour


function getIndexField returns logical private(phBuffer as handle, output phTprol as handle, output phNorol as handle, output phNoord as handle):
    /*------------------------------------------------------------------------------
    Purpose: r�cup�re les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tprol/norol/noord, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tprol' then phTprol = phBuffer:buffer-field(vi).
            when 'norol' then phNorol = phBuffer:buffer-field(vi).
            when 'noord' then phNoord = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSalabs private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSalabs.
    run updateSalabs.
    run createSalabs.
end procedure.

procedure setSalabs:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSalabs.
    ghttSalabs = phttSalabs.
    run crudSalabs.
    delete object phttSalabs.
end procedure.

procedure readSalabs:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table salabs 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTprol as character  no-undo.
    define input parameter piNorol as int64      no-undo.
    define input parameter piNoord as integer    no-undo.
    define input parameter table-handle phttSalabs.
    define variable vhttBuffer as handle no-undo.
    define buffer salabs for salabs.

    vhttBuffer = phttSalabs:default-buffer-handle.
    for first salabs no-lock
        where salabs.tprol = pcTprol
          and salabs.norol = piNorol
          and salabs.noord = piNoord:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer salabs:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSalabs no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSalabs:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table salabs 
    Notes  : service externe. Crit�re piNorol = ? si pas � prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTprol as character  no-undo.
    define input parameter piNorol as int64      no-undo.
    define input parameter table-handle phttSalabs.
    define variable vhttBuffer as handle  no-undo.
    define buffer salabs for salabs.

    vhttBuffer = phttSalabs:default-buffer-handle.
    if piNorol = ?
    then for each salabs no-lock
        where salabs.tprol = pcTprol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer salabs:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each salabs no-lock
        where salabs.tprol = pcTprol
          and salabs.norol = piNorol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer salabs:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSalabs no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSalabs private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer salabs for salabs.

    create query vhttquery.
    vhttBuffer = ghttSalabs:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSalabs:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTprol, output vhNorol, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first salabs exclusive-lock
                where rowid(salabs) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer salabs:handle, 'tprol/norol/noord: ', substitute('&1/&2/&3', vhTprol:buffer-value(), vhNorol:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer salabs:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSalabs private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer salabs for salabs.

    create query vhttquery.
    vhttBuffer = ghttSalabs:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSalabs:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create salabs.
            if not outils:copyValidField(buffer salabs:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSalabs private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer salabs for salabs.

    create query vhttquery.
    vhttBuffer = ghttSalabs:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSalabs:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTprol, output vhNorol, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first salabs exclusive-lock
                where rowid(Salabs) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer salabs:handle, 'tprol/norol/noord: ', substitute('&1/&2/&3', vhTprol:buffer-value(), vhNorol:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete salabs no-error.
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

