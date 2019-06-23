/*------------------------------------------------------------------------
File        : usage_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table usage
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/usage.i}
{application/include/error.i}
define variable ghttusage as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNtapp as handle, output phCdusa as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur ntapp/cdusa, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'ntapp' then phNtapp = phBuffer:buffer-field(vi).
            when 'cdusa' then phCdusa = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudUsage private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteUsage.
    run updateUsage.
    run createUsage.
end procedure.

procedure setUsage:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttUsage.
    ghttUsage = phttUsage.
    run crudUsage.
    delete object phttUsage.
end procedure.

procedure readUsage:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table usage 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcNtapp as character  no-undo.
    define input parameter pcCdusa as character  no-undo.
    define input parameter table-handle phttUsage.
    define variable vhttBuffer as handle no-undo.
    define buffer usage for usage.

    vhttBuffer = phttUsage:default-buffer-handle.
    for first usage no-lock
        where usage.ntapp = pcNtapp
          and usage.cdusa = pcCdusa:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer usage:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttUsage no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getUsage:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table usage 
    Notes  : service externe. Critère pcNtapp = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcNtapp as character  no-undo.
    define input parameter table-handle phttUsage.
    define variable vhttBuffer as handle  no-undo.
    define buffer usage for usage.

    vhttBuffer = phttUsage:default-buffer-handle.
    if pcNtapp = ?
    then for each usage no-lock
        where usage.ntapp = pcNtapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer usage:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each usage no-lock
        where usage.ntapp = pcNtapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer usage:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttUsage no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateUsage private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNtapp    as handle  no-undo.
    define variable vhCdusa    as handle  no-undo.
    define buffer usage for usage.

    create query vhttquery.
    vhttBuffer = ghttUsage:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttUsage:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNtapp, output vhCdusa).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first usage exclusive-lock
                where rowid(usage) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer usage:handle, 'ntapp/cdusa: ', substitute('&1/&2', vhNtapp:buffer-value(), vhCdusa:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer usage:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createUsage private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer usage for usage.

    create query vhttquery.
    vhttBuffer = ghttUsage:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttUsage:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create usage.
            if not outils:copyValidField(buffer usage:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteUsage private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNtapp    as handle  no-undo.
    define variable vhCdusa    as handle  no-undo.
    define buffer usage for usage.

    create query vhttquery.
    vhttBuffer = ghttUsage:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttUsage:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNtapp, output vhCdusa).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first usage exclusive-lock
                where rowid(Usage) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer usage:handle, 'ntapp/cdusa: ', substitute('&1/&2', vhNtapp:buffer-value(), vhCdusa:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete usage no-error.
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

