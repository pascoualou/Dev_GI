/*------------------------------------------------------------------------
File        : SSDOS_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table SSDOS
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/SSDOS.i}
{application/include/error.i}
define variable ghttSSDOS as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpidt as handle, output phNoidt as handle, output phNossd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpidt/noidt/nossd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpidt' then phTpidt = phBuffer:buffer-field(vi).
            when 'noidt' then phNoidt = phBuffer:buffer-field(vi).
            when 'nossd' then phNossd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSsdos private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSsdos.
    run updateSsdos.
    run createSsdos.
end procedure.

procedure setSsdos:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSsdos.
    ghttSsdos = phttSsdos.
    run crudSsdos.
    delete object phttSsdos.
end procedure.

procedure readSsdos:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table SSDOS Sous-dossier
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpidt as character  no-undo.
    define input parameter piNoidt as integer    no-undo.
    define input parameter piNossd as integer    no-undo.
    define input parameter table-handle phttSsdos.
    define variable vhttBuffer as handle no-undo.
    define buffer SSDOS for SSDOS.

    vhttBuffer = phttSsdos:default-buffer-handle.
    for first SSDOS no-lock
        where SSDOS.tpidt = pcTpidt
          and SSDOS.noidt = piNoidt
          and SSDOS.nossd = piNossd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer SSDOS:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSsdos no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSsdos:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table SSDOS Sous-dossier
    Notes  : service externe. Critère piNoidt = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpidt as character  no-undo.
    define input parameter piNoidt as integer    no-undo.
    define input parameter table-handle phttSsdos.
    define variable vhttBuffer as handle  no-undo.
    define buffer SSDOS for SSDOS.

    vhttBuffer = phttSsdos:default-buffer-handle.
    if piNoidt = ?
    then for each SSDOS no-lock
        where SSDOS.tpidt = pcTpidt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer SSDOS:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each SSDOS no-lock
        where SSDOS.tpidt = pcTpidt
          and SSDOS.noidt = piNoidt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer SSDOS:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSsdos no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSsdos private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define variable vhNossd    as handle  no-undo.
    define buffer SSDOS for SSDOS.

    create query vhttquery.
    vhttBuffer = ghttSsdos:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSsdos:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpidt, output vhNoidt, output vhNossd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first SSDOS exclusive-lock
                where rowid(SSDOS) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer SSDOS:handle, 'tpidt/noidt/nossd: ', substitute('&1/&2/&3', vhTpidt:buffer-value(), vhNoidt:buffer-value(), vhNossd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer SSDOS:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSsdos private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer SSDOS for SSDOS.

    create query vhttquery.
    vhttBuffer = ghttSsdos:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSsdos:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create SSDOS.
            if not outils:copyValidField(buffer SSDOS:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSsdos private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define variable vhNossd    as handle  no-undo.
    define buffer SSDOS for SSDOS.

    create query vhttquery.
    vhttBuffer = ghttSsdos:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSsdos:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpidt, output vhNoidt, output vhNossd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first SSDOS exclusive-lock
                where rowid(Ssdos) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer SSDOS:handle, 'tpidt/noidt/nossd: ', substitute('&1/&2/&3', vhTpidt:buffer-value(), vhNoidt:buffer-value(), vhNossd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete SSDOS no-error.
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

