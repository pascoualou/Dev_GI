/*------------------------------------------------------------------------
File        : irgtpays_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table irgtpays
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/irgtpays.i}
{application/include/error.i}
define variable ghttirgtpays as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phRgt-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/rgt-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'rgt-cd' then phRgt-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIrgtpays private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIrgtpays.
    run updateIrgtpays.
    run createIrgtpays.
end procedure.

procedure setIrgtpays:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIrgtpays.
    ghttIrgtpays = phttIrgtpays.
    run crudIrgtpays.
    delete object phttIrgtpays.
end procedure.

procedure readIrgtpays:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table irgtpays Groupe de pays (Entete) pour niveau de relance
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd as integer    no-undo.
    define input parameter pcRgt-cd as character  no-undo.
    define input parameter table-handle phttIrgtpays.
    define variable vhttBuffer as handle no-undo.
    define buffer irgtpays for irgtpays.

    vhttBuffer = phttIrgtpays:default-buffer-handle.
    for first irgtpays no-lock
        where irgtpays.soc-cd = piSoc-cd
          and irgtpays.rgt-cd = pcRgt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer irgtpays:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIrgtpays no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIrgtpays:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table irgtpays Groupe de pays (Entete) pour niveau de relance
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd as integer    no-undo.
    define input parameter table-handle phttIrgtpays.
    define variable vhttBuffer as handle  no-undo.
    define buffer irgtpays for irgtpays.

    vhttBuffer = phttIrgtpays:default-buffer-handle.
    if piSoc-cd = ?
    then for each irgtpays no-lock
        where irgtpays.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer irgtpays:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each irgtpays no-lock
        where irgtpays.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer irgtpays:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIrgtpays no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIrgtpays private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhRgt-cd    as handle  no-undo.
    define buffer irgtpays for irgtpays.

    create query vhttquery.
    vhttBuffer = ghttIrgtpays:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIrgtpays:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhRgt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first irgtpays exclusive-lock
                where rowid(irgtpays) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer irgtpays:handle, 'soc-cd/rgt-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhRgt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer irgtpays:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIrgtpays private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer irgtpays for irgtpays.

    create query vhttquery.
    vhttBuffer = ghttIrgtpays:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIrgtpays:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create irgtpays.
            if not outils:copyValidField(buffer irgtpays:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIrgtpays private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhRgt-cd    as handle  no-undo.
    define buffer irgtpays for irgtpays.

    create query vhttquery.
    vhttBuffer = ghttIrgtpays:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIrgtpays:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhRgt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first irgtpays exclusive-lock
                where rowid(Irgtpays) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer irgtpays:handle, 'soc-cd/rgt-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhRgt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete irgtpays no-error.
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

