/*------------------------------------------------------------------------
File        : JOUVR_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table JOUVR
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/JOUVR.i}
{application/include/error.i}
define variable ghttJOUVR as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phJosem as handle, output phTpovr as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur JOSEM/TPOVR, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'JOSEM' then phJosem = phBuffer:buffer-field(vi).
            when 'TPOVR' then phTpovr = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudJouvr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteJouvr.
    run updateJouvr.
    run createJouvr.
end procedure.

procedure setJouvr:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttJouvr.
    ghttJouvr = phttJouvr.
    run crudJouvr.
    delete object phttJouvr.
end procedure.

procedure readJouvr:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table JOUVR 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piJosem as integer    no-undo.
    define input parameter pcTpovr as character  no-undo.
    define input parameter table-handle phttJouvr.
    define variable vhttBuffer as handle no-undo.
    define buffer JOUVR for JOUVR.

    vhttBuffer = phttJouvr:default-buffer-handle.
    for first JOUVR no-lock
        where JOUVR.JOSEM = piJosem
          and JOUVR.TPOVR = pcTpovr:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer JOUVR:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttJouvr no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getJouvr:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table JOUVR 
    Notes  : service externe. Critère piJosem = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piJosem as integer    no-undo.
    define input parameter table-handle phttJouvr.
    define variable vhttBuffer as handle  no-undo.
    define buffer JOUVR for JOUVR.

    vhttBuffer = phttJouvr:default-buffer-handle.
    if piJosem = ?
    then for each JOUVR no-lock
        where JOUVR.JOSEM = piJosem:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer JOUVR:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each JOUVR no-lock
        where JOUVR.JOSEM = piJosem:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer JOUVR:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttJouvr no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateJouvr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhJosem    as handle  no-undo.
    define variable vhTpovr    as handle  no-undo.
    define buffer JOUVR for JOUVR.

    create query vhttquery.
    vhttBuffer = ghttJouvr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttJouvr:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhJosem, output vhTpovr).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first JOUVR exclusive-lock
                where rowid(JOUVR) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer JOUVR:handle, 'JOSEM/TPOVR: ', substitute('&1/&2', vhJosem:buffer-value(), vhTpovr:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer JOUVR:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createJouvr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer JOUVR for JOUVR.

    create query vhttquery.
    vhttBuffer = ghttJouvr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttJouvr:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create JOUVR.
            if not outils:copyValidField(buffer JOUVR:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteJouvr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhJosem    as handle  no-undo.
    define variable vhTpovr    as handle  no-undo.
    define buffer JOUVR for JOUVR.

    create query vhttquery.
    vhttBuffer = ghttJouvr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttJouvr:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhJosem, output vhTpovr).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first JOUVR exclusive-lock
                where rowid(Jouvr) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer JOUVR:handle, 'JOSEM/TPOVR: ', substitute('&1/&2', vhJosem:buffer-value(), vhTpovr:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete JOUVR no-error.
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

