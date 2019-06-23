/*------------------------------------------------------------------------
File        : LIFAM_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table LIFAM
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/LIFAM.i}
{application/include/error.i}
define variable ghttLIFAM as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNochp as handle, output phCdfam as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nochp/cdfam, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nochp' then phNochp = phBuffer:buffer-field(vi).
            when 'cdfam' then phCdfam = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudLifam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteLifam.
    run updateLifam.
    run createLifam.
end procedure.

procedure setLifam:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttLifam.
    ghttLifam = phttLifam.
    run crudLifam.
    delete object phttLifam.
end procedure.

procedure readLifam:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table LIFAM Lien famille & champ
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNochp as integer    no-undo.
    define input parameter pcCdfam as character  no-undo.
    define input parameter table-handle phttLifam.
    define variable vhttBuffer as handle no-undo.
    define buffer LIFAM for LIFAM.

    vhttBuffer = phttLifam:default-buffer-handle.
    for first LIFAM no-lock
        where LIFAM.nochp = piNochp
          and LIFAM.cdfam = pcCdfam:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer LIFAM:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLifam no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getLifam:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table LIFAM Lien famille & champ
    Notes  : service externe. Critère piNochp = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNochp as integer    no-undo.
    define input parameter table-handle phttLifam.
    define variable vhttBuffer as handle  no-undo.
    define buffer LIFAM for LIFAM.

    vhttBuffer = phttLifam:default-buffer-handle.
    if piNochp = ?
    then for each LIFAM no-lock
        where LIFAM.nochp = piNochp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer LIFAM:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each LIFAM no-lock
        where LIFAM.nochp = piNochp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer LIFAM:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLifam no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateLifam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNochp    as handle  no-undo.
    define variable vhCdfam    as handle  no-undo.
    define buffer LIFAM for LIFAM.

    create query vhttquery.
    vhttBuffer = ghttLifam:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttLifam:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNochp, output vhCdfam).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first LIFAM exclusive-lock
                where rowid(LIFAM) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer LIFAM:handle, 'nochp/cdfam: ', substitute('&1/&2', vhNochp:buffer-value(), vhCdfam:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer LIFAM:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createLifam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer LIFAM for LIFAM.

    create query vhttquery.
    vhttBuffer = ghttLifam:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttLifam:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create LIFAM.
            if not outils:copyValidField(buffer LIFAM:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteLifam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNochp    as handle  no-undo.
    define variable vhCdfam    as handle  no-undo.
    define buffer LIFAM for LIFAM.

    create query vhttquery.
    vhttBuffer = ghttLifam:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttLifam:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNochp, output vhCdfam).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first LIFAM exclusive-lock
                where rowid(Lifam) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer LIFAM:handle, 'nochp/cdfam: ', substitute('&1/&2', vhNochp:buffer-value(), vhCdfam:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete LIFAM no-error.
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

