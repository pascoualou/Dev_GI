/*------------------------------------------------------------------------
File        : TrDos_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table TrDos
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/TrDos.i}
{application/include/error.i}
define variable ghttTrDos as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phNodos as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur TpCon/NoCon/NoDos, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'TpCon' then phTpcon = phBuffer:buffer-field(vi).
            when 'NoCon' then phNocon = phBuffer:buffer-field(vi).
            when 'NoDos' then phNodos = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTrdos private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTrdos.
    run updateTrdos.
    run createTrdos.
end procedure.

procedure setTrdos:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTrdos.
    ghttTrdos = phttTrdos.
    run crudTrdos.
    delete object phttTrdos.
end procedure.

procedure readTrdos:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table TrDos Chaine Travaux : Table des Dossiers Travaux
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as integer    no-undo.
    define input parameter piNodos as integer    no-undo.
    define input parameter table-handle phttTrdos.
    define variable vhttBuffer as handle no-undo.
    define buffer TrDos for TrDos.

    vhttBuffer = phttTrdos:default-buffer-handle.
    for first TrDos no-lock
        where TrDos.TpCon = pcTpcon
          and TrDos.NoCon = piNocon
          and TrDos.NoDos = piNodos:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer TrDos:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTrdos no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTrdos:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table TrDos Chaine Travaux : Table des Dossiers Travaux
    Notes  : service externe. Critère piNocon = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as integer    no-undo.
    define input parameter table-handle phttTrdos.
    define variable vhttBuffer as handle  no-undo.
    define buffer TrDos for TrDos.

    vhttBuffer = phttTrdos:default-buffer-handle.
    if piNocon = ?
    then for each TrDos no-lock
        where TrDos.TpCon = pcTpcon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer TrDos:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each TrDos no-lock
        where TrDos.TpCon = pcTpcon
          and TrDos.NoCon = piNocon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer TrDos:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTrdos no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTrdos private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNodos    as handle  no-undo.
    define buffer TrDos for TrDos.

    create query vhttquery.
    vhttBuffer = ghttTrdos:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTrdos:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNodos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first TrDos exclusive-lock
                where rowid(TrDos) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer TrDos:handle, 'TpCon/NoCon/NoDos: ', substitute('&1/&2/&3', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNodos:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer TrDos:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTrdos private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer TrDos for TrDos.

    create query vhttquery.
    vhttBuffer = ghttTrdos:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTrdos:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create TrDos.
            if not outils:copyValidField(buffer TrDos:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTrdos private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNodos    as handle  no-undo.
    define buffer TrDos for TrDos.

    create query vhttquery.
    vhttBuffer = ghttTrdos:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTrdos:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNodos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first TrDos exclusive-lock
                where rowid(Trdos) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer TrDos:handle, 'TpCon/NoCon/NoDos: ', substitute('&1/&2/&3', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNodos:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete TrDos no-error.
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

