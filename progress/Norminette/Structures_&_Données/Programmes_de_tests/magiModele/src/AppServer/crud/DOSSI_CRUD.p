/*------------------------------------------------------------------------
File        : dossi_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table dossi
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/06/05 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
{application/include/error.i}
define variable ghttDossi as handle no-undo.      // le handle de la temp table à mettre à jour

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
    Purpose: Lecture d'un enregistrement de la table dossi Dossier
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpidt as character  no-undo.
    define input parameter piNoidt as int64      no-undo.
    define input parameter table-handle phttDossi.
    define variable vhttBuffer as handle no-undo.
    define buffer dossi for dossi.

    vhttBuffer = phttDossi:default-buffer-handle.
    for first dossi no-lock
        where dossi.tpidt = pcTpidt
          and dossi.noidt = piNoidt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer dossi:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDossi no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getdossi:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table dossi Dossier
    Notes  : service externe. Critère pcTpidt = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpidt as character  no-undo.
    define input parameter table-handle phttDossi.
    define variable vhttBuffer as handle  no-undo.
    define buffer dossi for dossi.

    vhttBuffer = phttDossi:default-buffer-handle.
    if pcTpidt = ?
    then for each dossi no-lock
        where dossi.tpidt = pcTpidt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer dossi:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each dossi no-lock
        where dossi.tpidt = pcTpidt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer dossi:handle, vhttBuffer).  // copy table physique vers temp-table
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
    define buffer dossi for dossi.

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

            find first dossi exclusive-lock
                where rowid(dossi) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer dossi:handle, 'tpidt/noidt: ', substitute('&1/&2', vhTpidt:buffer-value(), vhNoidt:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer dossi:handle, vhttBuffer, "U", mtoken:cUser)
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
    define buffer dossi for dossi.

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

            create dossi.
            if not outils:copyValidField(buffer dossi:handle, vhttBuffer, "C", mtoken:cUser)
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
    define buffer dossi for dossi.

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

            find first dossi exclusive-lock
                where rowid(dossi) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer dossi:handle, 'tpidt/noidt: ', substitute('&1/&2', vhTpidt:buffer-value(), vhNoidt:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete dossi no-error.
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

procedure deleteDossiSurNoidt:
    /*------------------------------------------------------------------------------
    Purpose: suppression de l'enregistrement correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeIdentifiant   as character no-undo.
    define input parameter piNumeroIdentifiant as int64     no-undo.
    
    define buffer dossi for dossi.

message "deleteDossiSurNoidt "  pcTypeIdentifiant "// " piNumeroIdentifiant.

blocTrans:
    for first dossi exclusive-lock
        where dossi.tpidt = pcTypeIdentifiant
          and dossi.noidt = piNumeroIdentifiant:
        delete dossi no-error.
        if error-status:error then do:
            mError:createError({&error}, error-status:get-message(1)).
            undo blocTrans, leave blocTrans.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
