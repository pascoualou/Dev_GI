/*------------------------------------------------------------------------
File        : barem_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table barem
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/barem.i}
{application/include/error.i}
define variable ghttbarem as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCddev as handle, output phCdbar as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cddev/cdbar, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cddev' then phCddev = phBuffer:buffer-field(vi).
            when 'cdbar' then phCdbar = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudBarem private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteBarem.
    run updateBarem.
    run createBarem.
end procedure.

procedure setBarem:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttBarem.
    ghttBarem = phttBarem.
    run crudBarem.
    delete object phttBarem.
end procedure.

procedure readBarem:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table barem 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCddev as character  no-undo.
    define input parameter pcCdbar as character  no-undo.
    define input parameter table-handle phttBarem.
    define variable vhttBuffer as handle no-undo.
    define buffer barem for barem.

    vhttBuffer = phttBarem:default-buffer-handle.
    for first barem no-lock
        where barem.cddev = pcCddev
          and barem.cdbar = pcCdbar:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer barem:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttBarem no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getBarem:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table barem 
    Notes  : service externe. Critère pcCddev = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCddev as character  no-undo.
    define input parameter table-handle phttBarem.
    define variable vhttBuffer as handle  no-undo.
    define buffer barem for barem.

    vhttBuffer = phttBarem:default-buffer-handle.
    if pcCddev = ?
    then for each barem no-lock
        where barem.cddev = pcCddev:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer barem:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each barem no-lock
        where barem.cddev = pcCddev:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer barem:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttBarem no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateBarem private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCddev    as handle  no-undo.
    define variable vhCdbar    as handle  no-undo.
    define buffer barem for barem.

    create query vhttquery.
    vhttBuffer = ghttBarem:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttBarem:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCddev, output vhCdbar).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first barem exclusive-lock
                where rowid(barem) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer barem:handle, 'cddev/cdbar: ', substitute('&1/&2', vhCddev:buffer-value(), vhCdbar:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer barem:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createBarem private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer barem for barem.

    create query vhttquery.
    vhttBuffer = ghttBarem:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttBarem:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create barem.
            if not outils:copyValidField(buffer barem:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteBarem private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCddev    as handle  no-undo.
    define variable vhCdbar    as handle  no-undo.
    define buffer barem for barem.

    create query vhttquery.
    vhttBuffer = ghttBarem:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttBarem:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCddev, output vhCdbar).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first barem exclusive-lock
                where rowid(Barem) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer barem:handle, 'cddev/cdbar: ', substitute('&1/&2', vhCddev:buffer-value(), vhCdbar:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete barem no-error.
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

