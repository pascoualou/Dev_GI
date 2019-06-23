/*------------------------------------------------------------------------
File        : etxdt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table etxdt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/etxdt.i}
{application/include/error.i}
define variable ghttetxdt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNotrx as handle, output phTpapp as handle, output phNoapp as handle, output phNolot as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur notrx/tpapp/noapp/nolot, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'notrx' then phNotrx = phBuffer:buffer-field(vi).
            when 'tpapp' then phTpapp = phBuffer:buffer-field(vi).
            when 'noapp' then phNoapp = phBuffer:buffer-field(vi).
            when 'nolot' then phNolot = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudEtxdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteEtxdt.
    run updateEtxdt.
    run createEtxdt.
end procedure.

procedure setEtxdt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEtxdt.
    ghttEtxdt = phttEtxdt.
    run crudEtxdt.
    delete object phttEtxdt.
end procedure.

procedure readEtxdt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table etxdt 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNotrx as integer    no-undo.
    define input parameter pcTpapp as character  no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter piNolot as integer    no-undo.
    define input parameter table-handle phttEtxdt.
    define variable vhttBuffer as handle no-undo.
    define buffer etxdt for etxdt.

    vhttBuffer = phttEtxdt:default-buffer-handle.
    for first etxdt no-lock
        where etxdt.notrx = piNotrx
          and etxdt.tpapp = pcTpapp
          and etxdt.noapp = piNoapp
          and etxdt.nolot = piNolot:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer etxdt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEtxdt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getEtxdt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table etxdt 
    Notes  : service externe. Critère piNoapp = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNotrx as integer    no-undo.
    define input parameter pcTpapp as character  no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter table-handle phttEtxdt.
    define variable vhttBuffer as handle  no-undo.
    define buffer etxdt for etxdt.

    vhttBuffer = phttEtxdt:default-buffer-handle.
    if piNoapp = ?
    then for each etxdt no-lock
        where etxdt.notrx = piNotrx
          and etxdt.tpapp = pcTpapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer etxdt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each etxdt no-lock
        where etxdt.notrx = piNotrx
          and etxdt.tpapp = pcTpapp
          and etxdt.noapp = piNoapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer etxdt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEtxdt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateEtxdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNotrx    as handle  no-undo.
    define variable vhTpapp    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define buffer etxdt for etxdt.

    create query vhttquery.
    vhttBuffer = ghttEtxdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttEtxdt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNotrx, output vhTpapp, output vhNoapp, output vhNolot).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first etxdt exclusive-lock
                where rowid(etxdt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer etxdt:handle, 'notrx/tpapp/noapp/nolot: ', substitute('&1/&2/&3/&4', vhNotrx:buffer-value(), vhTpapp:buffer-value(), vhNoapp:buffer-value(), vhNolot:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer etxdt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createEtxdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer etxdt for etxdt.

    create query vhttquery.
    vhttBuffer = ghttEtxdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttEtxdt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create etxdt.
            if not outils:copyValidField(buffer etxdt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteEtxdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNotrx    as handle  no-undo.
    define variable vhTpapp    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define buffer etxdt for etxdt.

    create query vhttquery.
    vhttBuffer = ghttEtxdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttEtxdt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNotrx, output vhTpapp, output vhNoapp, output vhNolot).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first etxdt exclusive-lock
                where rowid(Etxdt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer etxdt:handle, 'notrx/tpapp/noapp/nolot: ', substitute('&1/&2/&3/&4', vhNotrx:buffer-value(), vhTpapp:buffer-value(), vhNoapp:buffer-value(), vhNolot:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete etxdt no-error.
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

