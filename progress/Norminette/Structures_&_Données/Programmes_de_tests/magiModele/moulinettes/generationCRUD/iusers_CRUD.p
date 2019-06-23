/*------------------------------------------------------------------------
File        : iusers_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iusers
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iusers.i}
{application/include/error.i}
define variable ghttiusers as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phUser-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/user-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'user-cle' then phUser-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIusers private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIusers.
    run updateIusers.
    run createIusers.
end procedure.

procedure setIusers:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIusers.
    ghttIusers = phttIusers.
    run crudIusers.
    delete object phttIusers.
end procedure.

procedure readIusers:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iusers table des utilisateurs pour defauts
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter pcUser-cle as character  no-undo.
    define input parameter table-handle phttIusers.
    define variable vhttBuffer as handle no-undo.
    define buffer iusers for iusers.

    vhttBuffer = phttIusers:default-buffer-handle.
    for first iusers no-lock
        where iusers.soc-cd = piSoc-cd
          and iusers.user-cle = pcUser-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iusers:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIusers no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIusers:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iusers table des utilisateurs pour defauts
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter table-handle phttIusers.
    define variable vhttBuffer as handle  no-undo.
    define buffer iusers for iusers.

    vhttBuffer = phttIusers:default-buffer-handle.
    if piSoc-cd = ?
    then for each iusers no-lock
        where iusers.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iusers:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iusers no-lock
        where iusers.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iusers:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIusers no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIusers private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhUser-cle    as handle  no-undo.
    define buffer iusers for iusers.

    create query vhttquery.
    vhttBuffer = ghttIusers:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIusers:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhUser-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iusers exclusive-lock
                where rowid(iusers) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iusers:handle, 'soc-cd/user-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhUser-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iusers:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIusers private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iusers for iusers.

    create query vhttquery.
    vhttBuffer = ghttIusers:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIusers:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iusers.
            if not outils:copyValidField(buffer iusers:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIusers private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhUser-cle    as handle  no-undo.
    define buffer iusers for iusers.

    create query vhttquery.
    vhttBuffer = ghttIusers:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIusers:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhUser-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iusers exclusive-lock
                where rowid(Iusers) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iusers:handle, 'soc-cd/user-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhUser-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iusers no-error.
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

