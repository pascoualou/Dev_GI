/*------------------------------------------------------------------------
File        : ahbmt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ahbmt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ahbmt.i}
{application/include/error.i}
define variable ghttahbmt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoimm as handle, output phNoapp as handle, output phNolot as handle, output phNocop as handle, output phNoecr as handle, output phNolig as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noimm/noapp/nolot/nocop/noecr/nolig, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noimm' then phNoimm = phBuffer:buffer-field(vi).
            when 'noapp' then phNoapp = phBuffer:buffer-field(vi).
            when 'nolot' then phNolot = phBuffer:buffer-field(vi).
            when 'nocop' then phNocop = phBuffer:buffer-field(vi).
            when 'noecr' then phNoecr = phBuffer:buffer-field(vi).
            when 'nolig' then phNolig = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAhbmt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAhbmt.
    run updateAhbmt.
    run createAhbmt.
end procedure.

procedure setAhbmt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAhbmt.
    ghttAhbmt = phttAhbmt.
    run crudAhbmt.
    delete object phttAhbmt.
end procedure.

procedure readAhbmt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ahbmt 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoimm as integer    no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter piNolot as integer    no-undo.
    define input parameter piNocop as integer    no-undo.
    define input parameter piNoecr as integer    no-undo.
    define input parameter piNolig as integer    no-undo.
    define input parameter table-handle phttAhbmt.
    define variable vhttBuffer as handle no-undo.
    define buffer ahbmt for ahbmt.

    vhttBuffer = phttAhbmt:default-buffer-handle.
    for first ahbmt no-lock
        where ahbmt.noimm = piNoimm
          and ahbmt.noapp = piNoapp
          and ahbmt.nolot = piNolot
          and ahbmt.nocop = piNocop
          and ahbmt.noecr = piNoecr
          and ahbmt.nolig = piNolig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ahbmt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAhbmt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAhbmt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ahbmt 
    Notes  : service externe. Critère piNoecr = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoimm as integer    no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter piNolot as integer    no-undo.
    define input parameter piNocop as integer    no-undo.
    define input parameter piNoecr as integer    no-undo.
    define input parameter table-handle phttAhbmt.
    define variable vhttBuffer as handle  no-undo.
    define buffer ahbmt for ahbmt.

    vhttBuffer = phttAhbmt:default-buffer-handle.
    if piNoecr = ?
    then for each ahbmt no-lock
        where ahbmt.noimm = piNoimm
          and ahbmt.noapp = piNoapp
          and ahbmt.nolot = piNolot
          and ahbmt.nocop = piNocop:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ahbmt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ahbmt no-lock
        where ahbmt.noimm = piNoimm
          and ahbmt.noapp = piNoapp
          and ahbmt.nolot = piNolot
          and ahbmt.nocop = piNocop
          and ahbmt.noecr = piNoecr:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ahbmt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAhbmt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAhbmt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define variable vhNocop    as handle  no-undo.
    define variable vhNoecr    as handle  no-undo.
    define variable vhNolig    as handle  no-undo.
    define buffer ahbmt for ahbmt.

    create query vhttquery.
    vhttBuffer = ghttAhbmt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAhbmt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoimm, output vhNoapp, output vhNolot, output vhNocop, output vhNoecr, output vhNolig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ahbmt exclusive-lock
                where rowid(ahbmt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ahbmt:handle, 'noimm/noapp/nolot/nocop/noecr/nolig: ', substitute('&1/&2/&3/&4/&5/&6', vhNoimm:buffer-value(), vhNoapp:buffer-value(), vhNolot:buffer-value(), vhNocop:buffer-value(), vhNoecr:buffer-value(), vhNolig:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ahbmt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAhbmt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ahbmt for ahbmt.

    create query vhttquery.
    vhttBuffer = ghttAhbmt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAhbmt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ahbmt.
            if not outils:copyValidField(buffer ahbmt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAhbmt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define variable vhNocop    as handle  no-undo.
    define variable vhNoecr    as handle  no-undo.
    define variable vhNolig    as handle  no-undo.
    define buffer ahbmt for ahbmt.

    create query vhttquery.
    vhttBuffer = ghttAhbmt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAhbmt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoimm, output vhNoapp, output vhNolot, output vhNocop, output vhNoecr, output vhNolig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ahbmt exclusive-lock
                where rowid(Ahbmt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ahbmt:handle, 'noimm/noapp/nolot/nocop/noecr/nolig: ', substitute('&1/&2/&3/&4/&5/&6', vhNoimm:buffer-value(), vhNoapp:buffer-value(), vhNolot:buffer-value(), vhNocop:buffer-value(), vhNoecr:buffer-value(), vhNolig:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ahbmt no-error.
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

