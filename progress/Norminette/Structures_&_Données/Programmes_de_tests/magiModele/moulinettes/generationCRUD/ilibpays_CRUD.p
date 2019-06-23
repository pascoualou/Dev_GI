/*------------------------------------------------------------------------
File        : ilibpays_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ilibpays
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ilibpays.i}
{application/include/error.i}
define variable ghttilibpays as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phLibpays-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/libpays-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'libpays-cd' then phLibpays-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIlibpays private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIlibpays.
    run updateIlibpays.
    run createIlibpays.
end procedure.

procedure setIlibpays:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIlibpays.
    ghttIlibpays = phttIlibpays.
    run crudIlibpays.
    delete object phttIlibpays.
end procedure.

procedure readIlibpays:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ilibpays Liste des libelles des differents pays
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter pcLibpays-cd as character  no-undo.
    define input parameter table-handle phttIlibpays.
    define variable vhttBuffer as handle no-undo.
    define buffer ilibpays for ilibpays.

    vhttBuffer = phttIlibpays:default-buffer-handle.
    for first ilibpays no-lock
        where ilibpays.soc-cd = piSoc-cd
          and ilibpays.libpays-cd = pcLibpays-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibpays:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibpays no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIlibpays:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ilibpays Liste des libelles des differents pays
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter table-handle phttIlibpays.
    define variable vhttBuffer as handle  no-undo.
    define buffer ilibpays for ilibpays.

    vhttBuffer = phttIlibpays:default-buffer-handle.
    if piSoc-cd = ?
    then for each ilibpays no-lock
        where ilibpays.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibpays:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ilibpays no-lock
        where ilibpays.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibpays:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibpays no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIlibpays private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhLibpays-cd    as handle  no-undo.
    define buffer ilibpays for ilibpays.

    create query vhttquery.
    vhttBuffer = ghttIlibpays:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIlibpays:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhLibpays-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibpays exclusive-lock
                where rowid(ilibpays) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibpays:handle, 'soc-cd/libpays-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhLibpays-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ilibpays:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIlibpays private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ilibpays for ilibpays.

    create query vhttquery.
    vhttBuffer = ghttIlibpays:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIlibpays:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ilibpays.
            if not outils:copyValidField(buffer ilibpays:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIlibpays private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhLibpays-cd    as handle  no-undo.
    define buffer ilibpays for ilibpays.

    create query vhttquery.
    vhttBuffer = ghttIlibpays:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIlibpays:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhLibpays-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibpays exclusive-lock
                where rowid(Ilibpays) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibpays:handle, 'soc-cd/libpays-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhLibpays-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ilibpays no-error.
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

