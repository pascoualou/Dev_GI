/*------------------------------------------------------------------------
File        : txbdt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table txbdt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/txbdt.i}
{application/include/error.i}
define variable ghtttxbdt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phAnnee as handle, output phNoimm as handle, output phNoman as handle, output phNolot as handle, output phNoulo as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur annee/noimm/noman/nolot/noulo, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'annee' then phAnnee = phBuffer:buffer-field(vi).
            when 'noimm' then phNoimm = phBuffer:buffer-field(vi).
            when 'noman' then phNoman = phBuffer:buffer-field(vi).
            when 'nolot' then phNolot = phBuffer:buffer-field(vi).
            when 'noulo' then phNoulo = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTxbdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTxbdt.
    run updateTxbdt.
    run createTxbdt.
end procedure.

procedure setTxbdt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTxbdt.
    ghttTxbdt = phttTxbdt.
    run crudTxbdt.
    delete object phttTxbdt.
end procedure.

procedure readTxbdt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table txbdt Table detail de la taxe sur bureaux
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piAnnee as integer    no-undo.
    define input parameter piNoimm as integer    no-undo.
    define input parameter piNoman as integer    no-undo.
    define input parameter piNolot as integer    no-undo.
    define input parameter piNoulo as integer    no-undo.
    define input parameter table-handle phttTxbdt.
    define variable vhttBuffer as handle no-undo.
    define buffer txbdt for txbdt.

    vhttBuffer = phttTxbdt:default-buffer-handle.
    for first txbdt no-lock
        where txbdt.annee = piAnnee
          and txbdt.noimm = piNoimm
          and txbdt.noman = piNoman
          and txbdt.nolot = piNolot
          and txbdt.noulo = piNoulo:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer txbdt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTxbdt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTxbdt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table txbdt Table detail de la taxe sur bureaux
    Notes  : service externe. Critère piNolot = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piAnnee as integer    no-undo.
    define input parameter piNoimm as integer    no-undo.
    define input parameter piNoman as integer    no-undo.
    define input parameter piNolot as integer    no-undo.
    define input parameter table-handle phttTxbdt.
    define variable vhttBuffer as handle  no-undo.
    define buffer txbdt for txbdt.

    vhttBuffer = phttTxbdt:default-buffer-handle.
    if piNolot = ?
    then for each txbdt no-lock
        where txbdt.annee = piAnnee
          and txbdt.noimm = piNoimm
          and txbdt.noman = piNoman:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer txbdt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each txbdt no-lock
        where txbdt.annee = piAnnee
          and txbdt.noimm = piNoimm
          and txbdt.noman = piNoman
          and txbdt.nolot = piNolot:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer txbdt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTxbdt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTxbdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhAnnee    as handle  no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhNoman    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define variable vhNoulo    as handle  no-undo.
    define buffer txbdt for txbdt.

    create query vhttquery.
    vhttBuffer = ghttTxbdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTxbdt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhAnnee, output vhNoimm, output vhNoman, output vhNolot, output vhNoulo).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first txbdt exclusive-lock
                where rowid(txbdt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer txbdt:handle, 'annee/noimm/noman/nolot/noulo: ', substitute('&1/&2/&3/&4/&5', vhAnnee:buffer-value(), vhNoimm:buffer-value(), vhNoman:buffer-value(), vhNolot:buffer-value(), vhNoulo:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer txbdt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTxbdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer txbdt for txbdt.

    create query vhttquery.
    vhttBuffer = ghttTxbdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTxbdt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create txbdt.
            if not outils:copyValidField(buffer txbdt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTxbdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhAnnee    as handle  no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhNoman    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define variable vhNoulo    as handle  no-undo.
    define buffer txbdt for txbdt.

    create query vhttquery.
    vhttBuffer = ghttTxbdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTxbdt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhAnnee, output vhNoimm, output vhNoman, output vhNolot, output vhNoulo).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first txbdt exclusive-lock
                where rowid(Txbdt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer txbdt:handle, 'annee/noimm/noman/nolot/noulo: ', substitute('&1/&2/&3/&4/&5', vhAnnee:buffer-value(), vhNoimm:buffer-value(), vhNoman:buffer-value(), vhNolot:buffer-value(), vhNoulo:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete txbdt no-error.
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

