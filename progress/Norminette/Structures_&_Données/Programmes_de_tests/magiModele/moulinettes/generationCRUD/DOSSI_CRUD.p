/*------------------------------------------------------------------------
File        : DOSSI_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table DOSSI
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/DOSSI.i}
{application/include/error.i}
define variable ghttDOSSI as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudDossi private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteDossi.
    run updateDossi.
    run createDossi.
end procedure.

procedure setDossi:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttDossi.
    ghttDossi = phttDossi.
    run crudDossi.
    delete object phttDossi.
end procedure.

procedure readDossi:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table DOSSI Dossier
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpidt as character  no-undo.
    define input parameter piNoidt as int64      no-undo.
    define input parameter table-handle phttDossi.
    define variable vhttBuffer as handle no-undo.
    define buffer DOSSI for DOSSI.

    vhttBuffer = phttDossi:default-buffer-handle.
    for first DOSSI no-lock
        where DOSSI.tpidt = pcTpidt
          and DOSSI.noidt = piNoidt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DOSSI:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDossi no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getDossi:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table DOSSI Dossier
    Notes  : service externe. Critère pcTpidt = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpidt as character  no-undo.
    define input parameter table-handle phttDossi.
    define variable vhttBuffer as handle  no-undo.
    define buffer DOSSI for DOSSI.

    vhttBuffer = phttDossi:default-buffer-handle.
    if pcTpidt = ?
    then for each DOSSI no-lock
        where DOSSI.tpidt = pcTpidt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DOSSI:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each DOSSI no-lock
        where DOSSI.tpidt = pcTpidt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DOSSI:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDossi no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateDossi private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define buffer DOSSI for DOSSI.

    create query vhttquery.
    vhttBuffer = ghttDossi:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttDossi:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpidt, output vhNoidt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first DOSSI exclusive-lock
                where rowid(DOSSI) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer DOSSI:handle, 'tpidt/noidt: ', substitute('&1/&2', vhTpidt:buffer-value(), vhNoidt:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer DOSSI:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createDossi private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer DOSSI for DOSSI.

    create query vhttquery.
    vhttBuffer = ghttDossi:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttDossi:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create DOSSI.
            if not outils:copyValidField(buffer DOSSI:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteDossi private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define buffer DOSSI for DOSSI.

    create query vhttquery.
    vhttBuffer = ghttDossi:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttDossi:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpidt, output vhNoidt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first DOSSI exclusive-lock
                where rowid(Dossi) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer DOSSI:handle, 'tpidt/noidt: ', substitute('&1/&2', vhTpidt:buffer-value(), vhNoidt:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete DOSSI no-error.
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

