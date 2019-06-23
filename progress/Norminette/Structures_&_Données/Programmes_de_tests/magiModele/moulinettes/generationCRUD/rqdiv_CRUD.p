/*------------------------------------------------------------------------
File        : rqdiv_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table rqdiv
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/rqdiv.i}
{application/include/error.i}
define variable ghttrqdiv as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCduti as handle, output phNoreq as handle, output phTpdiv as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cduti/noreq/tpdiv, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cduti' then phCduti = phBuffer:buffer-field(vi).
            when 'noreq' then phNoreq = phBuffer:buffer-field(vi).
            when 'tpdiv' then phTpdiv = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudRqdiv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteRqdiv.
    run updateRqdiv.
    run createRqdiv.
end procedure.

procedure setRqdiv:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRqdiv.
    ghttRqdiv = phttRqdiv.
    run crudRqdiv.
    delete object phttRqdiv.
end procedure.

procedure readRqdiv:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table rqdiv 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCduti as character  no-undo.
    define input parameter piNoreq as integer    no-undo.
    define input parameter pcTpdiv as character  no-undo.
    define input parameter table-handle phttRqdiv.
    define variable vhttBuffer as handle no-undo.
    define buffer rqdiv for rqdiv.

    vhttBuffer = phttRqdiv:default-buffer-handle.
    for first rqdiv no-lock
        where rqdiv.cduti = pcCduti
          and rqdiv.noreq = piNoreq
          and rqdiv.tpdiv = pcTpdiv:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer rqdiv:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRqdiv no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getRqdiv:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table rqdiv 
    Notes  : service externe. Critère piNoreq = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCduti as character  no-undo.
    define input parameter piNoreq as integer    no-undo.
    define input parameter table-handle phttRqdiv.
    define variable vhttBuffer as handle  no-undo.
    define buffer rqdiv for rqdiv.

    vhttBuffer = phttRqdiv:default-buffer-handle.
    if piNoreq = ?
    then for each rqdiv no-lock
        where rqdiv.cduti = pcCduti:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer rqdiv:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each rqdiv no-lock
        where rqdiv.cduti = pcCduti
          and rqdiv.noreq = piNoreq:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer rqdiv:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRqdiv no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateRqdiv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCduti    as handle  no-undo.
    define variable vhNoreq    as handle  no-undo.
    define variable vhTpdiv    as handle  no-undo.
    define buffer rqdiv for rqdiv.

    create query vhttquery.
    vhttBuffer = ghttRqdiv:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttRqdiv:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCduti, output vhNoreq, output vhTpdiv).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first rqdiv exclusive-lock
                where rowid(rqdiv) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer rqdiv:handle, 'cduti/noreq/tpdiv: ', substitute('&1/&2/&3', vhCduti:buffer-value(), vhNoreq:buffer-value(), vhTpdiv:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer rqdiv:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createRqdiv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer rqdiv for rqdiv.

    create query vhttquery.
    vhttBuffer = ghttRqdiv:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttRqdiv:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create rqdiv.
            if not outils:copyValidField(buffer rqdiv:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteRqdiv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCduti    as handle  no-undo.
    define variable vhNoreq    as handle  no-undo.
    define variable vhTpdiv    as handle  no-undo.
    define buffer rqdiv for rqdiv.

    create query vhttquery.
    vhttBuffer = ghttRqdiv:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttRqdiv:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCduti, output vhNoreq, output vhTpdiv).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first rqdiv exclusive-lock
                where rowid(Rqdiv) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer rqdiv:handle, 'cduti/noreq/tpdiv: ', substitute('&1/&2/&3', vhCduti:buffer-value(), vhNoreq:buffer-value(), vhTpdiv:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete rqdiv no-error.
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

