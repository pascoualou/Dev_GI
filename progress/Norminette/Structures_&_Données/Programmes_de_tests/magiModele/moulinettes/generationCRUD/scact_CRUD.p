/*------------------------------------------------------------------------
File        : scact_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table scact
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/scact.i}
{application/include/error.i}
define variable ghttscact as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNosoc as handle, output phNoact as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nosoc/noact, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nosoc' then phNosoc = phBuffer:buffer-field(vi).
            when 'noact' then phNoact = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudScact private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteScact.
    run updateScact.
    run createScact.
end procedure.

procedure setScact:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttScact.
    ghttScact = phttScact.
    run crudScact.
    delete object phttScact.
end procedure.

procedure readScact:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table scact Liste des actionnaires de la société
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNosoc as integer    no-undo.
    define input parameter piNoact as integer    no-undo.
    define input parameter table-handle phttScact.
    define variable vhttBuffer as handle no-undo.
    define buffer scact for scact.

    vhttBuffer = phttScact:default-buffer-handle.
    for first scact no-lock
        where scact.nosoc = piNosoc
          and scact.noact = piNoact:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer scact:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttScact no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getScact:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table scact Liste des actionnaires de la société
    Notes  : service externe. Critère piNosoc = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNosoc as integer    no-undo.
    define input parameter table-handle phttScact.
    define variable vhttBuffer as handle  no-undo.
    define buffer scact for scact.

    vhttBuffer = phttScact:default-buffer-handle.
    if piNosoc = ?
    then for each scact no-lock
        where scact.nosoc = piNosoc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer scact:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each scact no-lock
        where scact.nosoc = piNosoc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer scact:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttScact no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateScact private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNosoc    as handle  no-undo.
    define variable vhNoact    as handle  no-undo.
    define buffer scact for scact.

    create query vhttquery.
    vhttBuffer = ghttScact:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttScact:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNosoc, output vhNoact).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first scact exclusive-lock
                where rowid(scact) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer scact:handle, 'nosoc/noact: ', substitute('&1/&2', vhNosoc:buffer-value(), vhNoact:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer scact:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createScact private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer scact for scact.

    create query vhttquery.
    vhttBuffer = ghttScact:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttScact:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create scact.
            if not outils:copyValidField(buffer scact:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteScact private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNosoc    as handle  no-undo.
    define variable vhNoact    as handle  no-undo.
    define buffer scact for scact.

    create query vhttquery.
    vhttBuffer = ghttScact:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttScact:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNosoc, output vhNoact).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first scact exclusive-lock
                where rowid(Scact) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer scact:handle, 'nosoc/noact: ', substitute('&1/&2', vhNosoc:buffer-value(), vhNoact:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete scact no-error.
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

