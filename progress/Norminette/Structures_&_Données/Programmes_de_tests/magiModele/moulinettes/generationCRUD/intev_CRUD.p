/*------------------------------------------------------------------------
File        : intev_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table intev
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/intev.i}
{application/include/error.i}
define variable ghttintev as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpidt as handle, output phNoidt as handle, output phTpeve as handle, output phNoeve as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpidt/noidt/tpeve/noeve, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpidt' then phTpidt = phBuffer:buffer-field(vi).
            when 'noidt' then phNoidt = phBuffer:buffer-field(vi).
            when 'tpeve' then phTpeve = phBuffer:buffer-field(vi).
            when 'noeve' then phNoeve = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIntev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIntev.
    run updateIntev.
    run createIntev.
end procedure.

procedure setIntev:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIntev.
    ghttIntev = phttIntev.
    run crudIntev.
    delete object phttIntev.
end procedure.

procedure readIntev:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table intev 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpidt as character  no-undo.
    define input parameter piNoidt as int64      no-undo.
    define input parameter pcTpeve as character  no-undo.
    define input parameter piNoeve as int64      no-undo.
    define input parameter table-handle phttIntev.
    define variable vhttBuffer as handle no-undo.
    define buffer intev for intev.

    vhttBuffer = phttIntev:default-buffer-handle.
    for first intev no-lock
        where intev.tpidt = pcTpidt
          and intev.noidt = piNoidt
          and intev.tpeve = pcTpeve
          and intev.noeve = piNoeve:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer intev:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIntev no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIntev:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table intev 
    Notes  : service externe. Critère pcTpeve = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpidt as character  no-undo.
    define input parameter piNoidt as int64      no-undo.
    define input parameter pcTpeve as character  no-undo.
    define input parameter table-handle phttIntev.
    define variable vhttBuffer as handle  no-undo.
    define buffer intev for intev.

    vhttBuffer = phttIntev:default-buffer-handle.
    if pcTpeve = ?
    then for each intev no-lock
        where intev.tpidt = pcTpidt
          and intev.noidt = piNoidt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer intev:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each intev no-lock
        where intev.tpidt = pcTpidt
          and intev.noidt = piNoidt
          and intev.tpeve = pcTpeve:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer intev:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIntev no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIntev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define variable vhTpeve    as handle  no-undo.
    define variable vhNoeve    as handle  no-undo.
    define buffer intev for intev.

    create query vhttquery.
    vhttBuffer = ghttIntev:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIntev:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpidt, output vhNoidt, output vhTpeve, output vhNoeve).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first intev exclusive-lock
                where rowid(intev) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer intev:handle, 'tpidt/noidt/tpeve/noeve: ', substitute('&1/&2/&3/&4', vhTpidt:buffer-value(), vhNoidt:buffer-value(), vhTpeve:buffer-value(), vhNoeve:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer intev:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIntev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer intev for intev.

    create query vhttquery.
    vhttBuffer = ghttIntev:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIntev:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create intev.
            if not outils:copyValidField(buffer intev:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIntev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define variable vhTpeve    as handle  no-undo.
    define variable vhNoeve    as handle  no-undo.
    define buffer intev for intev.

    create query vhttquery.
    vhttBuffer = ghttIntev:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIntev:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpidt, output vhNoidt, output vhTpeve, output vhNoeve).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first intev exclusive-lock
                where rowid(Intev) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer intev:handle, 'tpidt/noidt/tpeve/noeve: ', substitute('&1/&2/&3/&4', vhTpidt:buffer-value(), vhNoidt:buffer-value(), vhTpeve:buffer-value(), vhNoeve:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete intev no-error.
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

