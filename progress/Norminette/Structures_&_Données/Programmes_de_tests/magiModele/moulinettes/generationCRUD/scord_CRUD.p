/*------------------------------------------------------------------------
File        : scord_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table scord
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/scord.i}
{application/include/error.i}
define variable ghttscord as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNosoc as handle, output phNoord as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nosoc/noord, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nosoc' then phNosoc = phBuffer:buffer-field(vi).
            when 'noord' then phNoord = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudScord private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteScord.
    run updateScord.
    run createScord.
end procedure.

procedure setScord:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttScord.
    ghttScord = phttScord.
    run crudScord.
    delete object phttScord.
end procedure.

procedure readScord:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table scord Compteur des numéros d'ordre par société
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNosoc as integer    no-undo.
    define input parameter piNoord as integer    no-undo.
    define input parameter table-handle phttScord.
    define variable vhttBuffer as handle no-undo.
    define buffer scord for scord.

    vhttBuffer = phttScord:default-buffer-handle.
    for first scord no-lock
        where scord.nosoc = piNosoc
          and scord.noord = piNoord:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer scord:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttScord no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getScord:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table scord Compteur des numéros d'ordre par société
    Notes  : service externe. Critère piNosoc = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNosoc as integer    no-undo.
    define input parameter table-handle phttScord.
    define variable vhttBuffer as handle  no-undo.
    define buffer scord for scord.

    vhttBuffer = phttScord:default-buffer-handle.
    if piNosoc = ?
    then for each scord no-lock
        where scord.nosoc = piNosoc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer scord:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each scord no-lock
        where scord.nosoc = piNosoc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer scord:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttScord no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateScord private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNosoc    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer scord for scord.

    create query vhttquery.
    vhttBuffer = ghttScord:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttScord:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNosoc, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first scord exclusive-lock
                where rowid(scord) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer scord:handle, 'nosoc/noord: ', substitute('&1/&2', vhNosoc:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer scord:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createScord private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer scord for scord.

    create query vhttquery.
    vhttBuffer = ghttScord:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttScord:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create scord.
            if not outils:copyValidField(buffer scord:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteScord private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNosoc    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer scord for scord.

    create query vhttquery.
    vhttBuffer = ghttScord:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttScord:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNosoc, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first scord exclusive-lock
                where rowid(Scord) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer scord:handle, 'nosoc/noord: ', substitute('&1/&2', vhNosoc:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete scord no-error.
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

