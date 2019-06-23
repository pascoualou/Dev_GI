/*------------------------------------------------------------------------
File        : MDSSD_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table MDSSD
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/MDSSD.i}
{application/include/error.i}
define variable ghttMDSSD as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNomod as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nomod, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nomod' then phNomod = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudMdssd private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteMdssd.
    run updateMdssd.
    run createMdssd.
end procedure.

procedure setMdssd:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttMdssd.
    ghttMdssd = phttMdssd.
    run crudMdssd.
    delete object phttMdssd.
end procedure.

procedure readMdssd:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table MDSSD Modèle de sous-dossier
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNomod as integer    no-undo.
    define input parameter table-handle phttMdssd.
    define variable vhttBuffer as handle no-undo.
    define buffer MDSSD for MDSSD.

    vhttBuffer = phttMdssd:default-buffer-handle.
    for first MDSSD no-lock
        where MDSSD.nomod = piNomod:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer MDSSD:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMdssd no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getMdssd:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table MDSSD Modèle de sous-dossier
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttMdssd.
    define variable vhttBuffer as handle  no-undo.
    define buffer MDSSD for MDSSD.

    vhttBuffer = phttMdssd:default-buffer-handle.
    for each MDSSD no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer MDSSD:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMdssd no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateMdssd private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomod    as handle  no-undo.
    define buffer MDSSD for MDSSD.

    create query vhttquery.
    vhttBuffer = ghttMdssd:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttMdssd:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomod).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first MDSSD exclusive-lock
                where rowid(MDSSD) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer MDSSD:handle, 'nomod: ', substitute('&1', vhNomod:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer MDSSD:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createMdssd private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer MDSSD for MDSSD.

    create query vhttquery.
    vhttBuffer = ghttMdssd:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttMdssd:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create MDSSD.
            if not outils:copyValidField(buffer MDSSD:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteMdssd private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomod    as handle  no-undo.
    define buffer MDSSD for MDSSD.

    create query vhttquery.
    vhttBuffer = ghttMdssd:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttMdssd:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomod).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first MDSSD exclusive-lock
                where rowid(Mdssd) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer MDSSD:handle, 'nomod: ', substitute('&1', vhNomod:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete MDSSD no-error.
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

