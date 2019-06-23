/*------------------------------------------------------------------------
File        : ajquit_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ajquit
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ajquit.i}
{application/include/error.i}
define variable ghttajquit as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phDacompta as handle, output phOrdre-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/dacompta/ordre-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'dacompta' then phDacompta = phBuffer:buffer-field(vi).
            when 'ordre-cd' then phOrdre-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAjquit private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAjquit.
    run updateAjquit.
    run createAjquit.
end procedure.

procedure setAjquit:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAjquit.
    ghttAjquit = phttAjquit.
    run crudAjquit.
    delete object phttAjquit.
end procedure.

procedure readAjquit:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ajquit 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter pdaDacompta as date       no-undo.
    define input parameter piOrdre-cd as integer    no-undo.
    define input parameter table-handle phttAjquit.
    define variable vhttBuffer as handle no-undo.
    define buffer ajquit for ajquit.

    vhttBuffer = phttAjquit:default-buffer-handle.
    for first ajquit no-lock
        where ajquit.soc-cd = piSoc-cd
          and ajquit.dacompta = pdaDacompta
          and ajquit.ordre-cd = piOrdre-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ajquit:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAjquit no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAjquit:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ajquit 
    Notes  : service externe. Critère pdaDacompta = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter pdaDacompta as date       no-undo.
    define input parameter table-handle phttAjquit.
    define variable vhttBuffer as handle  no-undo.
    define buffer ajquit for ajquit.

    vhttBuffer = phttAjquit:default-buffer-handle.
    if pdaDacompta = ?
    then for each ajquit no-lock
        where ajquit.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ajquit:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ajquit no-lock
        where ajquit.soc-cd = piSoc-cd
          and ajquit.dacompta = pdaDacompta:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ajquit:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAjquit no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAjquit private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhDacompta    as handle  no-undo.
    define variable vhOrdre-cd    as handle  no-undo.
    define buffer ajquit for ajquit.

    create query vhttquery.
    vhttBuffer = ghttAjquit:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAjquit:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhDacompta, output vhOrdre-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ajquit exclusive-lock
                where rowid(ajquit) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ajquit:handle, 'soc-cd/dacompta/ordre-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhDacompta:buffer-value(), vhOrdre-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ajquit:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAjquit private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ajquit for ajquit.

    create query vhttquery.
    vhttBuffer = ghttAjquit:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAjquit:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ajquit.
            if not outils:copyValidField(buffer ajquit:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAjquit private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhDacompta    as handle  no-undo.
    define variable vhOrdre-cd    as handle  no-undo.
    define buffer ajquit for ajquit.

    create query vhttquery.
    vhttBuffer = ghttAjquit:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAjquit:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhDacompta, output vhOrdre-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ajquit exclusive-lock
                where rowid(Ajquit) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ajquit:handle, 'soc-cd/dacompta/ordre-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhDacompta:buffer-value(), vhOrdre-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ajquit no-error.
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

