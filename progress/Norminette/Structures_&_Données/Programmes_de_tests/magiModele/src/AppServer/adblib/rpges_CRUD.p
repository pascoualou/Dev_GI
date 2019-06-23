/*------------------------------------------------------------------------
File        : rpges_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table rpges
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttrpges as handle no-undo.     // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNocon as handle, output phDtrep as handle, output phCdage as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nocon/dtrep/cdage, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'dtrep' then phDtrep = phBuffer:buffer-field(vi).
            when 'cdage' then phCdage = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudRpges private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteRpges.
    run updateRpges.
    run createRpges.
end procedure.

procedure setRpges:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRpges.
    ghttRpges = phttRpges.
    run crudRpges.
    delete object phttRpges.
end procedure.

procedure readRpges:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table rpges 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNocon as int64      no-undo.
    define input parameter pdaDtrep as date       no-undo.
    define input parameter pcCdage as character  no-undo.
    define input parameter table-handle phttRpges.
    define variable vhttBuffer as handle no-undo.
    define buffer rpges for rpges.

    vhttBuffer = phttRpges:default-buffer-handle.
    for first rpges no-lock
        where rpges.nocon = piNocon
          and rpges.dtrep = pdaDtrep
          and rpges.cdage = pcCdage:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer rpges:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRpges no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getRpges:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table rpges 
    Notes  : service externe. Critère pdaDtrep = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNocon as int64      no-undo.
    define input parameter pdaDtrep as date       no-undo.
    define input parameter table-handle phttRpges.
    define variable vhttBuffer as handle  no-undo.
    define buffer rpges for rpges.

    vhttBuffer = phttRpges:default-buffer-handle.
    if pdaDtrep = ?
    then for each rpges no-lock
        where rpges.nocon = piNocon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer rpges:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each rpges no-lock
        where rpges.nocon = piNocon
          and rpges.dtrep = pdaDtrep:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer rpges:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRpges no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateRpges private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhDtrep    as handle  no-undo.
    define variable vhCdage    as handle  no-undo.
    define buffer rpges for rpges.

    create query vhttquery.
    vhttBuffer = ghttRpges:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttRpges:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNocon, output vhDtrep, output vhCdage).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first rpges exclusive-lock
                where rowid(rpges) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer rpges:handle, 'nocon/dtrep/cdage: ', substitute('&1/&2/&3', vhNocon:buffer-value(), vhDtrep:buffer-value(), vhCdage:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer rpges:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createRpges private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer rpges for rpges.

    create query vhttquery.
    vhttBuffer = ghttRpges:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttRpges:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create rpges.
            if not outils:copyValidField(buffer rpges:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteRpges private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhDtrep    as handle  no-undo.
    define variable vhCdage    as handle  no-undo.
    define buffer rpges for rpges.

    create query vhttquery.
    vhttBuffer = ghttRpges:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttRpges:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNocon, output vhDtrep, output vhCdage).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first rpges exclusive-lock
                where rowid(Rpges) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer rpges:handle, 'nocon/dtrep/cdage: ', substitute('&1/&2/&3', vhNocon:buffer-value(), vhDtrep:buffer-value(), vhCdage:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete rpges no-error.
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

procedure deleteRpgesSurContrat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64 no-undo.

    define buffer rpges for rpges.

blocTrans:
    do transaction:
        for each rpges exclusive-lock 
            where rpges.nocon = piNumeroContrat:
            delete rpges no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status
end procedure.
