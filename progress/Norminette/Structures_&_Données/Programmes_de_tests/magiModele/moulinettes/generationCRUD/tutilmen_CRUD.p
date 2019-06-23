/*------------------------------------------------------------------------
File        : tutilmen_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table tutilmen
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/tutilmen.i}
{application/include/error.i}
define variable ghtttutilmen as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phProfil_u as handle, output phCdapp as handle, output phNoord as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur profil_u/cdapp/noord, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'profil_u' then phProfil_u = phBuffer:buffer-field(vi).
            when 'cdapp' then phCdapp = phBuffer:buffer-field(vi).
            when 'noord' then phNoord = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTutilmen private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTutilmen.
    run updateTutilmen.
    run createTutilmen.
end procedure.

procedure setTutilmen:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTutilmen.
    ghttTutilmen = phttTutilmen.
    run crudTutilmen.
    delete object phttTutilmen.
end procedure.

procedure readTutilmen:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table tutilmen 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcProfil_u as character  no-undo.
    define input parameter pcCdapp    as character  no-undo.
    define input parameter piNoord    as integer    no-undo.
    define input parameter table-handle phttTutilmen.
    define variable vhttBuffer as handle no-undo.
    define buffer tutilmen for tutilmen.

    vhttBuffer = phttTutilmen:default-buffer-handle.
    for first tutilmen no-lock
        where tutilmen.profil_u = pcProfil_u
          and tutilmen.cdapp = pcCdapp
          and tutilmen.noord = piNoord:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tutilmen:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTutilmen no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTutilmen:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table tutilmen 
    Notes  : service externe. Critère pcCdapp = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcProfil_u as character  no-undo.
    define input parameter pcCdapp    as character  no-undo.
    define input parameter table-handle phttTutilmen.
    define variable vhttBuffer as handle  no-undo.
    define buffer tutilmen for tutilmen.

    vhttBuffer = phttTutilmen:default-buffer-handle.
    if pcCdapp = ?
    then for each tutilmen no-lock
        where tutilmen.profil_u = pcProfil_u:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tutilmen:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each tutilmen no-lock
        where tutilmen.profil_u = pcProfil_u
          and tutilmen.cdapp = pcCdapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tutilmen:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTutilmen no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTutilmen private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhProfil_u    as handle  no-undo.
    define variable vhCdapp    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer tutilmen for tutilmen.

    create query vhttquery.
    vhttBuffer = ghttTutilmen:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTutilmen:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhProfil_u, output vhCdapp, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tutilmen exclusive-lock
                where rowid(tutilmen) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tutilmen:handle, 'profil_u/cdapp/noord: ', substitute('&1/&2/&3', vhProfil_u:buffer-value(), vhCdapp:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer tutilmen:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTutilmen private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer tutilmen for tutilmen.

    create query vhttquery.
    vhttBuffer = ghttTutilmen:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTutilmen:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create tutilmen.
            if not outils:copyValidField(buffer tutilmen:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTutilmen private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhProfil_u    as handle  no-undo.
    define variable vhCdapp    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer tutilmen for tutilmen.

    create query vhttquery.
    vhttBuffer = ghttTutilmen:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTutilmen:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhProfil_u, output vhCdapp, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tutilmen exclusive-lock
                where rowid(Tutilmen) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tutilmen:handle, 'profil_u/cdapp/noord: ', substitute('&1/&2/&3', vhProfil_u:buffer-value(), vhCdapp:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete tutilmen no-error.
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

