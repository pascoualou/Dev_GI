/*------------------------------------------------------------------------
File        : ajqufl_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ajqufl
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ajqufl.i}
{application/include/error.i}
define variable ghttajqufl as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudAjqufl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAjqufl.
    run updateAjqufl.
    run createAjqufl.
end procedure.

procedure setAjqufl:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAjqufl.
    ghttAjqufl = phttAjqufl.
    run crudAjqufl.
    delete object phttAjqufl.
end procedure.

procedure readAjqufl:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ajqufl 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter pdaDacompta as date       no-undo.
    define input parameter piOrdre-cd as integer    no-undo.
    define input parameter table-handle phttAjqufl.
    define variable vhttBuffer as handle no-undo.
    define buffer ajqufl for ajqufl.

    vhttBuffer = phttAjqufl:default-buffer-handle.
    for first ajqufl no-lock
        where ajqufl.soc-cd = piSoc-cd
          and ajqufl.dacompta = pdaDacompta
          and ajqufl.ordre-cd = piOrdre-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ajqufl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAjqufl no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAjqufl:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ajqufl 
    Notes  : service externe. Critère pdaDacompta = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter pdaDacompta as date       no-undo.
    define input parameter table-handle phttAjqufl.
    define variable vhttBuffer as handle  no-undo.
    define buffer ajqufl for ajqufl.

    vhttBuffer = phttAjqufl:default-buffer-handle.
    if pdaDacompta = ?
    then for each ajqufl no-lock
        where ajqufl.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ajqufl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ajqufl no-lock
        where ajqufl.soc-cd = piSoc-cd
          and ajqufl.dacompta = pdaDacompta:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ajqufl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAjqufl no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAjqufl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhDacompta    as handle  no-undo.
    define variable vhOrdre-cd    as handle  no-undo.
    define buffer ajqufl for ajqufl.

    create query vhttquery.
    vhttBuffer = ghttAjqufl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAjqufl:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhDacompta, output vhOrdre-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ajqufl exclusive-lock
                where rowid(ajqufl) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ajqufl:handle, 'soc-cd/dacompta/ordre-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhDacompta:buffer-value(), vhOrdre-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ajqufl:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAjqufl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ajqufl for ajqufl.

    create query vhttquery.
    vhttBuffer = ghttAjqufl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAjqufl:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ajqufl.
            if not outils:copyValidField(buffer ajqufl:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAjqufl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhDacompta    as handle  no-undo.
    define variable vhOrdre-cd    as handle  no-undo.
    define buffer ajqufl for ajqufl.

    create query vhttquery.
    vhttBuffer = ghttAjqufl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAjqufl:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhDacompta, output vhOrdre-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ajqufl exclusive-lock
                where rowid(Ajqufl) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ajqufl:handle, 'soc-cd/dacompta/ordre-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhDacompta:buffer-value(), vhOrdre-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ajqufl no-error.
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

