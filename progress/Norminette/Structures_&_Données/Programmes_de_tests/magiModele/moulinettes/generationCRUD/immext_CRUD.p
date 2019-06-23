/*------------------------------------------------------------------------
File        : immext_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table immext
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/immext.i}
{application/include/error.i}
define variable ghttimmext as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpidt as handle, output phNoidt as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpidt/noidt, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpidt' then phTpidt = phBuffer:buffer-field(vi).
            when 'noidt' then phNoidt = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudImmext private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteImmext.
    run updateImmext.
    run createImmext.
end procedure.

procedure setImmext:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttImmext.
    ghttImmext = phttImmext.
    run crudImmext.
    delete object phttImmext.
end procedure.

procedure readImmext:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table immext Immeubles externes (0712/0243 - GECINA)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpidt as character  no-undo.
    define input parameter piNoidt as int64      no-undo.
    define input parameter table-handle phttImmext.
    define variable vhttBuffer as handle no-undo.
    define buffer immext for immext.

    vhttBuffer = phttImmext:default-buffer-handle.
    for first immext no-lock
        where immext.tpidt = pcTpidt
          and immext.noidt = piNoidt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer immext:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttImmext no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getImmext:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table immext Immeubles externes (0712/0243 - GECINA)
    Notes  : service externe. Critère pcTpidt = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpidt as character  no-undo.
    define input parameter table-handle phttImmext.
    define variable vhttBuffer as handle  no-undo.
    define buffer immext for immext.

    vhttBuffer = phttImmext:default-buffer-handle.
    if pcTpidt = ?
    then for each immext no-lock
        where immext.tpidt = pcTpidt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer immext:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each immext no-lock
        where immext.tpidt = pcTpidt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer immext:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttImmext no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateImmext private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define buffer immext for immext.

    create query vhttquery.
    vhttBuffer = ghttImmext:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttImmext:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpidt, output vhNoidt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first immext exclusive-lock
                where rowid(immext) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer immext:handle, 'tpidt/noidt: ', substitute('&1/&2', vhTpidt:buffer-value(), vhNoidt:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer immext:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createImmext private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer immext for immext.

    create query vhttquery.
    vhttBuffer = ghttImmext:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttImmext:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create immext.
            if not outils:copyValidField(buffer immext:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteImmext private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define buffer immext for immext.

    create query vhttquery.
    vhttBuffer = ghttImmext:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttImmext:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpidt, output vhNoidt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first immext exclusive-lock
                where rowid(Immext) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer immext:handle, 'tpidt/noidt: ', substitute('&1/&2', vhTpidt:buffer-value(), vhNoidt:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete immext no-error.
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

