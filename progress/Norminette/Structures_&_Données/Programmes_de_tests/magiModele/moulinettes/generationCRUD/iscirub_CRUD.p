/*------------------------------------------------------------------------
File        : iscirub_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iscirub
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iscirub.i}
{application/include/error.i}
define variable ghttiscirub as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phType-rub as handle, output phRub-cd as handle, output phSsrub-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/type-rub/rub-cd/ssrub-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'type-rub' then phType-rub = phBuffer:buffer-field(vi).
            when 'rub-cd' then phRub-cd = phBuffer:buffer-field(vi).
            when 'ssrub-cd' then phSsrub-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIscirub private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIscirub.
    run updateIscirub.
    run createIscirub.
end procedure.

procedure setIscirub:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIscirub.
    ghttIscirub = phttIscirub.
    run crudIscirub.
    delete object phttIscirub.
end procedure.

procedure readIscirub:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iscirub Table de correspondances rubriques SCI
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piType-rub as integer    no-undo.
    define input parameter pcRub-cd   as character  no-undo.
    define input parameter pcSsrub-cd as character  no-undo.
    define input parameter table-handle phttIscirub.
    define variable vhttBuffer as handle no-undo.
    define buffer iscirub for iscirub.

    vhttBuffer = phttIscirub:default-buffer-handle.
    for first iscirub no-lock
        where iscirub.soc-cd = piSoc-cd
          and iscirub.type-rub = piType-rub
          and iscirub.rub-cd = pcRub-cd
          and iscirub.ssrub-cd = pcSsrub-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iscirub:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIscirub no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIscirub:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iscirub Table de correspondances rubriques SCI
    Notes  : service externe. Critère pcRub-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piType-rub as integer    no-undo.
    define input parameter pcRub-cd   as character  no-undo.
    define input parameter table-handle phttIscirub.
    define variable vhttBuffer as handle  no-undo.
    define buffer iscirub for iscirub.

    vhttBuffer = phttIscirub:default-buffer-handle.
    if pcRub-cd = ?
    then for each iscirub no-lock
        where iscirub.soc-cd = piSoc-cd
          and iscirub.type-rub = piType-rub:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iscirub:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iscirub no-lock
        where iscirub.soc-cd = piSoc-cd
          and iscirub.type-rub = piType-rub
          and iscirub.rub-cd = pcRub-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iscirub:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIscirub no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIscirub private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhType-rub    as handle  no-undo.
    define variable vhRub-cd    as handle  no-undo.
    define variable vhSsrub-cd    as handle  no-undo.
    define buffer iscirub for iscirub.

    create query vhttquery.
    vhttBuffer = ghttIscirub:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIscirub:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhType-rub, output vhRub-cd, output vhSsrub-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iscirub exclusive-lock
                where rowid(iscirub) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iscirub:handle, 'soc-cd/type-rub/rub-cd/ssrub-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhType-rub:buffer-value(), vhRub-cd:buffer-value(), vhSsrub-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iscirub:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIscirub private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iscirub for iscirub.

    create query vhttquery.
    vhttBuffer = ghttIscirub:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIscirub:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iscirub.
            if not outils:copyValidField(buffer iscirub:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIscirub private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhType-rub    as handle  no-undo.
    define variable vhRub-cd    as handle  no-undo.
    define variable vhSsrub-cd    as handle  no-undo.
    define buffer iscirub for iscirub.

    create query vhttquery.
    vhttBuffer = ghttIscirub:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIscirub:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhType-rub, output vhRub-cd, output vhSsrub-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iscirub exclusive-lock
                where rowid(Iscirub) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iscirub:handle, 'soc-cd/type-rub/rub-cd/ssrub-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhType-rub:buffer-value(), vhRub-cd:buffer-value(), vhSsrub-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iscirub no-error.
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

