/*------------------------------------------------------------------------
File        : rqctt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table rqctt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/rqctt.i}
{application/include/error.i}
define variable ghttrqctt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCduti as handle, output phNoreq as handle, output phTpcon as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cduti/noreq/tpcon, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cduti' then phCduti = phBuffer:buffer-field(vi).
            when 'noreq' then phNoreq = phBuffer:buffer-field(vi).
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudRqctt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteRqctt.
    run updateRqctt.
    run createRqctt.
end procedure.

procedure setRqctt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRqctt.
    ghttRqctt = phttRqctt.
    run crudRqctt.
    delete object phttRqctt.
end procedure.

procedure readRqctt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table rqctt 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCduti as character  no-undo.
    define input parameter piNoreq as integer    no-undo.
    define input parameter pcTpcon as character  no-undo.
    define input parameter table-handle phttRqctt.
    define variable vhttBuffer as handle no-undo.
    define buffer rqctt for rqctt.

    vhttBuffer = phttRqctt:default-buffer-handle.
    for first rqctt no-lock
        where rqctt.cduti = pcCduti
          and rqctt.noreq = piNoreq
          and rqctt.tpcon = pcTpcon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer rqctt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRqctt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getRqctt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table rqctt 
    Notes  : service externe. Critère piNoreq = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCduti as character  no-undo.
    define input parameter piNoreq as integer    no-undo.
    define input parameter table-handle phttRqctt.
    define variable vhttBuffer as handle  no-undo.
    define buffer rqctt for rqctt.

    vhttBuffer = phttRqctt:default-buffer-handle.
    if piNoreq = ?
    then for each rqctt no-lock
        where rqctt.cduti = pcCduti:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer rqctt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each rqctt no-lock
        where rqctt.cduti = pcCduti
          and rqctt.noreq = piNoreq:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer rqctt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRqctt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateRqctt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCduti    as handle  no-undo.
    define variable vhNoreq    as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define buffer rqctt for rqctt.

    create query vhttquery.
    vhttBuffer = ghttRqctt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttRqctt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCduti, output vhNoreq, output vhTpcon).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first rqctt exclusive-lock
                where rowid(rqctt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer rqctt:handle, 'cduti/noreq/tpcon: ', substitute('&1/&2/&3', vhCduti:buffer-value(), vhNoreq:buffer-value(), vhTpcon:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer rqctt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createRqctt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer rqctt for rqctt.

    create query vhttquery.
    vhttBuffer = ghttRqctt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttRqctt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create rqctt.
            if not outils:copyValidField(buffer rqctt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteRqctt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCduti    as handle  no-undo.
    define variable vhNoreq    as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define buffer rqctt for rqctt.

    create query vhttquery.
    vhttBuffer = ghttRqctt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttRqctt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCduti, output vhNoreq, output vhTpcon).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first rqctt exclusive-lock
                where rowid(Rqctt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer rqctt:handle, 'cduti/noreq/tpcon: ', substitute('&1/&2/&3', vhCduti:buffer-value(), vhNoreq:buffer-value(), vhTpcon:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete rqctt no-error.
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

