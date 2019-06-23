/*------------------------------------------------------------------------
File        : SuiExport_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table SuiExport
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/SuiExport.i}
{application/include/error.i}
define variable ghttSuiExport as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpexp as handle, output phTpidt as handle, output phNoidt as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur TpExp/TpIdt/NoIdt, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'TpExp' then phTpexp = phBuffer:buffer-field(vi).
            when 'TpIdt' then phTpidt = phBuffer:buffer-field(vi).
            when 'NoIdt' then phNoidt = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSuiexport private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSuiexport.
    run updateSuiexport.
    run createSuiexport.
end procedure.

procedure setSuiexport:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSuiexport.
    ghttSuiexport = phttSuiexport.
    run crudSuiexport.
    delete object phttSuiexport.
end procedure.

procedure readSuiexport:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table SuiExport 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpexp as character  no-undo.
    define input parameter pcTpidt as character  no-undo.
    define input parameter pcNoidt as character  no-undo.
    define input parameter table-handle phttSuiexport.
    define variable vhttBuffer as handle no-undo.
    define buffer SuiExport for SuiExport.

    vhttBuffer = phttSuiexport:default-buffer-handle.
    for first SuiExport no-lock
        where SuiExport.TpExp = pcTpexp
          and SuiExport.TpIdt = pcTpidt
          and SuiExport.NoIdt = pcNoidt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer SuiExport:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSuiexport no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSuiexport:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table SuiExport 
    Notes  : service externe. Critère pcTpidt = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpexp as character  no-undo.
    define input parameter pcTpidt as character  no-undo.
    define input parameter table-handle phttSuiexport.
    define variable vhttBuffer as handle  no-undo.
    define buffer SuiExport for SuiExport.

    vhttBuffer = phttSuiexport:default-buffer-handle.
    if pcTpidt = ?
    then for each SuiExport no-lock
        where SuiExport.TpExp = pcTpexp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer SuiExport:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each SuiExport no-lock
        where SuiExport.TpExp = pcTpexp
          and SuiExport.TpIdt = pcTpidt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer SuiExport:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSuiexport no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSuiexport private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpexp    as handle  no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define buffer SuiExport for SuiExport.

    create query vhttquery.
    vhttBuffer = ghttSuiexport:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSuiexport:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpexp, output vhTpidt, output vhNoidt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first SuiExport exclusive-lock
                where rowid(SuiExport) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer SuiExport:handle, 'TpExp/TpIdt/NoIdt: ', substitute('&1/&2/&3', vhTpexp:buffer-value(), vhTpidt:buffer-value(), vhNoidt:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer SuiExport:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSuiexport private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer SuiExport for SuiExport.

    create query vhttquery.
    vhttBuffer = ghttSuiexport:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSuiexport:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create SuiExport.
            if not outils:copyValidField(buffer SuiExport:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSuiexport private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpexp    as handle  no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define buffer SuiExport for SuiExport.

    create query vhttquery.
    vhttBuffer = ghttSuiexport:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSuiexport:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpexp, output vhTpidt, output vhNoidt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first SuiExport exclusive-lock
                where rowid(Suiexport) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer SuiExport:handle, 'TpExp/TpIdt/NoIdt: ', substitute('&1/&2/&3', vhTpexp:buffer-value(), vhTpidt:buffer-value(), vhNoidt:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete SuiExport no-error.
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

