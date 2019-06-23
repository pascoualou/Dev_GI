/*------------------------------------------------------------------------
File        : PROFIL_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table PROFIL
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/PROFIL.i}
{application/include/error.i}
define variable ghttPROFIL as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdprofil as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur CDPROFIL, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'CDPROFIL' then phCdprofil = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudProfil private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteProfil.
    run updateProfil.
    run createProfil.
end procedure.

procedure setProfil:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttProfil.
    ghttProfil = phttProfil.
    run crudProfil.
    delete object phttProfil.
end procedure.

procedure readProfil:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table PROFIL 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdprofil as character  no-undo.
    define input parameter table-handle phttProfil.
    define variable vhttBuffer as handle no-undo.
    define buffer PROFIL for PROFIL.

    vhttBuffer = phttProfil:default-buffer-handle.
    for first PROFIL no-lock
        where PROFIL.CDPROFIL = pcCdprofil:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer PROFIL:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttProfil no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getProfil:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table PROFIL 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttProfil.
    define variable vhttBuffer as handle  no-undo.
    define buffer PROFIL for PROFIL.

    vhttBuffer = phttProfil:default-buffer-handle.
    for each PROFIL no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer PROFIL:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttProfil no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateProfil private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdprofil    as handle  no-undo.
    define buffer PROFIL for PROFIL.

    create query vhttquery.
    vhttBuffer = ghttProfil:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttProfil:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdprofil).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first PROFIL exclusive-lock
                where rowid(PROFIL) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer PROFIL:handle, 'CDPROFIL: ', substitute('&1', vhCdprofil:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer PROFIL:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createProfil private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer PROFIL for PROFIL.

    create query vhttquery.
    vhttBuffer = ghttProfil:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttProfil:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create PROFIL.
            if not outils:copyValidField(buffer PROFIL:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteProfil private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdprofil    as handle  no-undo.
    define buffer PROFIL for PROFIL.

    create query vhttquery.
    vhttBuffer = ghttProfil:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttProfil:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdprofil).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first PROFIL exclusive-lock
                where rowid(Profil) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer PROFIL:handle, 'CDPROFIL: ', substitute('&1', vhCdprofil:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete PROFIL no-error.
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

