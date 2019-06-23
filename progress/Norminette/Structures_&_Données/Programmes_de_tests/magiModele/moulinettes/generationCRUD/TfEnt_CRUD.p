/*------------------------------------------------------------------------
File        : TfEnt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table TfEnt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/TfEnt.i}
{application/include/error.i}
define variable ghttTfEnt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoimm as handle, output phDtrev as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur NoImm/DtRev, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'NoImm' then phNoimm = phBuffer:buffer-field(vi).
            when 'DtRev' then phDtrev = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTfent private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTfent.
    run updateTfent.
    run createTfent.
end procedure.

procedure setTfent:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTfent.
    ghttTfent = phttTfent.
    run crudTfent.
    delete object phttTfent.
end procedure.

procedure readTfent:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table TfEnt 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoimm as integer    no-undo.
    define input parameter pdaDtrev as date       no-undo.
    define input parameter table-handle phttTfent.
    define variable vhttBuffer as handle no-undo.
    define buffer TfEnt for TfEnt.

    vhttBuffer = phttTfent:default-buffer-handle.
    for first TfEnt no-lock
        where TfEnt.NoImm = piNoimm
          and TfEnt.DtRev = pdaDtrev:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer TfEnt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTfent no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTfent:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table TfEnt 
    Notes  : service externe. Critère piNoimm = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoimm as integer    no-undo.
    define input parameter table-handle phttTfent.
    define variable vhttBuffer as handle  no-undo.
    define buffer TfEnt for TfEnt.

    vhttBuffer = phttTfent:default-buffer-handle.
    if piNoimm = ?
    then for each TfEnt no-lock
        where TfEnt.NoImm = piNoimm:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer TfEnt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each TfEnt no-lock
        where TfEnt.NoImm = piNoimm:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer TfEnt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTfent no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTfent private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhDtrev    as handle  no-undo.
    define buffer TfEnt for TfEnt.

    create query vhttquery.
    vhttBuffer = ghttTfent:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTfent:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoimm, output vhDtrev).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first TfEnt exclusive-lock
                where rowid(TfEnt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer TfEnt:handle, 'NoImm/DtRev: ', substitute('&1/&2', vhNoimm:buffer-value(), vhDtrev:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer TfEnt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTfent private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer TfEnt for TfEnt.

    create query vhttquery.
    vhttBuffer = ghttTfent:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTfent:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create TfEnt.
            if not outils:copyValidField(buffer TfEnt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTfent private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhDtrev    as handle  no-undo.
    define buffer TfEnt for TfEnt.

    create query vhttquery.
    vhttBuffer = ghttTfent:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTfent:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoimm, output vhDtrev).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first TfEnt exclusive-lock
                where rowid(Tfent) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer TfEnt:handle, 'NoImm/DtRev: ', substitute('&1/&2', vhNoimm:buffer-value(), vhDtrev:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete TfEnt no-error.
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

