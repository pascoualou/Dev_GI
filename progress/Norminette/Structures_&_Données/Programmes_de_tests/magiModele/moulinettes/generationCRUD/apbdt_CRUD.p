/*------------------------------------------------------------------------
File        : apbdt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table apbdt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/apbdt.i}
{application/include/error.i}
define variable ghttapbdt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNobud as handle, output phTpapp as handle, output phNoapp as handle, output phNolig as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nobud/tpapp/noapp/nolig, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nobud' then phNobud = phBuffer:buffer-field(vi).
            when 'tpapp' then phTpapp = phBuffer:buffer-field(vi).
            when 'noapp' then phNoapp = phBuffer:buffer-field(vi).
            when 'nolig' then phNolig = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudApbdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteApbdt.
    run updateApbdt.
    run createApbdt.
end procedure.

procedure setApbdt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttApbdt.
    ghttApbdt = phttApbdt.
    run crudApbdt.
    delete object phttApbdt.
end procedure.

procedure readApbdt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table apbdt 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNobud as int64      no-undo.
    define input parameter pcTpapp as character  no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter piNolig as integer    no-undo.
    define input parameter table-handle phttApbdt.
    define variable vhttBuffer as handle no-undo.
    define buffer apbdt for apbdt.

    vhttBuffer = phttApbdt:default-buffer-handle.
    for first apbdt no-lock
        where apbdt.nobud = piNobud
          and apbdt.tpapp = pcTpapp
          and apbdt.noapp = piNoapp
          and apbdt.nolig = piNolig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer apbdt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttApbdt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getApbdt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table apbdt 
    Notes  : service externe. Critère piNoapp = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNobud as int64      no-undo.
    define input parameter pcTpapp as character  no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter table-handle phttApbdt.
    define variable vhttBuffer as handle  no-undo.
    define buffer apbdt for apbdt.

    vhttBuffer = phttApbdt:default-buffer-handle.
    if piNoapp = ?
    then for each apbdt no-lock
        where apbdt.nobud = piNobud
          and apbdt.tpapp = pcTpapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer apbdt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each apbdt no-lock
        where apbdt.nobud = piNobud
          and apbdt.tpapp = pcTpapp
          and apbdt.noapp = piNoapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer apbdt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttApbdt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateApbdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNobud    as handle  no-undo.
    define variable vhTpapp    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define variable vhNolig    as handle  no-undo.
    define buffer apbdt for apbdt.

    create query vhttquery.
    vhttBuffer = ghttApbdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttApbdt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNobud, output vhTpapp, output vhNoapp, output vhNolig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first apbdt exclusive-lock
                where rowid(apbdt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer apbdt:handle, 'nobud/tpapp/noapp/nolig: ', substitute('&1/&2/&3/&4', vhNobud:buffer-value(), vhTpapp:buffer-value(), vhNoapp:buffer-value(), vhNolig:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer apbdt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createApbdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer apbdt for apbdt.

    create query vhttquery.
    vhttBuffer = ghttApbdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttApbdt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create apbdt.
            if not outils:copyValidField(buffer apbdt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteApbdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNobud    as handle  no-undo.
    define variable vhTpapp    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define variable vhNolig    as handle  no-undo.
    define buffer apbdt for apbdt.

    create query vhttquery.
    vhttBuffer = ghttApbdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttApbdt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNobud, output vhTpapp, output vhNoapp, output vhNolig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first apbdt exclusive-lock
                where rowid(Apbdt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer apbdt:handle, 'nobud/tpapp/noapp/nolig: ', substitute('&1/&2/&3/&4', vhNobud:buffer-value(), vhTpapp:buffer-value(), vhNoapp:buffer-value(), vhNolig:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete apbdt no-error.
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

