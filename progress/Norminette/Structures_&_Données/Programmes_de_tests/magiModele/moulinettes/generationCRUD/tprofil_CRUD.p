/*------------------------------------------------------------------------
File        : tprofil_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table tprofil
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/tprofil.i}
{application/include/error.i}
define variable ghtttprofil as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phProfil_u as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur profil_u, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'profil_u' then phProfil_u = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTprofil private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTprofil.
    run updateTprofil.
    run createTprofil.
end procedure.

procedure setTprofil:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTprofil.
    ghttTprofil = phttTprofil.
    run crudTprofil.
    delete object phttTprofil.
end procedure.

procedure readTprofil:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table tprofil 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcProfil_u as character  no-undo.
    define input parameter table-handle phttTprofil.
    define variable vhttBuffer as handle no-undo.
    define buffer tprofil for tprofil.

    vhttBuffer = phttTprofil:default-buffer-handle.
    for first tprofil no-lock
        where tprofil.profil_u = pcProfil_u:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tprofil:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTprofil no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTprofil:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table tprofil 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTprofil.
    define variable vhttBuffer as handle  no-undo.
    define buffer tprofil for tprofil.

    vhttBuffer = phttTprofil:default-buffer-handle.
    for each tprofil no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tprofil:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTprofil no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTprofil private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhProfil_u    as handle  no-undo.
    define buffer tprofil for tprofil.

    create query vhttquery.
    vhttBuffer = ghttTprofil:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTprofil:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhProfil_u).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tprofil exclusive-lock
                where rowid(tprofil) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tprofil:handle, 'profil_u: ', substitute('&1', vhProfil_u:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer tprofil:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTprofil private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer tprofil for tprofil.

    create query vhttquery.
    vhttBuffer = ghttTprofil:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTprofil:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create tprofil.
            if not outils:copyValidField(buffer tprofil:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTprofil private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhProfil_u    as handle  no-undo.
    define buffer tprofil for tprofil.

    create query vhttquery.
    vhttBuffer = ghttTprofil:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTprofil:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhProfil_u).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tprofil exclusive-lock
                where rowid(Tprofil) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tprofil:handle, 'profil_u: ', substitute('&1', vhProfil_u:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete tprofil no-error.
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

