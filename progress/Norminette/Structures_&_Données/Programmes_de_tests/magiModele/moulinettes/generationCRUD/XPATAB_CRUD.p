/*------------------------------------------------------------------------
File        : XPATAB_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table XPATAB
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/XPATAB.i}
{application/include/error.i}
define variable ghttXPATAB as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNotab as handle, output phNolig as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur notab/nolig, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'notab' then phNotab = phBuffer:buffer-field(vi).
            when 'nolig' then phNolig = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudXpatab private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteXpatab.
    run updateXpatab.
    run createXpatab.
end procedure.

procedure setXpatab:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttXpatab.
    ghttXpatab = phttXpatab.
    run crudXpatab.
    delete object phttXpatab.
end procedure.

procedure readXpatab:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table XPATAB Tables des paramétrages de paie
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNotab as integer    no-undo.
    define input parameter piNolig as integer    no-undo.
    define input parameter table-handle phttXpatab.
    define variable vhttBuffer as handle no-undo.
    define buffer XPATAB for XPATAB.

    vhttBuffer = phttXpatab:default-buffer-handle.
    for first XPATAB no-lock
        where XPATAB.notab = piNotab
          and XPATAB.nolig = piNolig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer XPATAB:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttXpatab no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getXpatab:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table XPATAB Tables des paramétrages de paie
    Notes  : service externe. Critère piNotab = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNotab as integer    no-undo.
    define input parameter table-handle phttXpatab.
    define variable vhttBuffer as handle  no-undo.
    define buffer XPATAB for XPATAB.

    vhttBuffer = phttXpatab:default-buffer-handle.
    if piNotab = ?
    then for each XPATAB no-lock
        where XPATAB.notab = piNotab:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer XPATAB:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each XPATAB no-lock
        where XPATAB.notab = piNotab:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer XPATAB:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttXpatab no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateXpatab private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNotab    as handle  no-undo.
    define variable vhNolig    as handle  no-undo.
    define buffer XPATAB for XPATAB.

    create query vhttquery.
    vhttBuffer = ghttXpatab:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttXpatab:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNotab, output vhNolig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first XPATAB exclusive-lock
                where rowid(XPATAB) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer XPATAB:handle, 'notab/nolig: ', substitute('&1/&2', vhNotab:buffer-value(), vhNolig:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer XPATAB:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createXpatab private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer XPATAB for XPATAB.

    create query vhttquery.
    vhttBuffer = ghttXpatab:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttXpatab:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create XPATAB.
            if not outils:copyValidField(buffer XPATAB:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteXpatab private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNotab    as handle  no-undo.
    define variable vhNolig    as handle  no-undo.
    define buffer XPATAB for XPATAB.

    create query vhttquery.
    vhttBuffer = ghttXpatab:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttXpatab:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNotab, output vhNolig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first XPATAB exclusive-lock
                where rowid(Xpatab) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer XPATAB:handle, 'notab/nolig: ', substitute('&1/&2', vhNotab:buffer-value(), vhNolig:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete XPATAB no-error.
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

