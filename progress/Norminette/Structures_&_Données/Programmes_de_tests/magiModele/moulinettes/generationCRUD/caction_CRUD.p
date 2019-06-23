/*------------------------------------------------------------------------
File        : caction_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table caction
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/caction.i}
{application/include/error.i}
define variable ghttcaction as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phAct-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/act-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'act-cle' then phAct-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCaction private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCaction.
    run updateCaction.
    run createCaction.
end procedure.

procedure setCaction:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCaction.
    ghttCaction = phttCaction.
    run crudCaction.
    delete object phttCaction.
end procedure.

procedure readCaction:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table caction 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter pcAct-cle as character  no-undo.
    define input parameter table-handle phttCaction.
    define variable vhttBuffer as handle no-undo.
    define buffer caction for caction.

    vhttBuffer = phttCaction:default-buffer-handle.
    for first caction no-lock
        where caction.soc-cd = piSoc-cd
          and caction.act-cle = pcAct-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer caction:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCaction no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCaction:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table caction 
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter table-handle phttCaction.
    define variable vhttBuffer as handle  no-undo.
    define buffer caction for caction.

    vhttBuffer = phttCaction:default-buffer-handle.
    if piSoc-cd = ?
    then for each caction no-lock
        where caction.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer caction:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each caction no-lock
        where caction.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer caction:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCaction no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCaction private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhAct-cle    as handle  no-undo.
    define buffer caction for caction.

    create query vhttquery.
    vhttBuffer = ghttCaction:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCaction:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhAct-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first caction exclusive-lock
                where rowid(caction) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer caction:handle, 'soc-cd/act-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhAct-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer caction:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCaction private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer caction for caction.

    create query vhttquery.
    vhttBuffer = ghttCaction:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCaction:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create caction.
            if not outils:copyValidField(buffer caction:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCaction private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhAct-cle    as handle  no-undo.
    define buffer caction for caction.

    create query vhttquery.
    vhttBuffer = ghttCaction:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCaction:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhAct-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first caction exclusive-lock
                where rowid(Caction) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer caction:handle, 'soc-cd/act-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhAct-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete caction no-error.
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

