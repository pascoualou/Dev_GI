/*------------------------------------------------------------------------
File        : DosAp_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table DosAp
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/DosAp.i}
{application/include/error.i}
define variable ghttDosAp as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phNodos as handle, output phNoapp as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur TpCon/NoCon/NoDos/NoApp, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'TpCon' then phTpcon = phBuffer:buffer-field(vi).
            when 'NoCon' then phNocon = phBuffer:buffer-field(vi).
            when 'NoDos' then phNodos = phBuffer:buffer-field(vi).
            when 'NoApp' then phNoapp = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudDosap private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteDosap.
    run updateDosap.
    run createDosap.
end procedure.

procedure setDosap:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttDosap.
    ghttDosap = phttDosap.
    run crudDosap.
    delete object phttDosap.
end procedure.

procedure readDosap:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table DosAp Chaine Travaux : Table des n° d'appel de fond
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as integer    no-undo.
    define input parameter piNodos as integer    no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter table-handle phttDosap.
    define variable vhttBuffer as handle no-undo.
    define buffer DosAp for DosAp.

    vhttBuffer = phttDosap:default-buffer-handle.
    for first DosAp no-lock
        where DosAp.TpCon = pcTpcon
          and DosAp.NoCon = piNocon
          and DosAp.NoDos = piNodos
          and DosAp.NoApp = piNoapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DosAp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDosap no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getDosap:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table DosAp Chaine Travaux : Table des n° d'appel de fond
    Notes  : service externe. Critère piNodos = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as integer    no-undo.
    define input parameter piNodos as integer    no-undo.
    define input parameter table-handle phttDosap.
    define variable vhttBuffer as handle  no-undo.
    define buffer DosAp for DosAp.

    vhttBuffer = phttDosap:default-buffer-handle.
    if piNodos = ?
    then for each DosAp no-lock
        where DosAp.TpCon = pcTpcon
          and DosAp.NoCon = piNocon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DosAp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each DosAp no-lock
        where DosAp.TpCon = pcTpcon
          and DosAp.NoCon = piNocon
          and DosAp.NoDos = piNodos:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DosAp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDosap no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateDosap private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNodos    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define buffer DosAp for DosAp.

    create query vhttquery.
    vhttBuffer = ghttDosap:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttDosap:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNodos, output vhNoapp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first DosAp exclusive-lock
                where rowid(DosAp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer DosAp:handle, 'TpCon/NoCon/NoDos/NoApp: ', substitute('&1/&2/&3/&4', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNodos:buffer-value(), vhNoapp:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer DosAp:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createDosap private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer DosAp for DosAp.

    create query vhttquery.
    vhttBuffer = ghttDosap:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttDosap:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create DosAp.
            if not outils:copyValidField(buffer DosAp:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteDosap private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNodos    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define buffer DosAp for DosAp.

    create query vhttquery.
    vhttBuffer = ghttDosap:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttDosap:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNodos, output vhNoapp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first DosAp exclusive-lock
                where rowid(Dosap) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer DosAp:handle, 'TpCon/NoCon/NoDos/NoApp: ', substitute('&1/&2/&3/&4', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNodos:buffer-value(), vhNoapp:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete DosAp no-error.
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

