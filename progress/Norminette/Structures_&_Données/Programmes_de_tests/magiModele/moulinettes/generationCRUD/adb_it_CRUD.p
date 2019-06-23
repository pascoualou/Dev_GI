/*------------------------------------------------------------------------
File        : adb_it_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table adb_it
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/adb_it.i}
{application/include/error.i}
define variable ghttadb_it as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdisp as handle, output phNoite as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cdisp/noite, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cdisp' then phCdisp = phBuffer:buffer-field(vi).
            when 'noite' then phNoite = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAdb_it private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAdb_it.
    run updateAdb_it.
    run createAdb_it.
end procedure.

procedure setAdb_it:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAdb_it.
    ghttAdb_it = phttAdb_it.
    run crudAdb_it.
    delete object phttAdb_it.
end procedure.

procedure readAdb_it:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table adb_it 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdisp as character  no-undo.
    define input parameter piNoite as integer    no-undo.
    define input parameter table-handle phttAdb_it.
    define variable vhttBuffer as handle no-undo.
    define buffer adb_it for adb_it.

    vhttBuffer = phttAdb_it:default-buffer-handle.
    for first adb_it no-lock
        where adb_it.cdisp = pcCdisp
          and adb_it.noite = piNoite:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer adb_it:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAdb_it no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAdb_it:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table adb_it 
    Notes  : service externe. Critère pcCdisp = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCdisp as character  no-undo.
    define input parameter table-handle phttAdb_it.
    define variable vhttBuffer as handle  no-undo.
    define buffer adb_it for adb_it.

    vhttBuffer = phttAdb_it:default-buffer-handle.
    if pcCdisp = ?
    then for each adb_it no-lock
        where adb_it.cdisp = pcCdisp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer adb_it:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each adb_it no-lock
        where adb_it.cdisp = pcCdisp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer adb_it:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAdb_it no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAdb_it private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdisp    as handle  no-undo.
    define variable vhNoite    as handle  no-undo.
    define buffer adb_it for adb_it.

    create query vhttquery.
    vhttBuffer = ghttAdb_it:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAdb_it:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdisp, output vhNoite).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first adb_it exclusive-lock
                where rowid(adb_it) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer adb_it:handle, 'cdisp/noite: ', substitute('&1/&2', vhCdisp:buffer-value(), vhNoite:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer adb_it:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAdb_it private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer adb_it for adb_it.

    create query vhttquery.
    vhttBuffer = ghttAdb_it:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAdb_it:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create adb_it.
            if not outils:copyValidField(buffer adb_it:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAdb_it private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdisp    as handle  no-undo.
    define variable vhNoite    as handle  no-undo.
    define buffer adb_it for adb_it.

    create query vhttquery.
    vhttBuffer = ghttAdb_it:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAdb_it:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdisp, output vhNoite).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first adb_it exclusive-lock
                where rowid(Adb_it) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer adb_it:handle, 'cdisp/noite: ', substitute('&1/&2', vhCdisp:buffer-value(), vhNoite:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete adb_it no-error.
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

