/*------------------------------------------------------------------------
File        : fdrou_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table fdrou
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/fdrou.i}
{application/include/error.i}
define variable ghttfdrou as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoimm as handle, output phTpfon as handle, output phNofon as handle, output phNolot as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noimm/tpfon/nofon/nolot, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noimm' then phNoimm = phBuffer:buffer-field(vi).
            when 'tpfon' then phTpfon = phBuffer:buffer-field(vi).
            when 'nofon' then phNofon = phBuffer:buffer-field(vi).
            when 'nolot' then phNolot = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudFdrou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteFdrou.
    run updateFdrou.
    run createFdrou.
end procedure.

procedure setFdrou:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttFdrou.
    ghttFdrou = phttFdrou.
    run crudFdrou.
    delete object phttFdrou.
end procedure.

procedure readFdrou:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table fdrou 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoimm as integer    no-undo.
    define input parameter pcTpfon as character  no-undo.
    define input parameter piNofon as integer    no-undo.
    define input parameter piNolot as integer    no-undo.
    define input parameter table-handle phttFdrou.
    define variable vhttBuffer as handle no-undo.
    define buffer fdrou for fdrou.

    vhttBuffer = phttFdrou:default-buffer-handle.
    for first fdrou no-lock
        where fdrou.noimm = piNoimm
          and fdrou.tpfon = pcTpfon
          and fdrou.nofon = piNofon
          and fdrou.nolot = piNolot:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer fdrou:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttFdrou no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getFdrou:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table fdrou 
    Notes  : service externe. Critère piNofon = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoimm as integer    no-undo.
    define input parameter pcTpfon as character  no-undo.
    define input parameter piNofon as integer    no-undo.
    define input parameter table-handle phttFdrou.
    define variable vhttBuffer as handle  no-undo.
    define buffer fdrou for fdrou.

    vhttBuffer = phttFdrou:default-buffer-handle.
    if piNofon = ?
    then for each fdrou no-lock
        where fdrou.noimm = piNoimm
          and fdrou.tpfon = pcTpfon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer fdrou:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each fdrou no-lock
        where fdrou.noimm = piNoimm
          and fdrou.tpfon = pcTpfon
          and fdrou.nofon = piNofon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer fdrou:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttFdrou no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateFdrou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhTpfon    as handle  no-undo.
    define variable vhNofon    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define buffer fdrou for fdrou.

    create query vhttquery.
    vhttBuffer = ghttFdrou:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttFdrou:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoimm, output vhTpfon, output vhNofon, output vhNolot).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first fdrou exclusive-lock
                where rowid(fdrou) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer fdrou:handle, 'noimm/tpfon/nofon/nolot: ', substitute('&1/&2/&3/&4', vhNoimm:buffer-value(), vhTpfon:buffer-value(), vhNofon:buffer-value(), vhNolot:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer fdrou:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createFdrou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer fdrou for fdrou.

    create query vhttquery.
    vhttBuffer = ghttFdrou:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttFdrou:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create fdrou.
            if not outils:copyValidField(buffer fdrou:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteFdrou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhTpfon    as handle  no-undo.
    define variable vhNofon    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define buffer fdrou for fdrou.

    create query vhttquery.
    vhttBuffer = ghttFdrou:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttFdrou:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoimm, output vhTpfon, output vhNofon, output vhNolot).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first fdrou exclusive-lock
                where rowid(Fdrou) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer fdrou:handle, 'noimm/tpfon/nofon/nolot: ', substitute('&1/&2/&3/&4', vhNoimm:buffer-value(), vhTpfon:buffer-value(), vhNofon:buffer-value(), vhNolot:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete fdrou no-error.
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

