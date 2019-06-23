/*------------------------------------------------------------------------
File        : trhon_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table trhon
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/trhon.i}
{application/include/error.i}
define variable ghtttrhon as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTphon as handle, output phNohon as handle, output phNotrc as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tphon/nohon/notrc, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tphon' then phTphon = phBuffer:buffer-field(vi).
            when 'nohon' then phNohon = phBuffer:buffer-field(vi).
            when 'notrc' then phNotrc = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTrhon private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTrhon.
    run updateTrhon.
    run createTrhon.
end procedure.

procedure setTrhon:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTrhon.
    ghttTrhon = phttTrhon.
    run crudTrhon.
    delete object phttTrhon.
end procedure.

procedure readTrhon:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table trhon Gestion des tranches pour les honoraires travaux
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTphon as character  no-undo.
    define input parameter piNohon as integer    no-undo.
    define input parameter piNotrc as integer    no-undo.
    define input parameter table-handle phttTrhon.
    define variable vhttBuffer as handle no-undo.
    define buffer trhon for trhon.

    vhttBuffer = phttTrhon:default-buffer-handle.
    for first trhon no-lock
        where trhon.tphon = pcTphon
          and trhon.nohon = piNohon
          and trhon.notrc = piNotrc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trhon:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTrhon no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTrhon:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table trhon Gestion des tranches pour les honoraires travaux
    Notes  : service externe. Critère piNohon = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTphon as character  no-undo.
    define input parameter piNohon as integer    no-undo.
    define input parameter table-handle phttTrhon.
    define variable vhttBuffer as handle  no-undo.
    define buffer trhon for trhon.

    vhttBuffer = phttTrhon:default-buffer-handle.
    if piNohon = ?
    then for each trhon no-lock
        where trhon.tphon = pcTphon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trhon:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each trhon no-lock
        where trhon.tphon = pcTphon
          and trhon.nohon = piNohon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trhon:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTrhon no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTrhon private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTphon    as handle  no-undo.
    define variable vhNohon    as handle  no-undo.
    define variable vhNotrc    as handle  no-undo.
    define buffer trhon for trhon.

    create query vhttquery.
    vhttBuffer = ghttTrhon:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTrhon:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTphon, output vhNohon, output vhNotrc).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first trhon exclusive-lock
                where rowid(trhon) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer trhon:handle, 'tphon/nohon/notrc: ', substitute('&1/&2/&3', vhTphon:buffer-value(), vhNohon:buffer-value(), vhNotrc:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer trhon:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTrhon private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer trhon for trhon.

    create query vhttquery.
    vhttBuffer = ghttTrhon:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTrhon:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create trhon.
            if not outils:copyValidField(buffer trhon:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTrhon private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTphon    as handle  no-undo.
    define variable vhNohon    as handle  no-undo.
    define variable vhNotrc    as handle  no-undo.
    define buffer trhon for trhon.

    create query vhttquery.
    vhttBuffer = ghttTrhon:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTrhon:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTphon, output vhNohon, output vhNotrc).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first trhon exclusive-lock
                where rowid(Trhon) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer trhon:handle, 'tphon/nohon/notrc: ', substitute('&1/&2/&3', vhTphon:buffer-value(), vhNohon:buffer-value(), vhNotrc:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete trhon no-error.
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

