/*------------------------------------------------------------------------
File        : apointe_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table apointe
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/apointe.i}
{application/include/error.i}
define variable ghttapointe as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phDapointe as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/dapointe, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'dapointe' then phDapointe = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudApointe private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteApointe.
    run updateApointe.
    run createApointe.
end procedure.

procedure setApointe:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttApointe.
    ghttApointe = phttApointe.
    run crudApointe.
    delete object phttApointe.
end procedure.

procedure readApointe:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table apointe 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter pdaDapointe as date       no-undo.
    define input parameter table-handle phttApointe.
    define variable vhttBuffer as handle no-undo.
    define buffer apointe for apointe.

    vhttBuffer = phttApointe:default-buffer-handle.
    for first apointe no-lock
        where apointe.soc-cd = piSoc-cd
          and apointe.dapointe = pdaDapointe:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer apointe:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttApointe no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getApointe:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table apointe 
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter table-handle phttApointe.
    define variable vhttBuffer as handle  no-undo.
    define buffer apointe for apointe.

    vhttBuffer = phttApointe:default-buffer-handle.
    if piSoc-cd = ?
    then for each apointe no-lock
        where apointe.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer apointe:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each apointe no-lock
        where apointe.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer apointe:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttApointe no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateApointe private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhDapointe    as handle  no-undo.
    define buffer apointe for apointe.

    create query vhttquery.
    vhttBuffer = ghttApointe:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttApointe:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhDapointe).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first apointe exclusive-lock
                where rowid(apointe) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer apointe:handle, 'soc-cd/dapointe: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhDapointe:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer apointe:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createApointe private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer apointe for apointe.

    create query vhttquery.
    vhttBuffer = ghttApointe:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttApointe:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create apointe.
            if not outils:copyValidField(buffer apointe:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteApointe private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhDapointe    as handle  no-undo.
    define buffer apointe for apointe.

    create query vhttquery.
    vhttBuffer = ghttApointe:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttApointe:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhDapointe).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first apointe exclusive-lock
                where rowid(Apointe) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer apointe:handle, 'soc-cd/dapointe: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhDapointe:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete apointe no-error.
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

