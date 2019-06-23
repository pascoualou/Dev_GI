/*------------------------------------------------------------------------
File        : alrub_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table alrub
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/alrub.i}
{application/include/error.i}
define variable ghttalrub as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phRub-cd as handle, output phSsrub-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/rub-cd/ssrub-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'rub-cd' then phRub-cd = phBuffer:buffer-field(vi).
            when 'ssrub-cd' then phSsrub-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAlrub private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAlrub.
    run updateAlrub.
    run createAlrub.
end procedure.

procedure setAlrub:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAlrub.
    ghttAlrub = phttAlrub.
    run crudAlrub.
    delete object phttAlrub.
end procedure.

procedure readAlrub:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table alrub 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter pcRub-cd   as character  no-undo.
    define input parameter pcSsrub-cd as character  no-undo.
    define input parameter table-handle phttAlrub.
    define variable vhttBuffer as handle no-undo.
    define buffer alrub for alrub.

    vhttBuffer = phttAlrub:default-buffer-handle.
    for first alrub no-lock
        where alrub.soc-cd = piSoc-cd
          and alrub.rub-cd = pcRub-cd
          and alrub.ssrub-cd = pcSsrub-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer alrub:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAlrub no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAlrub:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table alrub 
    Notes  : service externe. Critère pcRub-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter pcRub-cd   as character  no-undo.
    define input parameter table-handle phttAlrub.
    define variable vhttBuffer as handle  no-undo.
    define buffer alrub for alrub.

    vhttBuffer = phttAlrub:default-buffer-handle.
    if pcRub-cd = ?
    then for each alrub no-lock
        where alrub.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer alrub:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each alrub no-lock
        where alrub.soc-cd = piSoc-cd
          and alrub.rub-cd = pcRub-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer alrub:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAlrub no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAlrub private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhRub-cd    as handle  no-undo.
    define variable vhSsrub-cd    as handle  no-undo.
    define buffer alrub for alrub.

    create query vhttquery.
    vhttBuffer = ghttAlrub:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAlrub:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhRub-cd, output vhSsrub-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first alrub exclusive-lock
                where rowid(alrub) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer alrub:handle, 'soc-cd/rub-cd/ssrub-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhRub-cd:buffer-value(), vhSsrub-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer alrub:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAlrub private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer alrub for alrub.

    create query vhttquery.
    vhttBuffer = ghttAlrub:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAlrub:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create alrub.
            if not outils:copyValidField(buffer alrub:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAlrub private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhRub-cd    as handle  no-undo.
    define variable vhSsrub-cd    as handle  no-undo.
    define buffer alrub for alrub.

    create query vhttquery.
    vhttBuffer = ghttAlrub:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAlrub:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhRub-cd, output vhSsrub-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first alrub exclusive-lock
                where rowid(Alrub) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer alrub:handle, 'soc-cd/rub-cd/ssrub-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhRub-cd:buffer-value(), vhSsrub-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete alrub no-error.
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

