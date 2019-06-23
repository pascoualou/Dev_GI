/*------------------------------------------------------------------------
File        : apreln_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table apreln
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/apreln.i}
{application/include/error.i}
define variable ghttapreln as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phTp-trait as handle, output phEtab-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/tp-trait/etab-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'tp-trait' then phTp-trait = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudApreln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteApreln.
    run updateApreln.
    run createApreln.
end procedure.

procedure setApreln:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttApreln.
    ghttApreln = phttApreln.
    run crudApreln.
    delete object phttApreln.
end procedure.

procedure readApreln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table apreln 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piTp-trait as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter table-handle phttApreln.
    define variable vhttBuffer as handle no-undo.
    define buffer apreln for apreln.

    vhttBuffer = phttApreln:default-buffer-handle.
    for first apreln no-lock
        where apreln.soc-cd = piSoc-cd
          and apreln.tp-trait = piTp-trait
          and apreln.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer apreln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttApreln no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getApreln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table apreln 
    Notes  : service externe. Critère piTp-trait = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piTp-trait as integer    no-undo.
    define input parameter table-handle phttApreln.
    define variable vhttBuffer as handle  no-undo.
    define buffer apreln for apreln.

    vhttBuffer = phttApreln:default-buffer-handle.
    if piTp-trait = ?
    then for each apreln no-lock
        where apreln.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer apreln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each apreln no-lock
        where apreln.soc-cd = piSoc-cd
          and apreln.tp-trait = piTp-trait:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer apreln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttApreln no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateApreln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhTp-trait    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define buffer apreln for apreln.

    create query vhttquery.
    vhttBuffer = ghttApreln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttApreln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhTp-trait, output vhEtab-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first apreln exclusive-lock
                where rowid(apreln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer apreln:handle, 'soc-cd/tp-trait/etab-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhTp-trait:buffer-value(), vhEtab-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer apreln:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createApreln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer apreln for apreln.

    create query vhttquery.
    vhttBuffer = ghttApreln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttApreln:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create apreln.
            if not outils:copyValidField(buffer apreln:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteApreln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhTp-trait    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define buffer apreln for apreln.

    create query vhttquery.
    vhttBuffer = ghttApreln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttApreln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhTp-trait, output vhEtab-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first apreln exclusive-lock
                where rowid(Apreln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer apreln:handle, 'soc-cd/tp-trait/etab-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhTp-trait:buffer-value(), vhEtab-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete apreln no-error.
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

