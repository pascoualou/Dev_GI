/*------------------------------------------------------------------------
File        : rqrol_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table rqrol
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/rqrol.i}
{application/include/error.i}
define variable ghttrqrol as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoref as handle, output phCduti as handle, output phNoses as handle, output phNoreq as handle, output phTprol as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noref/cduti/noses/Noreq/tprol, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noref' then phNoref = phBuffer:buffer-field(vi).
            when 'cduti' then phCduti = phBuffer:buffer-field(vi).
            when 'noses' then phNoses = phBuffer:buffer-field(vi).
            when 'Noreq' then phNoreq = phBuffer:buffer-field(vi).
            when 'tprol' then phTprol = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudRqrol private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteRqrol.
    run updateRqrol.
    run createRqrol.
end procedure.

procedure setRqrol:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRqrol.
    ghttRqrol = phttRqrol.
    run crudRqrol.
    delete object phttRqrol.
end procedure.

procedure readRqrol:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table rqrol 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoref as integer    no-undo.
    define input parameter pcCduti as character  no-undo.
    define input parameter piNoses as integer    no-undo.
    define input parameter piNoreq as integer    no-undo.
    define input parameter pcTprol as character  no-undo.
    define input parameter table-handle phttRqrol.
    define variable vhttBuffer as handle no-undo.
    define buffer rqrol for rqrol.

    vhttBuffer = phttRqrol:default-buffer-handle.
    for first rqrol no-lock
        where rqrol.noref = piNoref
          and rqrol.cduti = pcCduti
          and rqrol.noses = piNoses
          and rqrol.Noreq = piNoreq
          and rqrol.tprol = pcTprol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer rqrol:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRqrol no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getRqrol:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table rqrol 
    Notes  : service externe. Critère piNoreq = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoref as integer    no-undo.
    define input parameter pcCduti as character  no-undo.
    define input parameter piNoses as integer    no-undo.
    define input parameter piNoreq as integer    no-undo.
    define input parameter table-handle phttRqrol.
    define variable vhttBuffer as handle  no-undo.
    define buffer rqrol for rqrol.

    vhttBuffer = phttRqrol:default-buffer-handle.
    if piNoreq = ?
    then for each rqrol no-lock
        where rqrol.noref = piNoref
          and rqrol.cduti = pcCduti
          and rqrol.noses = piNoses:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer rqrol:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each rqrol no-lock
        where rqrol.noref = piNoref
          and rqrol.cduti = pcCduti
          and rqrol.noses = piNoses
          and rqrol.Noreq = piNoreq:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer rqrol:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRqrol no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateRqrol private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoref    as handle  no-undo.
    define variable vhCduti    as handle  no-undo.
    define variable vhNoses    as handle  no-undo.
    define variable vhNoreq    as handle  no-undo.
    define variable vhTprol    as handle  no-undo.
    define buffer rqrol for rqrol.

    create query vhttquery.
    vhttBuffer = ghttRqrol:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttRqrol:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoref, output vhCduti, output vhNoses, output vhNoreq, output vhTprol).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first rqrol exclusive-lock
                where rowid(rqrol) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer rqrol:handle, 'noref/cduti/noses/Noreq/tprol: ', substitute('&1/&2/&3/&4/&5', vhNoref:buffer-value(), vhCduti:buffer-value(), vhNoses:buffer-value(), vhNoreq:buffer-value(), vhTprol:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer rqrol:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createRqrol private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer rqrol for rqrol.

    create query vhttquery.
    vhttBuffer = ghttRqrol:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttRqrol:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create rqrol.
            if not outils:copyValidField(buffer rqrol:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteRqrol private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoref    as handle  no-undo.
    define variable vhCduti    as handle  no-undo.
    define variable vhNoses    as handle  no-undo.
    define variable vhNoreq    as handle  no-undo.
    define variable vhTprol    as handle  no-undo.
    define buffer rqrol for rqrol.

    create query vhttquery.
    vhttBuffer = ghttRqrol:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttRqrol:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoref, output vhCduti, output vhNoses, output vhNoreq, output vhTprol).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first rqrol exclusive-lock
                where rowid(Rqrol) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer rqrol:handle, 'noref/cduti/noses/Noreq/tprol: ', substitute('&1/&2/&3/&4/&5', vhNoref:buffer-value(), vhCduti:buffer-value(), vhNoses:buffer-value(), vhNoreq:buffer-value(), vhTprol:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete rqrol no-error.
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

