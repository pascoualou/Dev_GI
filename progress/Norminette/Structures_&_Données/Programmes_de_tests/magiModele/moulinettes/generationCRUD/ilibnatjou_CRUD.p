/*------------------------------------------------------------------------
File        : ilibnatjou_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ilibnatjou
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ilibnatjou.i}
{application/include/error.i}
define variable ghttilibnatjou as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phNatjou-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/natjou-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'natjou-cd' then phNatjou-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIlibnatjou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIlibnatjou.
    run updateIlibnatjou.
    run createIlibnatjou.
end procedure.

procedure setIlibnatjou:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIlibnatjou.
    ghttIlibnatjou = phttIlibnatjou.
    run crudIlibnatjou.
    delete object phttIlibnatjou.
end procedure.

procedure readIlibnatjou:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ilibnatjou Libelle nature journal.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piNatjou-cd as integer    no-undo.
    define input parameter table-handle phttIlibnatjou.
    define variable vhttBuffer as handle no-undo.
    define buffer ilibnatjou for ilibnatjou.

    vhttBuffer = phttIlibnatjou:default-buffer-handle.
    for first ilibnatjou no-lock
        where ilibnatjou.soc-cd = piSoc-cd
          and ilibnatjou.natjou-cd = piNatjou-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibnatjou:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibnatjou no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIlibnatjou:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ilibnatjou Libelle nature journal.
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter table-handle phttIlibnatjou.
    define variable vhttBuffer as handle  no-undo.
    define buffer ilibnatjou for ilibnatjou.

    vhttBuffer = phttIlibnatjou:default-buffer-handle.
    if piSoc-cd = ?
    then for each ilibnatjou no-lock
        where ilibnatjou.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibnatjou:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ilibnatjou no-lock
        where ilibnatjou.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibnatjou:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibnatjou no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIlibnatjou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhNatjou-cd    as handle  no-undo.
    define buffer ilibnatjou for ilibnatjou.

    create query vhttquery.
    vhttBuffer = ghttIlibnatjou:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIlibnatjou:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhNatjou-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibnatjou exclusive-lock
                where rowid(ilibnatjou) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibnatjou:handle, 'soc-cd/natjou-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhNatjou-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ilibnatjou:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIlibnatjou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ilibnatjou for ilibnatjou.

    create query vhttquery.
    vhttBuffer = ghttIlibnatjou:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIlibnatjou:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ilibnatjou.
            if not outils:copyValidField(buffer ilibnatjou:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIlibnatjou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhNatjou-cd    as handle  no-undo.
    define buffer ilibnatjou for ilibnatjou.

    create query vhttquery.
    vhttBuffer = ghttIlibnatjou:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIlibnatjou:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhNatjou-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibnatjou exclusive-lock
                where rowid(Ilibnatjou) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibnatjou:handle, 'soc-cd/natjou-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhNatjou-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ilibnatjou no-error.
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

