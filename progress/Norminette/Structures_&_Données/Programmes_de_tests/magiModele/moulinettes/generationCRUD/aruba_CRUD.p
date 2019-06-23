/*------------------------------------------------------------------------
File        : aruba_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table aruba
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/aruba.i}
{application/include/error.i}
define variable ghttaruba as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phCdlng as handle, output phFg-rub as handle, output phRub-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/cdlng/fg-rub/rub-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'cdlng' then phCdlng = phBuffer:buffer-field(vi).
            when 'fg-rub' then phFg-rub = phBuffer:buffer-field(vi).
            when 'rub-cd' then phRub-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAruba private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAruba.
    run updateAruba.
    run createAruba.
end procedure.

procedure setAruba:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAruba.
    ghttAruba = phttAruba.
    run crudAruba.
    delete object phttAruba.
end procedure.

procedure readAruba:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table aruba 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd as integer    no-undo.
    define input parameter piCdlng  as integer    no-undo.
    define input parameter plFg-rub as logical    no-undo.
    define input parameter pcRub-cd as character  no-undo.
    define input parameter table-handle phttAruba.
    define variable vhttBuffer as handle no-undo.
    define buffer aruba for aruba.

    vhttBuffer = phttAruba:default-buffer-handle.
    for first aruba no-lock
        where aruba.soc-cd = piSoc-cd
          and aruba.cdlng = piCdlng
          and aruba.fg-rub = plFg-rub
          and aruba.rub-cd = pcRub-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aruba:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAruba no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAruba:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table aruba 
    Notes  : service externe. Critère plFg-rub = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd as integer    no-undo.
    define input parameter piCdlng  as integer    no-undo.
    define input parameter plFg-rub as logical    no-undo.
    define input parameter table-handle phttAruba.
    define variable vhttBuffer as handle  no-undo.
    define buffer aruba for aruba.

    vhttBuffer = phttAruba:default-buffer-handle.
    if plFg-rub = ?
    then for each aruba no-lock
        where aruba.soc-cd = piSoc-cd
          and aruba.cdlng = piCdlng:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aruba:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each aruba no-lock
        where aruba.soc-cd = piSoc-cd
          and aruba.cdlng = piCdlng
          and aruba.fg-rub = plFg-rub:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aruba:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAruba no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAruba private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhCdlng    as handle  no-undo.
    define variable vhFg-rub    as handle  no-undo.
    define variable vhRub-cd    as handle  no-undo.
    define buffer aruba for aruba.

    create query vhttquery.
    vhttBuffer = ghttAruba:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAruba:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhCdlng, output vhFg-rub, output vhRub-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aruba exclusive-lock
                where rowid(aruba) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aruba:handle, 'soc-cd/cdlng/fg-rub/rub-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhCdlng:buffer-value(), vhFg-rub:buffer-value(), vhRub-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer aruba:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAruba private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer aruba for aruba.

    create query vhttquery.
    vhttBuffer = ghttAruba:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAruba:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create aruba.
            if not outils:copyValidField(buffer aruba:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAruba private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhCdlng    as handle  no-undo.
    define variable vhFg-rub    as handle  no-undo.
    define variable vhRub-cd    as handle  no-undo.
    define buffer aruba for aruba.

    create query vhttquery.
    vhttBuffer = ghttAruba:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAruba:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhCdlng, output vhFg-rub, output vhRub-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aruba exclusive-lock
                where rowid(Aruba) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aruba:handle, 'soc-cd/cdlng/fg-rub/rub-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhCdlng:buffer-value(), vhFg-rub:buffer-value(), vhRub-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete aruba no-error.
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

