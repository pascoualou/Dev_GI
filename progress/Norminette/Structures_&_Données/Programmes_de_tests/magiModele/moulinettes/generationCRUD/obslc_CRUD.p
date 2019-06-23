/*------------------------------------------------------------------------
File        : obslc_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table obslc
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/obslc.i}
{application/include/error.i}
define variable ghttobslc as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoobs as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noobs, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noobs' then phNoobs = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudObslc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteObslc.
    run updateObslc.
    run createObslc.
end procedure.

procedure setObslc:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttObslc.
    ghttObslc = phttObslc.
    run crudObslc.
    delete object phttObslc.
end procedure.

procedure readObslc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table obslc 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoobs as integer    no-undo.
    define input parameter table-handle phttObslc.
    define variable vhttBuffer as handle no-undo.
    define buffer obslc for obslc.

    vhttBuffer = phttObslc:default-buffer-handle.
    for first obslc no-lock
        where obslc.noobs = piNoobs:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer obslc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttObslc no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getObslc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table obslc 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttObslc.
    define variable vhttBuffer as handle  no-undo.
    define buffer obslc for obslc.

    vhttBuffer = phttObslc:default-buffer-handle.
    for each obslc no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer obslc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttObslc no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateObslc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoobs    as handle  no-undo.
    define buffer obslc for obslc.

    create query vhttquery.
    vhttBuffer = ghttObslc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttObslc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoobs).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first obslc exclusive-lock
                where rowid(obslc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer obslc:handle, 'noobs: ', substitute('&1', vhNoobs:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer obslc:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createObslc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer obslc for obslc.

    create query vhttquery.
    vhttBuffer = ghttObslc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttObslc:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create obslc.
            if not outils:copyValidField(buffer obslc:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteObslc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoobs    as handle  no-undo.
    define buffer obslc for obslc.

    create query vhttquery.
    vhttBuffer = ghttObslc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttObslc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoobs).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first obslc exclusive-lock
                where rowid(Obslc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer obslc:handle, 'noobs: ', substitute('&1', vhNoobs:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete obslc no-error.
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

