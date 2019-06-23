/*------------------------------------------------------------------------
File        : piece_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table piece
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/piece.i}
{application/include/error.i}
define variable ghttpiece as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoloc as handle, output phNopie as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noloc/nopie, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noloc' then phNoloc = phBuffer:buffer-field(vi).
            when 'nopie' then phNopie = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPiece private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePiece.
    run updatePiece.
    run createPiece.
end procedure.

procedure setPiece:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPiece.
    ghttPiece = phttPiece.
    run crudPiece.
    delete object phttPiece.
end procedure.

procedure readPiece:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table piece 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoloc as int64      no-undo.
    define input parameter piNopie as integer    no-undo.
    define input parameter table-handle phttPiece.
    define variable vhttBuffer as handle no-undo.
    define buffer piece for piece.

    vhttBuffer = phttPiece:default-buffer-handle.
    for first piece no-lock
        where piece.noloc = piNoloc
          and piece.nopie = piNopie:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer piece:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPiece no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPiece:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table piece 
    Notes  : service externe. Critère piNoloc = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoloc as int64      no-undo.
    define input parameter table-handle phttPiece.
    define variable vhttBuffer as handle  no-undo.
    define buffer piece for piece.

    vhttBuffer = phttPiece:default-buffer-handle.
    if piNoloc = ?
    then for each piece no-lock
        where piece.noloc = piNoloc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer piece:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each piece no-lock
        where piece.noloc = piNoloc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer piece:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPiece no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePiece private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoloc    as handle  no-undo.
    define variable vhNopie    as handle  no-undo.
    define buffer piece for piece.

    create query vhttquery.
    vhttBuffer = ghttPiece:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPiece:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoloc, output vhNopie).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first piece exclusive-lock
                where rowid(piece) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer piece:handle, 'noloc/nopie: ', substitute('&1/&2', vhNoloc:buffer-value(), vhNopie:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer piece:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPiece private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer piece for piece.

    create query vhttquery.
    vhttBuffer = ghttPiece:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPiece:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create piece.
            if not outils:copyValidField(buffer piece:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePiece private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoloc    as handle  no-undo.
    define variable vhNopie    as handle  no-undo.
    define buffer piece for piece.

    create query vhttquery.
    vhttBuffer = ghttPiece:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPiece:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoloc, output vhNopie).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first piece exclusive-lock
                where rowid(Piece) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer piece:handle, 'noloc/nopie: ', substitute('&1/&2', vhNoloc:buffer-value(), vhNopie:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete piece no-error.
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

