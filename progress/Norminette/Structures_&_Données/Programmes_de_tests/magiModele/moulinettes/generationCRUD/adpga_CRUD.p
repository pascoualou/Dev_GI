/*------------------------------------------------------------------------
File        : adpga_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table adpga
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/adpga.i}
{application/include/error.i}
define variable ghttadpga as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNomdt as handle, output phNoloc as handle, output phNolig as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nomdt/noloc/nolig, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
            when 'noloc' then phNoloc = phBuffer:buffer-field(vi).
            when 'nolig' then phNolig = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAdpga private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAdpga.
    run updateAdpga.
    run createAdpga.
end procedure.

procedure setAdpga:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAdpga.
    ghttAdpga = phttAdpga.
    run crudAdpga.
    delete object phttAdpga.
end procedure.

procedure readAdpga:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table adpga 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNoloc as int64      no-undo.
    define input parameter piNolig as integer    no-undo.
    define input parameter table-handle phttAdpga.
    define variable vhttBuffer as handle no-undo.
    define buffer adpga for adpga.

    vhttBuffer = phttAdpga:default-buffer-handle.
    for first adpga no-lock
        where adpga.nomdt = piNomdt
          and adpga.noloc = piNoloc
          and adpga.nolig = piNolig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer adpga:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAdpga no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAdpga:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table adpga 
    Notes  : service externe. Critère piNoloc = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNoloc as int64      no-undo.
    define input parameter table-handle phttAdpga.
    define variable vhttBuffer as handle  no-undo.
    define buffer adpga for adpga.

    vhttBuffer = phttAdpga:default-buffer-handle.
    if piNoloc = ?
    then for each adpga no-lock
        where adpga.nomdt = piNomdt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer adpga:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each adpga no-lock
        where adpga.nomdt = piNomdt
          and adpga.noloc = piNoloc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer adpga:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAdpga no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAdpga private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoloc    as handle  no-undo.
    define variable vhNolig    as handle  no-undo.
    define buffer adpga for adpga.

    create query vhttquery.
    vhttBuffer = ghttAdpga:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAdpga:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt, output vhNoloc, output vhNolig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first adpga exclusive-lock
                where rowid(adpga) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer adpga:handle, 'nomdt/noloc/nolig: ', substitute('&1/&2/&3', vhNomdt:buffer-value(), vhNoloc:buffer-value(), vhNolig:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer adpga:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAdpga private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer adpga for adpga.

    create query vhttquery.
    vhttBuffer = ghttAdpga:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAdpga:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create adpga.
            if not outils:copyValidField(buffer adpga:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAdpga private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoloc    as handle  no-undo.
    define variable vhNolig    as handle  no-undo.
    define buffer adpga for adpga.

    create query vhttquery.
    vhttBuffer = ghttAdpga:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAdpga:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt, output vhNoloc, output vhNolig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first adpga exclusive-lock
                where rowid(Adpga) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer adpga:handle, 'nomdt/noloc/nolig: ', substitute('&1/&2/&3', vhNomdt:buffer-value(), vhNoloc:buffer-value(), vhNolig:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete adpga no-error.
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

