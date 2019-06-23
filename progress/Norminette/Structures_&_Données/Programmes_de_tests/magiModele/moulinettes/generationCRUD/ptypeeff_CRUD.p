/*------------------------------------------------------------------------
File        : ptypeeff_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ptypeeff
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ptypeeff.i}
{application/include/error.i}
define variable ghttptypeeff as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTypeeff-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur typeeff-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'typeeff-cd' then phTypeeff-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPtypeeff private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePtypeeff.
    run updatePtypeeff.
    run createPtypeeff.
end procedure.

procedure setPtypeeff:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPtypeeff.
    ghttPtypeeff = phttPtypeeff.
    run crudPtypeeff.
    delete object phttPtypeeff.
end procedure.

procedure readPtypeeff:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ptypeeff Fichier Table des Effets
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piTypeeff-cd as integer    no-undo.
    define input parameter table-handle phttPtypeeff.
    define variable vhttBuffer as handle no-undo.
    define buffer ptypeeff for ptypeeff.

    vhttBuffer = phttPtypeeff:default-buffer-handle.
    for first ptypeeff no-lock
        where ptypeeff.typeeff-cd = piTypeeff-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ptypeeff:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPtypeeff no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPtypeeff:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ptypeeff Fichier Table des Effets
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPtypeeff.
    define variable vhttBuffer as handle  no-undo.
    define buffer ptypeeff for ptypeeff.

    vhttBuffer = phttPtypeeff:default-buffer-handle.
    for each ptypeeff no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ptypeeff:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPtypeeff no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePtypeeff private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTypeeff-cd    as handle  no-undo.
    define buffer ptypeeff for ptypeeff.

    create query vhttquery.
    vhttBuffer = ghttPtypeeff:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPtypeeff:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTypeeff-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ptypeeff exclusive-lock
                where rowid(ptypeeff) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ptypeeff:handle, 'typeeff-cd: ', substitute('&1', vhTypeeff-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ptypeeff:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPtypeeff private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ptypeeff for ptypeeff.

    create query vhttquery.
    vhttBuffer = ghttPtypeeff:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPtypeeff:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ptypeeff.
            if not outils:copyValidField(buffer ptypeeff:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePtypeeff private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTypeeff-cd    as handle  no-undo.
    define buffer ptypeeff for ptypeeff.

    create query vhttquery.
    vhttBuffer = ghttPtypeeff:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPtypeeff:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTypeeff-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ptypeeff exclusive-lock
                where rowid(Ptypeeff) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ptypeeff:handle, 'typeeff-cd: ', substitute('&1', vhTypeeff-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ptypeeff no-error.
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

