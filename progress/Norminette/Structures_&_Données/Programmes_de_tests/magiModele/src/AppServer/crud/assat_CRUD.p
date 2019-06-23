/*------------------------------------------------------------------------
File        : assat_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table assat
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
              issu de adb/lib/l_assat.p 
derniere revue: 2018/04/27 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttassat as handle no-undo.     // le handle de la temp table à mettre à jour

function getNextAssat returns integer(pcTypeContrat as character, piNumeroContrat as int64, pcTypeTache as character):
    /*------------------------------------------------------------------------------
    Purpose: fonction qui permet renvoie le prochain N° d' Attestation assurance Libre
    Notes  : service externe et interne 
    ------------------------------------------------------------------------------*/
    define buffer assat for assat.
    for last assat no-lock
        where assat.tpcon = pcTypeContrat
          and assat.nocon = piNumeroContrat
          and assat.tptac = pcTypeTache:
        return assat.noatt + 1.
    end.
    return 1.
end function.

function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phTptac as handle, output phNoatt as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcon/nocon/tptac/noatt, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'tptac' then phTptac = phBuffer:buffer-field(vi).
            when 'noatt' then phNoatt = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAssat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAssat.
    run updateAssat.
    run createAssat.
end procedure.

procedure setAssat:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAssat.
    ghttAssat = phttAssat.
    run crudAssat.
    delete object phttAssat.
end procedure.

procedure readAssat:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table assat 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character no-undo.
    define input parameter piNocon as integer   no-undo.
    define input parameter pcTptac as character no-undo.
    define input parameter piNoatt as integer   no-undo.
    define input parameter table-handle phttAssat.

    define variable vhttBuffer as handle no-undo.
    define buffer assat for assat.

    vhttBuffer = phttAssat:default-buffer-handle.
    for first assat no-lock
        where assat.tpcon = pcTpcon
          and assat.nocon = piNocon
          and assat.tptac = pcTptac
          and assat.noatt = piNoatt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer assat:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAssat no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAssat:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table assat 
    Notes  : service externe. Critère pcTptac = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character no-undo.
    define input parameter piNocon as integer   no-undo.
    define input parameter pcTptac as character no-undo.
    define input parameter table-handle phttAssat.

    define variable vhttBuffer as handle  no-undo.
    define buffer assat for assat.

    vhttBuffer = phttAssat:default-buffer-handle.
    if pcTptac = ?
    then for each assat no-lock
        where assat.tpcon = pcTpcon
          and assat.nocon = piNocon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer assat:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each assat no-lock
        where assat.tpcon = pcTpcon
          and assat.nocon = piNocon
          and assat.tptac = pcTptac:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer assat:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAssat no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAssat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhTptac    as handle  no-undo.
    define variable vhNoatt    as handle  no-undo.
    define buffer assat for assat.

    create query vhttquery.
    vhttBuffer = ghttAssat:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAssat:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhTptac, output vhNoatt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first assat exclusive-lock
                where rowid(assat) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer assat:handle, 'tpcon/nocon/tptac/noatt: ', substitute('&1/&2/&3/&4', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhTptac:buffer-value(), vhNoatt:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer assat:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAssat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhTptac    as handle  no-undo.
    define variable vhNoatt    as handle  no-undo.
    define buffer assat for assat.

    create query vhttquery.
    vhttBuffer = ghttAssat:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAssat:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhTptac, output vhNoatt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            if vhNoatt:buffer-value() = ?
            then vhNoatt:buffer-value() = getNextAssat(vhTpcon:buffer-value(), vhNocon:buffer-value(), vhTptac:buffer-value()).
            create assat.
            if not outils:copyValidField(buffer assat:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAssat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhTptac    as handle  no-undo.
    define variable vhNoatt    as handle  no-undo.
    define buffer assat for assat.

    create query vhttquery.
    vhttBuffer = ghttAssat:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAssat:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhTptac, output vhNoatt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first assat exclusive-lock
                where rowid(Assat) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer assat:handle, 'tpcon/nocon/tptac/noatt: ', substitute('&1/&2/&3/&4', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhTptac:buffer-value(), vhNoatt:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete assat no-error.
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

procedure deleteAssatSurContrat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.

    define buffer assat for assat.

blocTrans:
    do transaction:
        for each assat exclusive-lock 
            where assat.tpcon = pcTypeContrat 
              and assat.nocon = piNumeroContrat:
            delete assat no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status
end procedure.
