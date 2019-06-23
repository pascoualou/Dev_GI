/*------------------------------------------------------------------------
File        : ifmt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifmt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifmt.i}
{application/include/error.i}
define variable ghttifmt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur , 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
       end case.
    end.
end function.

procedure crudIfmt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfmt.
    run updateIfmt.
    run createIfmt.
end procedure.

procedure setIfmt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfmt.
    ghttIfmt = phttIfmt.
    run crudIfmt.
    delete object phttIfmt.
end procedure.

procedure readIfmt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifmt 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfmt.
    define variable vhttBuffer as handle no-undo.
    define buffer ifmt for ifmt.

    vhttBuffer = phttIfmt:default-buffer-handle.
    for first ifmt no-lock
        where :
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifmt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfmt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfmt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifmt 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfmt.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifmt for ifmt.

    vhttBuffer = phttIfmt:default-buffer-handle.
    for each ifmt no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifmt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfmt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfmt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifmt for ifmt.

    create query vhttquery.
    vhttBuffer = ghttIfmt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfmt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifmt exclusive-lock
                where rowid(ifmt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifmt:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifmt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfmt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifmt for ifmt.

    create query vhttquery.
    vhttBuffer = ghttIfmt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfmt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifmt.
            if not outils:copyValidField(buffer ifmt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfmt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifmt for ifmt.

    create query vhttquery.
    vhttBuffer = ghttIfmt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfmt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifmt exclusive-lock
                where rowid(Ifmt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifmt:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifmt no-error.
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

