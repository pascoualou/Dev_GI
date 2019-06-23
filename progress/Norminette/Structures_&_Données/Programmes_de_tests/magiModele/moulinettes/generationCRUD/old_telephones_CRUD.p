/*------------------------------------------------------------------------
File        : old_telephones_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table old_telephones
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/old_telephones.i}
{application/include/error.i}
define variable ghttold_telephones as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpidt as handle, output phNoidt as handle, output phNopos as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpidt/noidt/nopos, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpidt' then phTpidt = phBuffer:buffer-field(vi).
            when 'noidt' then phNoidt = phBuffer:buffer-field(vi).
            when 'nopos' then phNopos = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudOld_telephones private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteOld_telephones.
    run updateOld_telephones.
    run createOld_telephones.
end procedure.

procedure setOld_telephones:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttOld_telephones.
    ghttOld_telephones = phttOld_telephones.
    run crudOld_telephones.
    delete object phttOld_telephones.
end procedure.

procedure readOld_telephones:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table old_telephones 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpidt as character  no-undo.
    define input parameter piNoidt as integer    no-undo.
    define input parameter piNopos as integer    no-undo.
    define input parameter table-handle phttOld_telephones.
    define variable vhttBuffer as handle no-undo.
    define buffer old_telephones for old_telephones.

    vhttBuffer = phttOld_telephones:default-buffer-handle.
    for first old_telephones no-lock
        where old_telephones.tpidt = pcTpidt
          and old_telephones.noidt = piNoidt
          and old_telephones.nopos = piNopos:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer old_telephones:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttOld_telephones no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getOld_telephones:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table old_telephones 
    Notes  : service externe. Critère piNoidt = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpidt as character  no-undo.
    define input parameter piNoidt as integer    no-undo.
    define input parameter table-handle phttOld_telephones.
    define variable vhttBuffer as handle  no-undo.
    define buffer old_telephones for old_telephones.

    vhttBuffer = phttOld_telephones:default-buffer-handle.
    if piNoidt = ?
    then for each old_telephones no-lock
        where old_telephones.tpidt = pcTpidt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer old_telephones:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each old_telephones no-lock
        where old_telephones.tpidt = pcTpidt
          and old_telephones.noidt = piNoidt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer old_telephones:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttOld_telephones no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateOld_telephones private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define variable vhNopos    as handle  no-undo.
    define buffer old_telephones for old_telephones.

    create query vhttquery.
    vhttBuffer = ghttOld_telephones:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttOld_telephones:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpidt, output vhNoidt, output vhNopos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first old_telephones exclusive-lock
                where rowid(old_telephones) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer old_telephones:handle, 'tpidt/noidt/nopos: ', substitute('&1/&2/&3', vhTpidt:buffer-value(), vhNoidt:buffer-value(), vhNopos:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer old_telephones:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createOld_telephones private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer old_telephones for old_telephones.

    create query vhttquery.
    vhttBuffer = ghttOld_telephones:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttOld_telephones:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create old_telephones.
            if not outils:copyValidField(buffer old_telephones:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteOld_telephones private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define variable vhNopos    as handle  no-undo.
    define buffer old_telephones for old_telephones.

    create query vhttquery.
    vhttBuffer = ghttOld_telephones:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttOld_telephones:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpidt, output vhNoidt, output vhNopos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first old_telephones exclusive-lock
                where rowid(Old_telephones) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer old_telephones:handle, 'tpidt/noidt/nopos: ', substitute('&1/&2/&3', vhTpidt:buffer-value(), vhNoidt:buffer-value(), vhNopos:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete old_telephones no-error.
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

