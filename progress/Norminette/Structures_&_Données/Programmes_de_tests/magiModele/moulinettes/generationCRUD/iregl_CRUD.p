/*------------------------------------------------------------------------
File        : iregl_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iregl
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iregl.i}
{application/include/error.i}
define variable ghttiregl as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phRegl-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/regl-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'regl-cd' then phRegl-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIregl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIregl.
    run updateIregl.
    run createIregl.
end procedure.

procedure setIregl:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIregl.
    ghttIregl = phttIregl.
    run crudIregl.
    delete object phttIregl.
end procedure.

procedure readIregl:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iregl Fichier descriptif des reglements.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piRegl-cd as integer    no-undo.
    define input parameter table-handle phttIregl.
    define variable vhttBuffer as handle no-undo.
    define buffer iregl for iregl.

    vhttBuffer = phttIregl:default-buffer-handle.
    for first iregl no-lock
        where iregl.soc-cd = piSoc-cd
          and iregl.regl-cd = piRegl-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iregl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIregl no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIregl:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iregl Fichier descriptif des reglements.
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter table-handle phttIregl.
    define variable vhttBuffer as handle  no-undo.
    define buffer iregl for iregl.

    vhttBuffer = phttIregl:default-buffer-handle.
    if piSoc-cd = ?
    then for each iregl no-lock
        where iregl.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iregl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iregl no-lock
        where iregl.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iregl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIregl no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIregl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhRegl-cd    as handle  no-undo.
    define buffer iregl for iregl.

    create query vhttquery.
    vhttBuffer = ghttIregl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIregl:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhRegl-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iregl exclusive-lock
                where rowid(iregl) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iregl:handle, 'soc-cd/regl-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhRegl-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iregl:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIregl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iregl for iregl.

    create query vhttquery.
    vhttBuffer = ghttIregl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIregl:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iregl.
            if not outils:copyValidField(buffer iregl:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIregl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhRegl-cd    as handle  no-undo.
    define buffer iregl for iregl.

    create query vhttquery.
    vhttBuffer = ghttIregl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIregl:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhRegl-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iregl exclusive-lock
                where rowid(Iregl) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iregl:handle, 'soc-cd/regl-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhRegl-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iregl no-error.
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

