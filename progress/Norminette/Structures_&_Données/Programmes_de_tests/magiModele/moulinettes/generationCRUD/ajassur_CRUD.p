/*------------------------------------------------------------------------
File        : ajassur_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ajassur
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ajassur.i}
{application/include/error.i}
define variable ghttajassur as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudAjassur private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAjassur.
    run updateAjassur.
    run createAjassur.
end procedure.

procedure setAjassur:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAjassur.
    ghttAjassur = phttAjassur.
    run crudAjassur.
    delete object phttAjassur.
end procedure.

procedure readAjassur:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ajassur 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter pdaDacompta as date       no-undo.
    define input parameter piOrdre-cd as integer    no-undo.
    define input parameter table-handle phttAjassur.
    define variable vhttBuffer as handle no-undo.
    define buffer ajassur for ajassur.

    vhttBuffer = phttAjassur:default-buffer-handle.
    for first ajassur no-lock
        where ajassur.soc-cd = piSoc-cd
          and ajassur.dacompta = pdaDacompta
          and ajassur.ordre-cd = piOrdre-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ajassur:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAjassur no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAjassur:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ajassur 
    Notes  : service externe. Critère pdaDacompta = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter pdaDacompta as date       no-undo.
    define input parameter table-handle phttAjassur.
    define variable vhttBuffer as handle  no-undo.
    define buffer ajassur for ajassur.

    vhttBuffer = phttAjassur:default-buffer-handle.
    if pdaDacompta = ?
    then for each ajassur no-lock
        where ajassur.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ajassur:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ajassur no-lock
        where ajassur.soc-cd = piSoc-cd
          and ajassur.dacompta = pdaDacompta:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ajassur:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAjassur no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAjassur private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhDacompta    as handle  no-undo.
    define variable vhOrdre-cd    as handle  no-undo.
    define buffer ajassur for ajassur.

    create query vhttquery.
    vhttBuffer = ghttAjassur:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAjassur:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhDacompta, output vhOrdre-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ajassur exclusive-lock
                where rowid(ajassur) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ajassur:handle, 'soc-cd/dacompta/ordre-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhDacompta:buffer-value(), vhOrdre-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ajassur:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAjassur private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ajassur for ajassur.

    create query vhttquery.
    vhttBuffer = ghttAjassur:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAjassur:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ajassur.
            if not outils:copyValidField(buffer ajassur:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAjassur private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhDacompta    as handle  no-undo.
    define variable vhOrdre-cd    as handle  no-undo.
    define buffer ajassur for ajassur.

    create query vhttquery.
    vhttBuffer = ghttAjassur:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAjassur:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhDacompta, output vhOrdre-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ajassur exclusive-lock
                where rowid(Ajassur) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ajassur:handle, 'soc-cd/dacompta/ordre-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhDacompta:buffer-value(), vhOrdre-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ajassur no-error.
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

