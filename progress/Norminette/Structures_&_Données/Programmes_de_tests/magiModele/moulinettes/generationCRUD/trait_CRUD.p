/*------------------------------------------------------------------------
File        : trait_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table trait
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/trait.i}
{application/include/error.i}
define variable ghtttrait as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNotrt as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur notrt, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'notrt' then phNotrt = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTrait private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTrait.
    run updateTrait.
    run createTrait.
end procedure.

procedure setTrait:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTrait.
    ghttTrait = phttTrait.
    run crudTrait.
    delete object phttTrait.
end procedure.

procedure readTrait:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table trait 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNotrt as integer    no-undo.
    define input parameter table-handle phttTrait.
    define variable vhttBuffer as handle no-undo.
    define buffer trait for trait.

    vhttBuffer = phttTrait:default-buffer-handle.
    for first trait no-lock
        where trait.notrt = piNotrt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trait:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTrait no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTrait:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table trait 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTrait.
    define variable vhttBuffer as handle  no-undo.
    define buffer trait for trait.

    vhttBuffer = phttTrait:default-buffer-handle.
    for each trait no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trait:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTrait no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTrait private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNotrt    as handle  no-undo.
    define buffer trait for trait.

    create query vhttquery.
    vhttBuffer = ghttTrait:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTrait:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNotrt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first trait exclusive-lock
                where rowid(trait) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer trait:handle, 'notrt: ', substitute('&1', vhNotrt:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer trait:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTrait private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer trait for trait.

    create query vhttquery.
    vhttBuffer = ghttTrait:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTrait:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create trait.
            if not outils:copyValidField(buffer trait:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTrait private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNotrt    as handle  no-undo.
    define buffer trait for trait.

    create query vhttquery.
    vhttBuffer = ghttTrait:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTrait:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNotrt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first trait exclusive-lock
                where rowid(Trait) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer trait:handle, 'notrt: ', substitute('&1', vhNotrt:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete trait no-error.
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

