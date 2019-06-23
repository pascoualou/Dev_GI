/*------------------------------------------------------------------------
File        : aplafond_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table aplafond
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/aplafond.i}
{application/include/error.i}
define variable ghttaplafond as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phDaplafond as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/daplafond, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'daplafond' then phDaplafond = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAplafond private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAplafond.
    run updateAplafond.
    run createAplafond.
end procedure.

procedure setAplafond:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAplafond.
    ghttAplafond = phttAplafond.
    run crudAplafond.
    delete object phttAplafond.
end procedure.

procedure readAplafond:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table aplafond 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter pdaDaplafond as date       no-undo.
    define input parameter table-handle phttAplafond.
    define variable vhttBuffer as handle no-undo.
    define buffer aplafond for aplafond.

    vhttBuffer = phttAplafond:default-buffer-handle.
    for first aplafond no-lock
        where aplafond.soc-cd = piSoc-cd
          and aplafond.daplafond = pdaDaplafond:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aplafond:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAplafond no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAplafond:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table aplafond 
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter table-handle phttAplafond.
    define variable vhttBuffer as handle  no-undo.
    define buffer aplafond for aplafond.

    vhttBuffer = phttAplafond:default-buffer-handle.
    if piSoc-cd = ?
    then for each aplafond no-lock
        where aplafond.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aplafond:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each aplafond no-lock
        where aplafond.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aplafond:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAplafond no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAplafond private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhDaplafond    as handle  no-undo.
    define buffer aplafond for aplafond.

    create query vhttquery.
    vhttBuffer = ghttAplafond:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAplafond:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhDaplafond).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aplafond exclusive-lock
                where rowid(aplafond) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aplafond:handle, 'soc-cd/daplafond: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhDaplafond:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer aplafond:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAplafond private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer aplafond for aplafond.

    create query vhttquery.
    vhttBuffer = ghttAplafond:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAplafond:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create aplafond.
            if not outils:copyValidField(buffer aplafond:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAplafond private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhDaplafond    as handle  no-undo.
    define buffer aplafond for aplafond.

    create query vhttquery.
    vhttBuffer = ghttAplafond:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAplafond:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhDaplafond).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aplafond exclusive-lock
                where rowid(Aplafond) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aplafond:handle, 'soc-cd/daplafond: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhDaplafond:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete aplafond no-error.
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

