/*------------------------------------------------------------------------
File        : difheu_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table difheu
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/difheu.i}
{application/include/error.i}
define variable ghttdifheu as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTprol as handle, output phNorol as handle, output phMspai as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tprol/norol/mspai, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tprol' then phTprol = phBuffer:buffer-field(vi).
            when 'norol' then phNorol = phBuffer:buffer-field(vi).
            when 'mspai' then phMspai = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudDifheu private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteDifheu.
    run updateDifheu.
    run createDifheu.
end procedure.

procedure setDifheu:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttDifheu.
    ghttDifheu = phttDifheu.
    run crudDifheu.
    delete object phttDifheu.
end procedure.

procedure readDifheu:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table difheu Salariés : DIF - crédit d'heures
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTprol as character  no-undo.
    define input parameter piNorol as int64      no-undo.
    define input parameter piMspai as integer    no-undo.
    define input parameter table-handle phttDifheu.
    define variable vhttBuffer as handle no-undo.
    define buffer difheu for difheu.

    vhttBuffer = phttDifheu:default-buffer-handle.
    for first difheu no-lock
        where difheu.tprol = pcTprol
          and difheu.norol = piNorol
          and difheu.mspai = piMspai:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer difheu:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDifheu no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getDifheu:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table difheu Salariés : DIF - crédit d'heures
    Notes  : service externe. Critère piNorol = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTprol as character  no-undo.
    define input parameter piNorol as int64      no-undo.
    define input parameter table-handle phttDifheu.
    define variable vhttBuffer as handle  no-undo.
    define buffer difheu for difheu.

    vhttBuffer = phttDifheu:default-buffer-handle.
    if piNorol = ?
    then for each difheu no-lock
        where difheu.tprol = pcTprol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer difheu:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each difheu no-lock
        where difheu.tprol = pcTprol
          and difheu.norol = piNorol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer difheu:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDifheu no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateDifheu private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhMspai    as handle  no-undo.
    define buffer difheu for difheu.

    create query vhttquery.
    vhttBuffer = ghttDifheu:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttDifheu:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTprol, output vhNorol, output vhMspai).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first difheu exclusive-lock
                where rowid(difheu) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer difheu:handle, 'tprol/norol/mspai: ', substitute('&1/&2/&3', vhTprol:buffer-value(), vhNorol:buffer-value(), vhMspai:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer difheu:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createDifheu private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer difheu for difheu.

    create query vhttquery.
    vhttBuffer = ghttDifheu:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttDifheu:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create difheu.
            if not outils:copyValidField(buffer difheu:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteDifheu private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhMspai    as handle  no-undo.
    define buffer difheu for difheu.

    create query vhttquery.
    vhttBuffer = ghttDifheu:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttDifheu:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTprol, output vhNorol, output vhMspai).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first difheu exclusive-lock
                where rowid(Difheu) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer difheu:handle, 'tprol/norol/mspai: ', substitute('&1/&2/&3', vhTprol:buffer-value(), vhNorol:buffer-value(), vhMspai:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete difheu no-error.
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

