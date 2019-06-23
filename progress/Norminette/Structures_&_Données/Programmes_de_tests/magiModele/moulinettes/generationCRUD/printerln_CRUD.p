/*------------------------------------------------------------------------
File        : printerln_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table printerln
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/printerln.i}
{application/include/error.i}
define variable ghttprinterln as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phPrinter-fam as handle, output phPrinter-order as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur printer-fam/printer-order, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'printer-fam' then phPrinter-fam = phBuffer:buffer-field(vi).
            when 'printer-order' then phPrinter-order = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPrinterln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePrinterln.
    run updatePrinterln.
    run createPrinterln.
end procedure.

procedure setPrinterln:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPrinterln.
    ghttPrinterln = phttPrinterln.
    run crudPrinterln.
    delete object phttPrinterln.
end procedure.

procedure readPrinterln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table printerln Fichier Imprimante (Sequences d'echapements)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcPrinter-fam   as character  no-undo.
    define input parameter piPrinter-order as integer    no-undo.
    define input parameter table-handle phttPrinterln.
    define variable vhttBuffer as handle no-undo.
    define buffer printerln for printerln.

    vhttBuffer = phttPrinterln:default-buffer-handle.
    for first printerln no-lock
        where printerln.printer-fam = pcPrinter-fam
          and printerln.printer-order = piPrinter-order:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer printerln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPrinterln no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPrinterln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table printerln Fichier Imprimante (Sequences d'echapements)
    Notes  : service externe. Critère pcPrinter-fam = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcPrinter-fam   as character  no-undo.
    define input parameter table-handle phttPrinterln.
    define variable vhttBuffer as handle  no-undo.
    define buffer printerln for printerln.

    vhttBuffer = phttPrinterln:default-buffer-handle.
    if pcPrinter-fam = ?
    then for each printerln no-lock
        where printerln.printer-fam = pcPrinter-fam:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer printerln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each printerln no-lock
        where printerln.printer-fam = pcPrinter-fam:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer printerln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPrinterln no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePrinterln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhPrinter-fam    as handle  no-undo.
    define variable vhPrinter-order    as handle  no-undo.
    define buffer printerln for printerln.

    create query vhttquery.
    vhttBuffer = ghttPrinterln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPrinterln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhPrinter-fam, output vhPrinter-order).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first printerln exclusive-lock
                where rowid(printerln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer printerln:handle, 'printer-fam/printer-order: ', substitute('&1/&2', vhPrinter-fam:buffer-value(), vhPrinter-order:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer printerln:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPrinterln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer printerln for printerln.

    create query vhttquery.
    vhttBuffer = ghttPrinterln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPrinterln:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create printerln.
            if not outils:copyValidField(buffer printerln:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePrinterln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhPrinter-fam    as handle  no-undo.
    define variable vhPrinter-order    as handle  no-undo.
    define buffer printerln for printerln.

    create query vhttquery.
    vhttBuffer = ghttPrinterln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPrinterln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhPrinter-fam, output vhPrinter-order).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first printerln exclusive-lock
                where rowid(Printerln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer printerln:handle, 'printer-fam/printer-order: ', substitute('&1/&2', vhPrinter-fam:buffer-value(), vhPrinter-order:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete printerln no-error.
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

