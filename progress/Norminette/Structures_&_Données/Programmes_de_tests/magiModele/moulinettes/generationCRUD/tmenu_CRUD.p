/*------------------------------------------------------------------------
File        : tmenu_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table tmenu
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/tmenu.i}
{application/include/error.i}
define variable ghtttmenu as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phProfil_u as handle, output phCdlng as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur profil_u/cdlng, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'profil_u' then phProfil_u = phBuffer:buffer-field(vi).
            when 'cdlng' then phCdlng = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTmenu private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTmenu.
    run updateTmenu.
    run createTmenu.
end procedure.

procedure setTmenu:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTmenu.
    ghttTmenu = phttTmenu.
    run crudTmenu.
    delete object phttTmenu.
end procedure.

procedure readTmenu:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table tmenu Menu de l'application nouvelle ergonomie
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcProfil_u as character  no-undo.
    define input parameter piCdlng    as integer    no-undo.
    define input parameter table-handle phttTmenu.
    define variable vhttBuffer as handle no-undo.
    define buffer tmenu for tmenu.

    vhttBuffer = phttTmenu:default-buffer-handle.
    for first tmenu no-lock
        where tmenu.profil_u = pcProfil_u
          and tmenu.cdlng = piCdlng:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tmenu:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTmenu no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTmenu:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table tmenu Menu de l'application nouvelle ergonomie
    Notes  : service externe. Critère pcProfil_u = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcProfil_u as character  no-undo.
    define input parameter table-handle phttTmenu.
    define variable vhttBuffer as handle  no-undo.
    define buffer tmenu for tmenu.

    vhttBuffer = phttTmenu:default-buffer-handle.
    if pcProfil_u = ?
    then for each tmenu no-lock
        where tmenu.profil_u = pcProfil_u:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tmenu:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each tmenu no-lock
        where tmenu.profil_u = pcProfil_u:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tmenu:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTmenu no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTmenu private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhProfil_u    as handle  no-undo.
    define variable vhCdlng    as handle  no-undo.
    define buffer tmenu for tmenu.

    create query vhttquery.
    vhttBuffer = ghttTmenu:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTmenu:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhProfil_u, output vhCdlng).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tmenu exclusive-lock
                where rowid(tmenu) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tmenu:handle, 'profil_u/cdlng: ', substitute('&1/&2', vhProfil_u:buffer-value(), vhCdlng:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer tmenu:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTmenu private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer tmenu for tmenu.

    create query vhttquery.
    vhttBuffer = ghttTmenu:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTmenu:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create tmenu.
            if not outils:copyValidField(buffer tmenu:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTmenu private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhProfil_u    as handle  no-undo.
    define variable vhCdlng    as handle  no-undo.
    define buffer tmenu for tmenu.

    create query vhttquery.
    vhttBuffer = ghttTmenu:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTmenu:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhProfil_u, output vhCdlng).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tmenu exclusive-lock
                where rowid(Tmenu) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tmenu:handle, 'profil_u/cdlng: ', substitute('&1/&2', vhProfil_u:buffer-value(), vhCdlng:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete tmenu no-error.
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

