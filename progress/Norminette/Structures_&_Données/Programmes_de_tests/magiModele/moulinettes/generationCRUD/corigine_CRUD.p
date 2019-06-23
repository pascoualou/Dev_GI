/*------------------------------------------------------------------------
File        : corigine_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table corigine
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/corigine.i}
{application/include/error.i}
define variable ghttcorigine as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phOri-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/ori-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'ori-cle' then phOri-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCorigine private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCorigine.
    run updateCorigine.
    run createCorigine.
end procedure.

procedure setCorigine:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCorigine.
    ghttCorigine = phttCorigine.
    run crudCorigine.
    delete object phttCorigine.
end procedure.

procedure readCorigine:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table corigine 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter pcOri-cle as character  no-undo.
    define input parameter table-handle phttCorigine.
    define variable vhttBuffer as handle no-undo.
    define buffer corigine for corigine.

    vhttBuffer = phttCorigine:default-buffer-handle.
    for first corigine no-lock
        where corigine.soc-cd = piSoc-cd
          and corigine.ori-cle = pcOri-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer corigine:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCorigine no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCorigine:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table corigine 
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter table-handle phttCorigine.
    define variable vhttBuffer as handle  no-undo.
    define buffer corigine for corigine.

    vhttBuffer = phttCorigine:default-buffer-handle.
    if piSoc-cd = ?
    then for each corigine no-lock
        where corigine.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer corigine:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each corigine no-lock
        where corigine.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer corigine:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCorigine no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCorigine private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhOri-cle    as handle  no-undo.
    define buffer corigine for corigine.

    create query vhttquery.
    vhttBuffer = ghttCorigine:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCorigine:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhOri-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first corigine exclusive-lock
                where rowid(corigine) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer corigine:handle, 'soc-cd/ori-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhOri-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer corigine:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCorigine private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer corigine for corigine.

    create query vhttquery.
    vhttBuffer = ghttCorigine:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCorigine:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create corigine.
            if not outils:copyValidField(buffer corigine:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCorigine private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhOri-cle    as handle  no-undo.
    define buffer corigine for corigine.

    create query vhttquery.
    vhttBuffer = ghttCorigine:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCorigine:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhOri-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first corigine exclusive-lock
                where rowid(Corigine) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer corigine:handle, 'soc-cd/ori-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhOri-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete corigine no-error.
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

