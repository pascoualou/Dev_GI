/*------------------------------------------------------------------------
File        : parjou_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table parjou
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/parjou.i}
{application/include/error.i}
define variable ghttparjou as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phParjou-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/parjou-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'parjou-cd' then phParjou-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudParjou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteParjou.
    run updateParjou.
    run createParjou.
end procedure.

procedure setParjou:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttParjou.
    ghttParjou = phttParjou.
    run crudParjou.
    delete object phttParjou.
end procedure.

procedure readParjou:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table parjou Fichier Parametrage des Journaux
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piParjou-cd as integer    no-undo.
    define input parameter table-handle phttParjou.
    define variable vhttBuffer as handle no-undo.
    define buffer parjou for parjou.

    vhttBuffer = phttParjou:default-buffer-handle.
    for first parjou no-lock
        where parjou.soc-cd = piSoc-cd
          and parjou.parjou-cd = piParjou-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer parjou:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttParjou no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getParjou:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table parjou Fichier Parametrage des Journaux
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter table-handle phttParjou.
    define variable vhttBuffer as handle  no-undo.
    define buffer parjou for parjou.

    vhttBuffer = phttParjou:default-buffer-handle.
    if piSoc-cd = ?
    then for each parjou no-lock
        where parjou.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer parjou:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each parjou no-lock
        where parjou.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer parjou:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttParjou no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateParjou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhParjou-cd    as handle  no-undo.
    define buffer parjou for parjou.

    create query vhttquery.
    vhttBuffer = ghttParjou:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttParjou:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhParjou-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first parjou exclusive-lock
                where rowid(parjou) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer parjou:handle, 'soc-cd/parjou-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhParjou-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer parjou:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createParjou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer parjou for parjou.

    create query vhttquery.
    vhttBuffer = ghttParjou:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttParjou:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create parjou.
            if not outils:copyValidField(buffer parjou:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteParjou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhParjou-cd    as handle  no-undo.
    define buffer parjou for parjou.

    create query vhttquery.
    vhttBuffer = ghttParjou:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttParjou:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhParjou-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first parjou exclusive-lock
                where rowid(Parjou) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer parjou:handle, 'soc-cd/parjou-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhParjou-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete parjou no-error.
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

