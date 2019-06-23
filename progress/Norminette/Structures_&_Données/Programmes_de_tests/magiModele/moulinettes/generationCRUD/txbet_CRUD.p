/*------------------------------------------------------------------------
File        : txbet_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table txbet
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/txbet.i}
{application/include/error.i}
define variable ghtttxbet as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phAnnee as handle, output phNoimm as handle, output phNoman as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur annee/noimm/noman, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'annee' then phAnnee = phBuffer:buffer-field(vi).
            when 'noimm' then phNoimm = phBuffer:buffer-field(vi).
            when 'noman' then phNoman = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTxbet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTxbet.
    run updateTxbet.
    run createTxbet.
end procedure.

procedure setTxbet:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTxbet.
    ghttTxbet = phttTxbet.
    run crudTxbet.
    delete object phttTxbet.
end procedure.

procedure readTxbet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table txbet Table entete de la taxe sur bureaux
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piAnnee as integer    no-undo.
    define input parameter piNoimm as integer    no-undo.
    define input parameter piNoman as integer    no-undo.
    define input parameter table-handle phttTxbet.
    define variable vhttBuffer as handle no-undo.
    define buffer txbet for txbet.

    vhttBuffer = phttTxbet:default-buffer-handle.
    for first txbet no-lock
        where txbet.annee = piAnnee
          and txbet.noimm = piNoimm
          and txbet.noman = piNoman:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer txbet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTxbet no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTxbet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table txbet Table entete de la taxe sur bureaux
    Notes  : service externe. Critère piNoimm = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piAnnee as integer    no-undo.
    define input parameter piNoimm as integer    no-undo.
    define input parameter table-handle phttTxbet.
    define variable vhttBuffer as handle  no-undo.
    define buffer txbet for txbet.

    vhttBuffer = phttTxbet:default-buffer-handle.
    if piNoimm = ?
    then for each txbet no-lock
        where txbet.annee = piAnnee:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer txbet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each txbet no-lock
        where txbet.annee = piAnnee
          and txbet.noimm = piNoimm:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer txbet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTxbet no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTxbet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhAnnee    as handle  no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhNoman    as handle  no-undo.
    define buffer txbet for txbet.

    create query vhttquery.
    vhttBuffer = ghttTxbet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTxbet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhAnnee, output vhNoimm, output vhNoman).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first txbet exclusive-lock
                where rowid(txbet) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer txbet:handle, 'annee/noimm/noman: ', substitute('&1/&2/&3', vhAnnee:buffer-value(), vhNoimm:buffer-value(), vhNoman:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer txbet:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTxbet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer txbet for txbet.

    create query vhttquery.
    vhttBuffer = ghttTxbet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTxbet:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create txbet.
            if not outils:copyValidField(buffer txbet:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTxbet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhAnnee    as handle  no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhNoman    as handle  no-undo.
    define buffer txbet for txbet.

    create query vhttquery.
    vhttBuffer = ghttTxbet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTxbet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhAnnee, output vhNoimm, output vhNoman).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first txbet exclusive-lock
                where rowid(Txbet) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer txbet:handle, 'annee/noimm/noman: ', substitute('&1/&2/&3', vhAnnee:buffer-value(), vhNoimm:buffer-value(), vhNoman:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete txbet no-error.
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

