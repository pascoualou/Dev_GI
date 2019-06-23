/*------------------------------------------------------------------------
File        : budle_CRUD.p
Purpose     : Librairie contenant les procedures li�es � la mise � jour de la table budle
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table � condition
              que les champs de l'index unique soient tous pr�sents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit �tre positionn�e juste apr�s using
//{include/budle.i}
{application/include/error.i}
define variable ghttbudle as handle no-undo.      // le handle de la temp table � mettre � jour


function getIndexField returns logical private(phBuffer as handle, output phTpbud as handle, output phNomdt as handle, output phNobud as handle, output phNoavt as handle):
    /*------------------------------------------------------------------------------
    Purpose: r�cup�re les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpbud/nomdt/nobud/noavt, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpbud' then phTpbud = phBuffer:buffer-field(vi).
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
            when 'nobud' then phNobud = phBuffer:buffer-field(vi).
            when 'noavt' then phNoavt = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudBudle private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteBudle.
    run updateBudle.
    run createBudle.
end procedure.

procedure setBudle:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttBudle.
    ghttBudle = phttBudle.
    run crudBudle.
    delete object phttBudle.
end procedure.

procedure readBudle:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table budle 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpbud as character  no-undo.
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNobud as int64      no-undo.
    define input parameter piNoavt as integer    no-undo.
    define input parameter table-handle phttBudle.
    define variable vhttBuffer as handle no-undo.
    define buffer budle for budle.

    vhttBuffer = phttBudle:default-buffer-handle.
    for first budle no-lock
        where budle.tpbud = pcTpbud
          and budle.nomdt = piNomdt
          and budle.nobud = piNobud
          and budle.noavt = piNoavt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer budle:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttBudle no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getBudle:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table budle 
    Notes  : service externe. Crit�re piNobud = ? si pas � prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpbud as character  no-undo.
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNobud as int64      no-undo.
    define input parameter table-handle phttBudle.
    define variable vhttBuffer as handle  no-undo.
    define buffer budle for budle.

    vhttBuffer = phttBudle:default-buffer-handle.
    if piNobud = ?
    then for each budle no-lock
        where budle.tpbud = pcTpbud
          and budle.nomdt = piNomdt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer budle:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each budle no-lock
        where budle.tpbud = pcTpbud
          and budle.nomdt = piNomdt
          and budle.nobud = piNobud:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer budle:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttBudle no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateBudle private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpbud    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNobud    as handle  no-undo.
    define variable vhNoavt    as handle  no-undo.
    define buffer budle for budle.

    create query vhttquery.
    vhttBuffer = ghttBudle:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttBudle:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpbud, output vhNomdt, output vhNobud, output vhNoavt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first budle exclusive-lock
                where rowid(budle) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer budle:handle, 'tpbud/nomdt/nobud/noavt: ', substitute('&1/&2/&3/&4', vhTpbud:buffer-value(), vhNomdt:buffer-value(), vhNobud:buffer-value(), vhNoavt:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer budle:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createBudle private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer budle for budle.

    create query vhttquery.
    vhttBuffer = ghttBudle:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttBudle:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create budle.
            if not outils:copyValidField(buffer budle:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteBudle private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpbud    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNobud    as handle  no-undo.
    define variable vhNoavt    as handle  no-undo.
    define buffer budle for budle.

    create query vhttquery.
    vhttBuffer = ghttBudle:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttBudle:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpbud, output vhNomdt, output vhNobud, output vhNoavt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first budle exclusive-lock
                where rowid(Budle) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer budle:handle, 'tpbud/nomdt/nobud/noavt: ', substitute('&1/&2/&3/&4', vhTpbud:buffer-value(), vhNomdt:buffer-value(), vhNobud:buffer-value(), vhNoavt:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete budle no-error.
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

