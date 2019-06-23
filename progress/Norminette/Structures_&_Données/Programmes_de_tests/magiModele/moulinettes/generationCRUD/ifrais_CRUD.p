/*------------------------------------------------------------------------
File        : ifrais_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifrais
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifrais.i}
{application/include/error.i}
define variable ghttifrais as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phFrais-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/frais-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'frais-cd' then phFrais-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfrais private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfrais.
    run updateIfrais.
    run createIfrais.
end procedure.

procedure setIfrais:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfrais.
    ghttIfrais = phttIfrais.
    run crudIfrais.
    delete object phttIfrais.
end procedure.

procedure readIfrais:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifrais Liste des frais fixes.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piFrais-cd as integer    no-undo.
    define input parameter table-handle phttIfrais.
    define variable vhttBuffer as handle no-undo.
    define buffer ifrais for ifrais.

    vhttBuffer = phttIfrais:default-buffer-handle.
    for first ifrais no-lock
        where ifrais.soc-cd = piSoc-cd
          and ifrais.frais-cd = piFrais-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifrais:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfrais no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfrais:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifrais Liste des frais fixes.
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter table-handle phttIfrais.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifrais for ifrais.

    vhttBuffer = phttIfrais:default-buffer-handle.
    if piSoc-cd = ?
    then for each ifrais no-lock
        where ifrais.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifrais:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifrais no-lock
        where ifrais.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifrais:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfrais no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfrais private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhFrais-cd    as handle  no-undo.
    define buffer ifrais for ifrais.

    create query vhttquery.
    vhttBuffer = ghttIfrais:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfrais:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhFrais-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifrais exclusive-lock
                where rowid(ifrais) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifrais:handle, 'soc-cd/frais-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhFrais-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifrais:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfrais private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifrais for ifrais.

    create query vhttquery.
    vhttBuffer = ghttIfrais:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfrais:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifrais.
            if not outils:copyValidField(buffer ifrais:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfrais private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhFrais-cd    as handle  no-undo.
    define buffer ifrais for ifrais.

    create query vhttquery.
    vhttBuffer = ghttIfrais:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfrais:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhFrais-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifrais exclusive-lock
                where rowid(Ifrais) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifrais:handle, 'soc-cd/frais-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhFrais-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifrais no-error.
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

