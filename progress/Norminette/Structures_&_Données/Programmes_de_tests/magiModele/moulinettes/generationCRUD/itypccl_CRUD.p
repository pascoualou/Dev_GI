/*------------------------------------------------------------------------
File        : itypccl_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table itypccl
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/itypccl.i}
{application/include/error.i}
define variable ghttitypccl as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTypccl-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur typccl-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'typccl-cd' then phTypccl-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudItypccl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteItypccl.
    run updateItypccl.
    run createItypccl.
end procedure.

procedure setItypccl:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttItypccl.
    ghttItypccl = phttItypccl.
    run crudItypccl.
    delete object phttItypccl.
end procedure.

procedure readItypccl:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table itypccl Fichier Type de Commande Client
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piTypccl-cd as integer    no-undo.
    define input parameter table-handle phttItypccl.
    define variable vhttBuffer as handle no-undo.
    define buffer itypccl for itypccl.

    vhttBuffer = phttItypccl:default-buffer-handle.
    for first itypccl no-lock
        where itypccl.typccl-cd = piTypccl-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itypccl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttItypccl no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getItypccl:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table itypccl Fichier Type de Commande Client
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttItypccl.
    define variable vhttBuffer as handle  no-undo.
    define buffer itypccl for itypccl.

    vhttBuffer = phttItypccl:default-buffer-handle.
    for each itypccl no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itypccl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttItypccl no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateItypccl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTypccl-cd    as handle  no-undo.
    define buffer itypccl for itypccl.

    create query vhttquery.
    vhttBuffer = ghttItypccl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttItypccl:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTypccl-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first itypccl exclusive-lock
                where rowid(itypccl) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer itypccl:handle, 'typccl-cd: ', substitute('&1', vhTypccl-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer itypccl:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createItypccl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer itypccl for itypccl.

    create query vhttquery.
    vhttBuffer = ghttItypccl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttItypccl:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create itypccl.
            if not outils:copyValidField(buffer itypccl:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteItypccl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTypccl-cd    as handle  no-undo.
    define buffer itypccl for itypccl.

    create query vhttquery.
    vhttBuffer = ghttItypccl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttItypccl:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTypccl-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first itypccl exclusive-lock
                where rowid(Itypccl) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer itypccl:handle, 'typccl-cd: ', substitute('&1', vhTypccl-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete itypccl no-error.
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

