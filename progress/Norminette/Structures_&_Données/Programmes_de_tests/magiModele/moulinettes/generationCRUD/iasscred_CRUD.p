/*------------------------------------------------------------------------
File        : iasscred_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iasscred
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iasscred.i}
{application/include/error.i}
define variable ghttiasscred as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phCli-cle as handle, output phAsscred-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/cli-cle/asscred-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'cli-cle' then phCli-cle = phBuffer:buffer-field(vi).
            when 'asscred-cd' then phAsscred-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIasscred private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIasscred.
    run updateIasscred.
    run createIasscred.
end procedure.

procedure setIasscred:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIasscred.
    ghttIasscred = phttIasscred.
    run crudIasscred.
    delete object phttIasscred.
end procedure.

procedure readIasscred:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iasscred Assurance credit pour un client
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter pcCli-cle    as character  no-undo.
    define input parameter piAsscred-cd as integer    no-undo.
    define input parameter table-handle phttIasscred.
    define variable vhttBuffer as handle no-undo.
    define buffer iasscred for iasscred.

    vhttBuffer = phttIasscred:default-buffer-handle.
    for first iasscred no-lock
        where iasscred.soc-cd = piSoc-cd
          and iasscred.cli-cle = pcCli-cle
          and iasscred.asscred-cd = piAsscred-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iasscred:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIasscred no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIasscred:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iasscred Assurance credit pour un client
    Notes  : service externe. Critère pcCli-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter pcCli-cle    as character  no-undo.
    define input parameter table-handle phttIasscred.
    define variable vhttBuffer as handle  no-undo.
    define buffer iasscred for iasscred.

    vhttBuffer = phttIasscred:default-buffer-handle.
    if pcCli-cle = ?
    then for each iasscred no-lock
        where iasscred.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iasscred:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iasscred no-lock
        where iasscred.soc-cd = piSoc-cd
          and iasscred.cli-cle = pcCli-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iasscred:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIasscred no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIasscred private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhCli-cle    as handle  no-undo.
    define variable vhAsscred-cd    as handle  no-undo.
    define buffer iasscred for iasscred.

    create query vhttquery.
    vhttBuffer = ghttIasscred:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIasscred:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhCli-cle, output vhAsscred-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iasscred exclusive-lock
                where rowid(iasscred) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iasscred:handle, 'soc-cd/cli-cle/asscred-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhCli-cle:buffer-value(), vhAsscred-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iasscred:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIasscred private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iasscred for iasscred.

    create query vhttquery.
    vhttBuffer = ghttIasscred:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIasscred:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iasscred.
            if not outils:copyValidField(buffer iasscred:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIasscred private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhCli-cle    as handle  no-undo.
    define variable vhAsscred-cd    as handle  no-undo.
    define buffer iasscred for iasscred.

    create query vhttquery.
    vhttBuffer = ghttIasscred:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIasscred:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhCli-cle, output vhAsscred-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iasscred exclusive-lock
                where rowid(Iasscred) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iasscred:handle, 'soc-cd/cli-cle/asscred-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhCli-cle:buffer-value(), vhAsscred-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iasscred no-error.
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

