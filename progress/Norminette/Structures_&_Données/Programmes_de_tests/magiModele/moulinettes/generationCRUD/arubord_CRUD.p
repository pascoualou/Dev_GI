/*------------------------------------------------------------------------
File        : arubord_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table arubord
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/arubord.i}
{application/include/error.i}
define variable ghttarubord as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phOrdre-num as handle, output phRub-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/ordre-num/rub-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'ordre-num' then phOrdre-num = phBuffer:buffer-field(vi).
            when 'rub-cd' then phRub-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudArubord private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteArubord.
    run updateArubord.
    run createArubord.
end procedure.

procedure setArubord:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttArubord.
    ghttArubord = phttArubord.
    run crudArubord.
    delete object phttArubord.
end procedure.

procedure readArubord:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table arubord 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter piOrdre-num as integer    no-undo.
    define input parameter piRub-cd    as integer    no-undo.
    define input parameter table-handle phttArubord.
    define variable vhttBuffer as handle no-undo.
    define buffer arubord for arubord.

    vhttBuffer = phttArubord:default-buffer-handle.
    for first arubord no-lock
        where arubord.soc-cd = piSoc-cd
          and arubord.etab-cd = piEtab-cd
          and arubord.ordre-num = piOrdre-num
          and arubord.rub-cd = piRub-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer arubord:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttArubord no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getArubord:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table arubord 
    Notes  : service externe. Critère piOrdre-num = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter piOrdre-num as integer    no-undo.
    define input parameter table-handle phttArubord.
    define variable vhttBuffer as handle  no-undo.
    define buffer arubord for arubord.

    vhttBuffer = phttArubord:default-buffer-handle.
    if piOrdre-num = ?
    then for each arubord no-lock
        where arubord.soc-cd = piSoc-cd
          and arubord.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer arubord:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each arubord no-lock
        where arubord.soc-cd = piSoc-cd
          and arubord.etab-cd = piEtab-cd
          and arubord.ordre-num = piOrdre-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer arubord:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttArubord no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateArubord private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhOrdre-num    as handle  no-undo.
    define variable vhRub-cd    as handle  no-undo.
    define buffer arubord for arubord.

    create query vhttquery.
    vhttBuffer = ghttArubord:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttArubord:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhOrdre-num, output vhRub-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first arubord exclusive-lock
                where rowid(arubord) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer arubord:handle, 'soc-cd/etab-cd/ordre-num/rub-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhOrdre-num:buffer-value(), vhRub-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer arubord:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createArubord private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer arubord for arubord.

    create query vhttquery.
    vhttBuffer = ghttArubord:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttArubord:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create arubord.
            if not outils:copyValidField(buffer arubord:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteArubord private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhOrdre-num    as handle  no-undo.
    define variable vhRub-cd    as handle  no-undo.
    define buffer arubord for arubord.

    create query vhttquery.
    vhttBuffer = ghttArubord:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttArubord:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhOrdre-num, output vhRub-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first arubord exclusive-lock
                where rowid(Arubord) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer arubord:handle, 'soc-cd/etab-cd/ordre-num/rub-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhOrdre-num:buffer-value(), vhRub-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete arubord no-error.
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

