/*------------------------------------------------------------------------
File        : iaction_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iaction
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttiaction as handle no-undo.     // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phDacrea as handle, output phIhcrea as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur dacrea/ihcrea, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'dacrea' then phDacrea = phBuffer:buffer-field(vi).
            when 'ihcrea' then phIhcrea = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIaction private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIaction.
    run updateIaction.
    run createIaction.
end procedure.

procedure setIaction:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIaction.
    ghttIaction = phttIaction.
    run crudIaction.
    delete object phttIaction.
end procedure.

procedure readIaction:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iaction Table des actions utilisateurs
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pdaDacrea as date       no-undo.
    define input parameter piIhcrea as integer    no-undo.
    define input parameter table-handle phttIaction.
    define variable vhttBuffer as handle no-undo.
    define buffer iaction for iaction.

    vhttBuffer = phttIaction:default-buffer-handle.
    for first iaction no-lock
        where iaction.dacrea = pdaDacrea
          and iaction.ihcrea = piIhcrea:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iaction:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIaction no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIaction:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iaction Table des actions utilisateurs
    Notes  : service externe. Critère pdaDacrea = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pdaDacrea as date       no-undo.
    define input parameter table-handle phttIaction.
    define variable vhttBuffer as handle  no-undo.
    define buffer iaction for iaction.

    vhttBuffer = phttIaction:default-buffer-handle.
    if pdaDacrea = ?
    then for each iaction no-lock
        where iaction.dacrea = pdaDacrea:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iaction:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iaction no-lock
        where iaction.dacrea = pdaDacrea:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iaction:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIaction no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIaction private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhDacrea    as handle  no-undo.
    define variable vhIhcrea    as handle  no-undo.
    define buffer iaction for iaction.

    create query vhttquery.
    vhttBuffer = ghttIaction:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIaction:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhDacrea, output vhIhcrea).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iaction exclusive-lock
                where rowid(iaction) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iaction:handle, 'dacrea/ihcrea: ', substitute('&1/&2', vhDacrea:buffer-value(), vhIhcrea:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iaction:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIaction private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer iaction for iaction.

    create query vhttquery.
    vhttBuffer = ghttIaction:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIaction:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iaction.
            if not outils:copyValidField(buffer iaction:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIaction private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhDacrea    as handle  no-undo.
    define variable vhIhcrea    as handle  no-undo.
    define buffer iaction for iaction.

    create query vhttquery.
    vhttBuffer = ghttIaction:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIaction:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhDacrea, output vhIhcrea).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iaction exclusive-lock
                where rowid(Iaction) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iaction:handle, 'dacrea/ihcrea: ', substitute('&1/&2', vhDacrea:buffer-value(), vhIhcrea:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iaction no-error.
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
