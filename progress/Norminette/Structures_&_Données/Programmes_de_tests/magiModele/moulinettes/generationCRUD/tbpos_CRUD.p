/*------------------------------------------------------------------------
File        : tbpos_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table tbpos
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/tbpos.i}
{application/include/error.i}
define variable ghtttbpos as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdpos as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cdpos, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cdpos' then phCdpos = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTbpos private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTbpos.
    run updateTbpos.
    run createTbpos.
end procedure.

procedure setTbpos:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTbpos.
    ghttTbpos = phttTbpos.
    run crudTbpos.
    delete object phttTbpos.
end procedure.

procedure readTbpos:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table tbpos Table des codes postaux avec les villes associ‚es
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdpos as character  no-undo.
    define input parameter table-handle phttTbpos.
    define variable vhttBuffer as handle no-undo.
    define buffer tbpos for tbpos.

    vhttBuffer = phttTbpos:default-buffer-handle.
    for first tbpos no-lock
        where tbpos.cdpos = pcCdpos:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tbpos:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTbpos no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTbpos:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table tbpos Table des codes postaux avec les villes associ‚es
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTbpos.
    define variable vhttBuffer as handle  no-undo.
    define buffer tbpos for tbpos.

    vhttBuffer = phttTbpos:default-buffer-handle.
    for each tbpos no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tbpos:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTbpos no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTbpos private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdpos    as handle  no-undo.
    define buffer tbpos for tbpos.

    create query vhttquery.
    vhttBuffer = ghttTbpos:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTbpos:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdpos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tbpos exclusive-lock
                where rowid(tbpos) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tbpos:handle, 'cdpos: ', substitute('&1', vhCdpos:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer tbpos:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTbpos private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer tbpos for tbpos.

    create query vhttquery.
    vhttBuffer = ghttTbpos:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTbpos:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create tbpos.
            if not outils:copyValidField(buffer tbpos:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTbpos private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdpos    as handle  no-undo.
    define buffer tbpos for tbpos.

    create query vhttquery.
    vhttBuffer = ghttTbpos:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTbpos:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdpos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tbpos exclusive-lock
                where rowid(Tbpos) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tbpos:handle, 'cdpos: ', substitute('&1', vhCdpos:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete tbpos no-error.
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

