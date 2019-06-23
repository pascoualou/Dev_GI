/*------------------------------------------------------------------------
File        : lotlocat_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table lotlocat
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/lotlocat.i}
{application/include/error.i}
define variable ghttlotlocat as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNofiche as handle, output phNoloc as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nofiche/noloc, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nofiche' then phNofiche = phBuffer:buffer-field(vi).
            when 'noloc' then phNoloc = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudLotlocat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteLotlocat.
    run updateLotlocat.
    run createLotlocat.
end procedure.

procedure setLotlocat:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttLotlocat.
    ghttLotlocat = phttLotlocat.
    run crudLotlocat.
    delete object phttLotlocat.
end procedure.

procedure readLotlocat:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table lotlocat 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNofiche as integer    no-undo.
    define input parameter piNoloc   as integer    no-undo.
    define input parameter table-handle phttLotlocat.
    define variable vhttBuffer as handle no-undo.
    define buffer lotlocat for lotlocat.

    vhttBuffer = phttLotlocat:default-buffer-handle.
    for first lotlocat no-lock
        where lotlocat.nofiche = piNofiche
          and lotlocat.noloc = piNoloc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer lotlocat:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLotlocat no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getLotlocat:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table lotlocat 
    Notes  : service externe. Critère piNofiche = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNofiche as integer    no-undo.
    define input parameter table-handle phttLotlocat.
    define variable vhttBuffer as handle  no-undo.
    define buffer lotlocat for lotlocat.

    vhttBuffer = phttLotlocat:default-buffer-handle.
    if piNofiche = ?
    then for each lotlocat no-lock
        where lotlocat.nofiche = piNofiche:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer lotlocat:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each lotlocat no-lock
        where lotlocat.nofiche = piNofiche:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer lotlocat:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLotlocat no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateLotlocat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNofiche    as handle  no-undo.
    define variable vhNoloc    as handle  no-undo.
    define buffer lotlocat for lotlocat.

    create query vhttquery.
    vhttBuffer = ghttLotlocat:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttLotlocat:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNofiche, output vhNoloc).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first lotlocat exclusive-lock
                where rowid(lotlocat) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer lotlocat:handle, 'nofiche/noloc: ', substitute('&1/&2', vhNofiche:buffer-value(), vhNoloc:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer lotlocat:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createLotlocat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer lotlocat for lotlocat.

    create query vhttquery.
    vhttBuffer = ghttLotlocat:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttLotlocat:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create lotlocat.
            if not outils:copyValidField(buffer lotlocat:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteLotlocat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNofiche    as handle  no-undo.
    define variable vhNoloc    as handle  no-undo.
    define buffer lotlocat for lotlocat.

    create query vhttquery.
    vhttBuffer = ghttLotlocat:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttLotlocat:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNofiche, output vhNoloc).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first lotlocat exclusive-lock
                where rowid(Lotlocat) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer lotlocat:handle, 'nofiche/noloc: ', substitute('&1/&2', vhNofiche:buffer-value(), vhNoloc:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete lotlocat no-error.
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

