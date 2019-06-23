/*------------------------------------------------------------------------
File        : REFGI_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table REFGI
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/REFGI.i}
{application/include/error.i}
define variable ghttREFGI as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNodot as handle, output phNochp as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nodot/nochp, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nodot' then phNodot = phBuffer:buffer-field(vi).
            when 'nochp' then phNochp = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudRefgi private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteRefgi.
    run updateRefgi.
    run createRefgi.
end procedure.

procedure setRefgi:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRefgi.
    ghttRefgi = phttRefgi.
    run crudRefgi.
    delete object phttRefgi.
end procedure.

procedure readRefgi:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table REFGI Référence GI
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNodot as integer    no-undo.
    define input parameter piNochp as integer    no-undo.
    define input parameter table-handle phttRefgi.
    define variable vhttBuffer as handle no-undo.
    define buffer REFGI for REFGI.

    vhttBuffer = phttRefgi:default-buffer-handle.
    for first REFGI no-lock
        where REFGI.nodot = piNodot
          and REFGI.nochp = piNochp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer REFGI:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRefgi no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getRefgi:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table REFGI Référence GI
    Notes  : service externe. Critère piNodot = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNodot as integer    no-undo.
    define input parameter table-handle phttRefgi.
    define variable vhttBuffer as handle  no-undo.
    define buffer REFGI for REFGI.

    vhttBuffer = phttRefgi:default-buffer-handle.
    if piNodot = ?
    then for each REFGI no-lock
        where REFGI.nodot = piNodot:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer REFGI:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each REFGI no-lock
        where REFGI.nodot = piNodot:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer REFGI:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRefgi no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateRefgi private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNodot    as handle  no-undo.
    define variable vhNochp    as handle  no-undo.
    define buffer REFGI for REFGI.

    create query vhttquery.
    vhttBuffer = ghttRefgi:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttRefgi:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNodot, output vhNochp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first REFGI exclusive-lock
                where rowid(REFGI) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer REFGI:handle, 'nodot/nochp: ', substitute('&1/&2', vhNodot:buffer-value(), vhNochp:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer REFGI:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createRefgi private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer REFGI for REFGI.

    create query vhttquery.
    vhttBuffer = ghttRefgi:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttRefgi:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create REFGI.
            if not outils:copyValidField(buffer REFGI:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteRefgi private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNodot    as handle  no-undo.
    define variable vhNochp    as handle  no-undo.
    define buffer REFGI for REFGI.

    create query vhttquery.
    vhttBuffer = ghttRefgi:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttRefgi:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNodot, output vhNochp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first REFGI exclusive-lock
                where rowid(Refgi) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer REFGI:handle, 'nodot/nochp: ', substitute('&1/&2', vhNodot:buffer-value(), vhNochp:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete REFGI no-error.
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

