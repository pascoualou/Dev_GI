/*------------------------------------------------------------------------
File        : atxdt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table atxdt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/atxdt.i}
{application/include/error.i}
define variable ghttatxdt as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudAtxdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAtxdt.
    run updateAtxdt.
    run createAtxdt.
end procedure.

procedure setAtxdt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAtxdt.
    ghttAtxdt = phttAtxdt.
    run crudAtxdt.
    delete object phttAtxdt.
end procedure.

procedure readAtxdt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table atxdt 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNotrx as int64      no-undo.
    define input parameter pcTpapp as character  no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter piNolot as integer    no-undo.
    define input parameter table-handle phttAtxdt.
    define variable vhttBuffer as handle no-undo.
    define buffer atxdt for atxdt.

    vhttBuffer = phttAtxdt:default-buffer-handle.
    for first atxdt no-lock
        where atxdt.notrx = piNotrx
          and atxdt.tpapp = pcTpapp
          and atxdt.noapp = piNoapp
          and atxdt.nolot = piNolot:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer atxdt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAtxdt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAtxdt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table atxdt 
    Notes  : service externe. Critère piNoapp = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNotrx as int64      no-undo.
    define input parameter pcTpapp as character  no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter table-handle phttAtxdt.
    define variable vhttBuffer as handle  no-undo.
    define buffer atxdt for atxdt.

    vhttBuffer = phttAtxdt:default-buffer-handle.
    if piNoapp = ?
    then for each atxdt no-lock
        where atxdt.notrx = piNotrx
          and atxdt.tpapp = pcTpapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer atxdt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each atxdt no-lock
        where atxdt.notrx = piNotrx
          and atxdt.tpapp = pcTpapp
          and atxdt.noapp = piNoapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer atxdt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAtxdt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAtxdt private:
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
    define buffer atxdt for atxdt.

    create query vhttquery.
    vhttBuffer = ghttAtxdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAtxdt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNotrx, output vhTpapp, output vhNoapp, output vhNolot).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first atxdt exclusive-lock
                where rowid(atxdt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer atxdt:handle, 'notrx/tpapp/noapp/nolot: ', substitute('&1/&2/&3/&4', vhNotrx:buffer-value(), vhTpapp:buffer-value(), vhNoapp:buffer-value(), vhNolot:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer atxdt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAtxdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer atxdt for atxdt.

    create query vhttquery.
    vhttBuffer = ghttAtxdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAtxdt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create atxdt.
            if not outils:copyValidField(buffer atxdt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAtxdt private:
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
    define buffer atxdt for atxdt.

    create query vhttquery.
    vhttBuffer = ghttAtxdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAtxdt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNotrx, output vhTpapp, output vhNoapp, output vhNolot).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first atxdt exclusive-lock
                where rowid(Atxdt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer atxdt:handle, 'notrx/tpapp/noapp/nolot: ', substitute('&1/&2/&3/&4', vhNotrx:buffer-value(), vhTpapp:buffer-value(), vhNoapp:buffer-value(), vhNolot:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete atxdt no-error.
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

