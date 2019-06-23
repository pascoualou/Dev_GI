/*------------------------------------------------------------------------
File        : FERIE_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table FERIE
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/FERIE.i}
{application/include/error.i}
define variable ghttFERIE as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNofer as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur NOFER, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'NOFER' then phNofer = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudFerie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteFerie.
    run updateFerie.
    run createFerie.
end procedure.

procedure setFerie:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttFerie.
    ghttFerie = phttFerie.
    run crudFerie.
    delete object phttFerie.
end procedure.

procedure readFerie:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table FERIE 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNofer as integer    no-undo.
    define input parameter table-handle phttFerie.
    define variable vhttBuffer as handle no-undo.
    define buffer FERIE for FERIE.

    vhttBuffer = phttFerie:default-buffer-handle.
    for first FERIE no-lock
        where FERIE.NOFER = piNofer:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer FERIE:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttFerie no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getFerie:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table FERIE 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttFerie.
    define variable vhttBuffer as handle  no-undo.
    define buffer FERIE for FERIE.

    vhttBuffer = phttFerie:default-buffer-handle.
    for each FERIE no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer FERIE:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttFerie no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateFerie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNofer    as handle  no-undo.
    define buffer FERIE for FERIE.

    create query vhttquery.
    vhttBuffer = ghttFerie:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttFerie:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNofer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first FERIE exclusive-lock
                where rowid(FERIE) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer FERIE:handle, 'NOFER: ', substitute('&1', vhNofer:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer FERIE:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createFerie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer FERIE for FERIE.

    create query vhttquery.
    vhttBuffer = ghttFerie:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttFerie:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create FERIE.
            if not outils:copyValidField(buffer FERIE:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteFerie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNofer    as handle  no-undo.
    define buffer FERIE for FERIE.

    create query vhttquery.
    vhttBuffer = ghttFerie:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttFerie:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNofer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first FERIE exclusive-lock
                where rowid(Ferie) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer FERIE:handle, 'NOFER: ', substitute('&1', vhNofer:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete FERIE no-error.
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

