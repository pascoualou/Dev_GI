/*------------------------------------------------------------------------
File        : NATUR_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table NATUR
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/NATUR.i}
{application/include/error.i}
define variable ghttNATUR as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNonat as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur NONAT, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'NONAT' then phNonat = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudNatur private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteNatur.
    run updateNatur.
    run createNatur.
end procedure.

procedure setNatur:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttNatur.
    ghttNatur = phttNatur.
    run crudNatur.
    delete object phttNatur.
end procedure.

procedure readNatur:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table NATUR 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNonat as integer    no-undo.
    define input parameter table-handle phttNatur.
    define variable vhttBuffer as handle no-undo.
    define buffer NATUR for NATUR.

    vhttBuffer = phttNatur:default-buffer-handle.
    for first NATUR no-lock
        where NATUR.NONAT = piNonat:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer NATUR:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttNatur no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getNatur:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table NATUR 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttNatur.
    define variable vhttBuffer as handle  no-undo.
    define buffer NATUR for NATUR.

    vhttBuffer = phttNatur:default-buffer-handle.
    for each NATUR no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer NATUR:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttNatur no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateNatur private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNonat    as handle  no-undo.
    define buffer NATUR for NATUR.

    create query vhttquery.
    vhttBuffer = ghttNatur:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttNatur:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNonat).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first NATUR exclusive-lock
                where rowid(NATUR) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer NATUR:handle, 'NONAT: ', substitute('&1', vhNonat:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer NATUR:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createNatur private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer NATUR for NATUR.

    create query vhttquery.
    vhttBuffer = ghttNatur:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttNatur:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create NATUR.
            if not outils:copyValidField(buffer NATUR:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteNatur private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNonat    as handle  no-undo.
    define buffer NATUR for NATUR.

    create query vhttquery.
    vhttBuffer = ghttNatur:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttNatur:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNonat).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first NATUR exclusive-lock
                where rowid(Natur) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer NATUR:handle, 'NONAT: ', substitute('&1', vhNonat:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete NATUR no-error.
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

