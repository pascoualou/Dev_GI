/*------------------------------------------------------------------------
File        : DESTI_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table DESTI
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/DESTI.i}
{application/include/error.i}
define variable ghttDESTI as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNodoc as handle, output phTprol as handle, output phNorol as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nodoc/tprol/norol, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nodoc' then phNodoc = phBuffer:buffer-field(vi).
            when 'tprol' then phTprol = phBuffer:buffer-field(vi).
            when 'norol' then phNorol = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudDesti private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteDesti.
    run updateDesti.
    run createDesti.
end procedure.

procedure setDesti:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttDesti.
    ghttDesti = phttDesti.
    run crudDesti.
    delete object phttDesti.
end procedure.

procedure readDesti:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table DESTI Destinataire
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNodoc as int64      no-undo.
    define input parameter pcTprol as character  no-undo.
    define input parameter piNorol as int64      no-undo.
    define input parameter table-handle phttDesti.
    define variable vhttBuffer as handle no-undo.
    define buffer DESTI for DESTI.

    vhttBuffer = phttDesti:default-buffer-handle.
    for first DESTI no-lock
        where DESTI.nodoc = piNodoc
          and DESTI.tprol = pcTprol
          and DESTI.norol = piNorol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DESTI:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDesti no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getDesti:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table DESTI Destinataire
    Notes  : service externe. Critère pcTprol = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNodoc as int64      no-undo.
    define input parameter pcTprol as character  no-undo.
    define input parameter table-handle phttDesti.
    define variable vhttBuffer as handle  no-undo.
    define buffer DESTI for DESTI.

    vhttBuffer = phttDesti:default-buffer-handle.
    if pcTprol = ?
    then for each DESTI no-lock
        where DESTI.nodoc = piNodoc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DESTI:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each DESTI no-lock
        where DESTI.nodoc = piNodoc
          and DESTI.tprol = pcTprol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DESTI:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDesti no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateDesti private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNodoc    as handle  no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define buffer DESTI for DESTI.

    create query vhttquery.
    vhttBuffer = ghttDesti:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttDesti:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNodoc, output vhTprol, output vhNorol).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first DESTI exclusive-lock
                where rowid(DESTI) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer DESTI:handle, 'nodoc/tprol/norol: ', substitute('&1/&2/&3', vhNodoc:buffer-value(), vhTprol:buffer-value(), vhNorol:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer DESTI:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createDesti private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer DESTI for DESTI.

    create query vhttquery.
    vhttBuffer = ghttDesti:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttDesti:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create DESTI.
            if not outils:copyValidField(buffer DESTI:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteDesti private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNodoc    as handle  no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define buffer DESTI for DESTI.

    create query vhttquery.
    vhttBuffer = ghttDesti:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttDesti:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNodoc, output vhTprol, output vhNorol).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first DESTI exclusive-lock
                where rowid(Desti) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer DESTI:handle, 'nodoc/tprol/norol: ', substitute('&1/&2/&3', vhNodoc:buffer-value(), vhTprol:buffer-value(), vhNorol:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete DESTI no-error.
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

