/*------------------------------------------------------------------------
File        : ibqics_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ibqics
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ibqics.i}
{application/include/error.i}
define variable ghttibqics as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phCdics as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/cdics, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'cdics' then phCdics = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIbqics private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIbqics.
    run updateIbqics.
    run createIbqics.
end procedure.

procedure setIbqics:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIbqics.
    ghttIbqics = phttIbqics.
    run crudIbqics.
    delete object phttIbqics.
end procedure.

procedure readIbqics:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ibqics Identifiant Creancier SEPA
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd as integer    no-undo.
    define input parameter pcCdics  as character  no-undo.
    define input parameter table-handle phttIbqics.
    define variable vhttBuffer as handle no-undo.
    define buffer ibqics for ibqics.

    vhttBuffer = phttIbqics:default-buffer-handle.
    for first ibqics no-lock
        where ibqics.soc-cd = piSoc-cd
          and ibqics.cdics = pcCdics:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ibqics:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIbqics no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIbqics:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ibqics Identifiant Creancier SEPA
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd as integer    no-undo.
    define input parameter table-handle phttIbqics.
    define variable vhttBuffer as handle  no-undo.
    define buffer ibqics for ibqics.

    vhttBuffer = phttIbqics:default-buffer-handle.
    if piSoc-cd = ?
    then for each ibqics no-lock
        where ibqics.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ibqics:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ibqics no-lock
        where ibqics.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ibqics:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIbqics no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIbqics private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhCdics    as handle  no-undo.
    define buffer ibqics for ibqics.

    create query vhttquery.
    vhttBuffer = ghttIbqics:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIbqics:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhCdics).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ibqics exclusive-lock
                where rowid(ibqics) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ibqics:handle, 'soc-cd/cdics: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhCdics:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ibqics:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIbqics private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ibqics for ibqics.

    create query vhttquery.
    vhttBuffer = ghttIbqics:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIbqics:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ibqics.
            if not outils:copyValidField(buffer ibqics:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIbqics private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhCdics    as handle  no-undo.
    define buffer ibqics for ibqics.

    create query vhttquery.
    vhttBuffer = ghttIbqics:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIbqics:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhCdics).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ibqics exclusive-lock
                where rowid(Ibqics) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ibqics:handle, 'soc-cd/cdics: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhCdics:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ibqics no-error.
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

