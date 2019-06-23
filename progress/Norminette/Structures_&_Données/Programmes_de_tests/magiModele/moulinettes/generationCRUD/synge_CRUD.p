/*------------------------------------------------------------------------
File        : synge_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table synge
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/synge.i}
{application/include/error.i}
define variable ghttsynge as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpctp as handle, output phNoctp as handle, output phTpct1 as handle, output phNoct1 as handle, output phTpct2 as handle, output phNoct2 as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpctp/noctp/tpct1/noct1/tpct2/noct2, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpctp' then phTpctp = phBuffer:buffer-field(vi).
            when 'noctp' then phNoctp = phBuffer:buffer-field(vi).
            when 'tpct1' then phTpct1 = phBuffer:buffer-field(vi).
            when 'noct1' then phNoct1 = phBuffer:buffer-field(vi).
            when 'tpct2' then phTpct2 = phBuffer:buffer-field(vi).
            when 'noct2' then phNoct2 = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSynge private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSynge.
    run updateSynge.
    run createSynge.
end procedure.

procedure setSynge:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSynge.
    ghttSynge = phttSynge.
    run crudSynge.
    delete object phttSynge.
end procedure.

procedure readSynge:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table synge 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpctp as character  no-undo.
    define input parameter piNoctp as integer    no-undo.
    define input parameter pcTpct1 as character  no-undo.
    define input parameter piNoct1 as int64      no-undo.
    define input parameter pcTpct2 as character  no-undo.
    define input parameter piNoct2 as integer    no-undo.
    define input parameter table-handle phttSynge.
    define variable vhttBuffer as handle no-undo.
    define buffer synge for synge.

    vhttBuffer = phttSynge:default-buffer-handle.
    for first synge no-lock
        where synge.tpctp = pcTpctp
          and synge.noctp = piNoctp
          and synge.tpct1 = pcTpct1
          and synge.noct1 = piNoct1
          and synge.tpct2 = pcTpct2
          and synge.noct2 = piNoct2:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer synge:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSynge no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSynge:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table synge 
    Notes  : service externe. Critère pcTpct2 = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpctp as character  no-undo.
    define input parameter piNoctp as integer    no-undo.
    define input parameter pcTpct1 as character  no-undo.
    define input parameter piNoct1 as int64      no-undo.
    define input parameter pcTpct2 as character  no-undo.
    define input parameter table-handle phttSynge.
    define variable vhttBuffer as handle  no-undo.
    define buffer synge for synge.

    vhttBuffer = phttSynge:default-buffer-handle.
    if pcTpct2 = ?
    then for each synge no-lock
        where synge.tpctp = pcTpctp
          and synge.noctp = piNoctp
          and synge.tpct1 = pcTpct1
          and synge.noct1 = piNoct1:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer synge:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each synge no-lock
        where synge.tpctp = pcTpctp
          and synge.noctp = piNoctp
          and synge.tpct1 = pcTpct1
          and synge.noct1 = piNoct1
          and synge.tpct2 = pcTpct2:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer synge:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSynge no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSynge private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpctp    as handle  no-undo.
    define variable vhNoctp    as handle  no-undo.
    define variable vhTpct1    as handle  no-undo.
    define variable vhNoct1    as handle  no-undo.
    define variable vhTpct2    as handle  no-undo.
    define variable vhNoct2    as handle  no-undo.
    define buffer synge for synge.

    create query vhttquery.
    vhttBuffer = ghttSynge:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSynge:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpctp, output vhNoctp, output vhTpct1, output vhNoct1, output vhTpct2, output vhNoct2).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first synge exclusive-lock
                where rowid(synge) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer synge:handle, 'tpctp/noctp/tpct1/noct1/tpct2/noct2: ', substitute('&1/&2/&3/&4/&5/&6', vhTpctp:buffer-value(), vhNoctp:buffer-value(), vhTpct1:buffer-value(), vhNoct1:buffer-value(), vhTpct2:buffer-value(), vhNoct2:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer synge:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSynge private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer synge for synge.

    create query vhttquery.
    vhttBuffer = ghttSynge:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSynge:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create synge.
            if not outils:copyValidField(buffer synge:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSynge private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpctp    as handle  no-undo.
    define variable vhNoctp    as handle  no-undo.
    define variable vhTpct1    as handle  no-undo.
    define variable vhNoct1    as handle  no-undo.
    define variable vhTpct2    as handle  no-undo.
    define variable vhNoct2    as handle  no-undo.
    define buffer synge for synge.

    create query vhttquery.
    vhttBuffer = ghttSynge:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSynge:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpctp, output vhNoctp, output vhTpct1, output vhNoct1, output vhTpct2, output vhNoct2).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first synge exclusive-lock
                where rowid(Synge) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer synge:handle, 'tpctp/noctp/tpct1/noct1/tpct2/noct2: ', substitute('&1/&2/&3/&4/&5/&6', vhTpctp:buffer-value(), vhNoctp:buffer-value(), vhTpct1:buffer-value(), vhNoct1:buffer-value(), vhTpct2:buffer-value(), vhNoct2:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete synge no-error.
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

