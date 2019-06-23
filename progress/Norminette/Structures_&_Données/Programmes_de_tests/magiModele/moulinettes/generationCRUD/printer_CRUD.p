/*------------------------------------------------------------------------
File        : printer_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table printer
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/printer.i}
{application/include/error.i}
define variable ghttprinter as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phPrinter-order as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur printer-order, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'printer-order' then phPrinter-order = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPrinter private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePrinter.
    run updatePrinter.
    run createPrinter.
end procedure.

procedure setPrinter:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPrinter.
    ghttPrinter = phttPrinter.
    run crudPrinter.
    delete object phttPrinter.
end procedure.

procedure readPrinter:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table printer Fichier Imprimante (G.I.)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piPrinter-order as integer    no-undo.
    define input parameter table-handle phttPrinter.
    define variable vhttBuffer as handle no-undo.
    define buffer printer for printer.

    vhttBuffer = phttPrinter:default-buffer-handle.
    for first printer no-lock
        where printer.printer-order = piPrinter-order:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer printer:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPrinter no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPrinter:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table printer Fichier Imprimante (G.I.)
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPrinter.
    define variable vhttBuffer as handle  no-undo.
    define buffer printer for printer.

    vhttBuffer = phttPrinter:default-buffer-handle.
    for each printer no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer printer:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPrinter no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePrinter private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhPrinter-order    as handle  no-undo.
    define buffer printer for printer.

    create query vhttquery.
    vhttBuffer = ghttPrinter:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPrinter:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhPrinter-order).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first printer exclusive-lock
                where rowid(printer) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer printer:handle, 'printer-order: ', substitute('&1', vhPrinter-order:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer printer:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPrinter private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer printer for printer.

    create query vhttquery.
    vhttBuffer = ghttPrinter:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPrinter:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create printer.
            if not outils:copyValidField(buffer printer:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePrinter private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhPrinter-order    as handle  no-undo.
    define buffer printer for printer.

    create query vhttquery.
    vhttBuffer = ghttPrinter:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPrinter:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhPrinter-order).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first printer exclusive-lock
                where rowid(Printer) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer printer:handle, 'printer-order: ', substitute('&1', vhPrinter-order:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete printer no-error.
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

