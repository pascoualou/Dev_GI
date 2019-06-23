/*------------------------------------------------------------------------
File        : DosRp_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table DosRp
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/DosRp.i}
{application/include/error.i}
define variable ghttDosRp as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phNodos as handle, output phNolot as handle, output phNocop as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur TpCon/NoCon/NoDos/NoLot/NoCop, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'TpCon' then phTpcon = phBuffer:buffer-field(vi).
            when 'NoCon' then phNocon = phBuffer:buffer-field(vi).
            when 'NoDos' then phNodos = phBuffer:buffer-field(vi).
            when 'NoLot' then phNolot = phBuffer:buffer-field(vi).
            when 'NoCop' then phNocop = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudDosrp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteDosrp.
    run updateDosrp.
    run createDosrp.
end procedure.

procedure setDosrp:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttDosrp.
    ghttDosrp = phttDosrp.
    run crudDosrp.
    delete object phttDosrp.
end procedure.

procedure readDosrp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table DosRp Chaine Travaux : Table des repartitions Achat / Vente
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as integer    no-undo.
    define input parameter piNodos as integer    no-undo.
    define input parameter piNolot as integer    no-undo.
    define input parameter piNocop as integer    no-undo.
    define input parameter table-handle phttDosrp.
    define variable vhttBuffer as handle no-undo.
    define buffer DosRp for DosRp.

    vhttBuffer = phttDosrp:default-buffer-handle.
    for first DosRp no-lock
        where DosRp.TpCon = pcTpcon
          and DosRp.NoCon = piNocon
          and DosRp.NoDos = piNodos
          and DosRp.NoLot = piNolot
          and DosRp.NoCop = piNocop:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DosRp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDosrp no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getDosrp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table DosRp Chaine Travaux : Table des repartitions Achat / Vente
    Notes  : service externe. Critère piNolot = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as integer    no-undo.
    define input parameter piNodos as integer    no-undo.
    define input parameter piNolot as integer    no-undo.
    define input parameter table-handle phttDosrp.
    define variable vhttBuffer as handle  no-undo.
    define buffer DosRp for DosRp.

    vhttBuffer = phttDosrp:default-buffer-handle.
    if piNolot = ?
    then for each DosRp no-lock
        where DosRp.TpCon = pcTpcon
          and DosRp.NoCon = piNocon
          and DosRp.NoDos = piNodos:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DosRp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each DosRp no-lock
        where DosRp.TpCon = pcTpcon
          and DosRp.NoCon = piNocon
          and DosRp.NoDos = piNodos
          and DosRp.NoLot = piNolot:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DosRp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDosrp no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateDosrp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNodos    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define variable vhNocop    as handle  no-undo.
    define buffer DosRp for DosRp.

    create query vhttquery.
    vhttBuffer = ghttDosrp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttDosrp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNodos, output vhNolot, output vhNocop).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first DosRp exclusive-lock
                where rowid(DosRp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer DosRp:handle, 'TpCon/NoCon/NoDos/NoLot/NoCop: ', substitute('&1/&2/&3/&4/&5', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNodos:buffer-value(), vhNolot:buffer-value(), vhNocop:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer DosRp:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createDosrp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer DosRp for DosRp.

    create query vhttquery.
    vhttBuffer = ghttDosrp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttDosrp:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create DosRp.
            if not outils:copyValidField(buffer DosRp:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteDosrp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNodos    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define variable vhNocop    as handle  no-undo.
    define buffer DosRp for DosRp.

    create query vhttquery.
    vhttBuffer = ghttDosrp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttDosrp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNodos, output vhNolot, output vhNocop).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first DosRp exclusive-lock
                where rowid(Dosrp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer DosRp:handle, 'TpCon/NoCon/NoDos/NoLot/NoCop: ', substitute('&1/&2/&3/&4/&5', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNodos:buffer-value(), vhNolot:buffer-value(), vhNocop:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete DosRp no-error.
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

