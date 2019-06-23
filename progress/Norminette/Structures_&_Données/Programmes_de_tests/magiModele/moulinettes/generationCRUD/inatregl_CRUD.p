/*------------------------------------------------------------------------
File        : inatregl_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table inatregl
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/inatregl.i}
{application/include/error.i}
define variable ghttinatregl as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phNatregl-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/natregl-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'natregl-cd' then phNatregl-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudInatregl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteInatregl.
    run updateInatregl.
    run createInatregl.
end procedure.

procedure setInatregl:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttInatregl.
    ghttInatregl = phttInatregl.
    run crudInatregl.
    delete object phttInatregl.
end procedure.

procedure readInatregl:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table inatregl Nature de Reglement
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piNatregl-cd as integer    no-undo.
    define input parameter table-handle phttInatregl.
    define variable vhttBuffer as handle no-undo.
    define buffer inatregl for inatregl.

    vhttBuffer = phttInatregl:default-buffer-handle.
    for first inatregl no-lock
        where inatregl.soc-cd = piSoc-cd
          and inatregl.natregl-cd = piNatregl-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer inatregl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttInatregl no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getInatregl:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table inatregl Nature de Reglement
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter table-handle phttInatregl.
    define variable vhttBuffer as handle  no-undo.
    define buffer inatregl for inatregl.

    vhttBuffer = phttInatregl:default-buffer-handle.
    if piSoc-cd = ?
    then for each inatregl no-lock
        where inatregl.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer inatregl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each inatregl no-lock
        where inatregl.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer inatregl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttInatregl no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateInatregl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhNatregl-cd    as handle  no-undo.
    define buffer inatregl for inatregl.

    create query vhttquery.
    vhttBuffer = ghttInatregl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttInatregl:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhNatregl-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first inatregl exclusive-lock
                where rowid(inatregl) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer inatregl:handle, 'soc-cd/natregl-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhNatregl-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer inatregl:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createInatregl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer inatregl for inatregl.

    create query vhttquery.
    vhttBuffer = ghttInatregl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttInatregl:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create inatregl.
            if not outils:copyValidField(buffer inatregl:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteInatregl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhNatregl-cd    as handle  no-undo.
    define buffer inatregl for inatregl.

    create query vhttquery.
    vhttBuffer = ghttInatregl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttInatregl:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhNatregl-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first inatregl exclusive-lock
                where rowid(Inatregl) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer inatregl:handle, 'soc-cd/natregl-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhNatregl-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete inatregl no-error.
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

