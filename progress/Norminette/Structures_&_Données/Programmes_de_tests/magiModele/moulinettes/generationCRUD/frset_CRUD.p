/*------------------------------------------------------------------------
File        : frset_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table frset
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/frset.i}
{application/include/error.i}
define variable ghttfrset as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpbud as handle, output phNobud as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpbud/nobud, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpbud' then phTpbud = phBuffer:buffer-field(vi).
            when 'nobud' then phNobud = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudFrset private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteFrset.
    run updateFrset.
    run createFrset.
end procedure.

procedure setFrset:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttFrset.
    ghttFrset = phttFrset.
    run crudFrset.
    delete object phttFrset.
end procedure.

procedure readFrset:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table frset 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpbud as character  no-undo.
    define input parameter piNobud as int64      no-undo.
    define input parameter table-handle phttFrset.
    define variable vhttBuffer as handle no-undo.
    define buffer frset for frset.

    vhttBuffer = phttFrset:default-buffer-handle.
    for first frset no-lock
        where frset.tpbud = pcTpbud
          and frset.nobud = piNobud:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer frset:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttFrset no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getFrset:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table frset 
    Notes  : service externe. Critère pcTpbud = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpbud as character  no-undo.
    define input parameter table-handle phttFrset.
    define variable vhttBuffer as handle  no-undo.
    define buffer frset for frset.

    vhttBuffer = phttFrset:default-buffer-handle.
    if pcTpbud = ?
    then for each frset no-lock
        where frset.tpbud = pcTpbud:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer frset:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each frset no-lock
        where frset.tpbud = pcTpbud:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer frset:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttFrset no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateFrset private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpbud    as handle  no-undo.
    define variable vhNobud    as handle  no-undo.
    define buffer frset for frset.

    create query vhttquery.
    vhttBuffer = ghttFrset:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttFrset:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpbud, output vhNobud).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first frset exclusive-lock
                where rowid(frset) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer frset:handle, 'tpbud/nobud: ', substitute('&1/&2', vhTpbud:buffer-value(), vhNobud:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer frset:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createFrset private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer frset for frset.

    create query vhttquery.
    vhttBuffer = ghttFrset:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttFrset:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create frset.
            if not outils:copyValidField(buffer frset:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteFrset private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpbud    as handle  no-undo.
    define variable vhNobud    as handle  no-undo.
    define buffer frset for frset.

    create query vhttquery.
    vhttBuffer = ghttFrset:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttFrset:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpbud, output vhNobud).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first frset exclusive-lock
                where rowid(Frset) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer frset:handle, 'tpbud/nobud: ', substitute('&1/&2', vhTpbud:buffer-value(), vhNobud:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete frset no-error.
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

