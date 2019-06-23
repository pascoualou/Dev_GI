/*------------------------------------------------------------------------
File        : menuweb_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table menuweb
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/menuweb.i}
{application/include/error.i}
define variable ghttmenuweb as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phIdmenu as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur IdMenu, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'IdMenu' then phIdmenu = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudMenuweb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteMenuweb.
    run updateMenuweb.
    run createMenuweb.
end procedure.

procedure setMenuweb:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttMenuweb.
    ghttMenuweb = phttMenuweb.
    run crudMenuweb.
    delete object phttMenuweb.
end procedure.

procedure readMenuweb:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table menuweb 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piIdmenu as int64      no-undo.
    define input parameter table-handle phttMenuweb.
    define variable vhttBuffer as handle no-undo.
    define buffer menuweb for menuweb.

    vhttBuffer = phttMenuweb:default-buffer-handle.
    for first menuweb no-lock
        where menuweb.IdMenu = piIdmenu:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer menuweb:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMenuweb no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getMenuweb:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table menuweb 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttMenuweb.
    define variable vhttBuffer as handle  no-undo.
    define buffer menuweb for menuweb.

    vhttBuffer = phttMenuweb:default-buffer-handle.
    for each menuweb no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer menuweb:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMenuweb no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateMenuweb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhIdmenu    as handle  no-undo.
    define buffer menuweb for menuweb.

    create query vhttquery.
    vhttBuffer = ghttMenuweb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttMenuweb:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhIdmenu).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first menuweb exclusive-lock
                where rowid(menuweb) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer menuweb:handle, 'IdMenu: ', substitute('&1', vhIdmenu:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer menuweb:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createMenuweb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer menuweb for menuweb.

    create query vhttquery.
    vhttBuffer = ghttMenuweb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttMenuweb:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create menuweb.
            if not outils:copyValidField(buffer menuweb:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteMenuweb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhIdmenu    as handle  no-undo.
    define buffer menuweb for menuweb.

    create query vhttquery.
    vhttBuffer = ghttMenuweb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttMenuweb:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhIdmenu).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first menuweb exclusive-lock
                where rowid(Menuweb) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer menuweb:handle, 'IdMenu: ', substitute('&1', vhIdmenu:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete menuweb no-error.
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

