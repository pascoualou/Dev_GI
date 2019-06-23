/*------------------------------------------------------------------------
File        : SQDOC_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table SQDOC
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/SQDOC.i}
{application/include/error.i}
define variable ghttSQDOC as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoseq as handle, output phLbseq as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur NOSEQ/LBSEQ, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'NOSEQ' then phNoseq = phBuffer:buffer-field(vi).
            when 'LBSEQ' then phLbseq = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSqdoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSqdoc.
    run updateSqdoc.
    run createSqdoc.
end procedure.

procedure setSqdoc:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSqdoc.
    ghttSqdoc = phttSqdoc.
    run crudSqdoc.
    delete object phttSqdoc.
end procedure.

procedure readSqdoc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table SQDOC 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoseq as integer    no-undo.
    define input parameter pcLbseq as character  no-undo.
    define input parameter table-handle phttSqdoc.
    define variable vhttBuffer as handle no-undo.
    define buffer SQDOC for SQDOC.

    vhttBuffer = phttSqdoc:default-buffer-handle.
    for first SQDOC no-lock
        where SQDOC.NOSEQ = piNoseq
          and SQDOC.LBSEQ = pcLbseq:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer SQDOC:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSqdoc no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSqdoc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table SQDOC 
    Notes  : service externe. Critère piNoseq = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoseq as integer    no-undo.
    define input parameter table-handle phttSqdoc.
    define variable vhttBuffer as handle  no-undo.
    define buffer SQDOC for SQDOC.

    vhttBuffer = phttSqdoc:default-buffer-handle.
    if piNoseq = ?
    then for each SQDOC no-lock
        where SQDOC.NOSEQ = piNoseq:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer SQDOC:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each SQDOC no-lock
        where SQDOC.NOSEQ = piNoseq:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer SQDOC:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSqdoc no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSqdoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoseq    as handle  no-undo.
    define variable vhLbseq    as handle  no-undo.
    define buffer SQDOC for SQDOC.

    create query vhttquery.
    vhttBuffer = ghttSqdoc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSqdoc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoseq, output vhLbseq).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first SQDOC exclusive-lock
                where rowid(SQDOC) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer SQDOC:handle, 'NOSEQ/LBSEQ: ', substitute('&1/&2', vhNoseq:buffer-value(), vhLbseq:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer SQDOC:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSqdoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer SQDOC for SQDOC.

    create query vhttquery.
    vhttBuffer = ghttSqdoc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSqdoc:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create SQDOC.
            if not outils:copyValidField(buffer SQDOC:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSqdoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoseq    as handle  no-undo.
    define variable vhLbseq    as handle  no-undo.
    define buffer SQDOC for SQDOC.

    create query vhttquery.
    vhttBuffer = ghttSqdoc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSqdoc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoseq, output vhLbseq).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first SQDOC exclusive-lock
                where rowid(Sqdoc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer SQDOC:handle, 'NOSEQ/LBSEQ: ', substitute('&1/&2', vhNoseq:buffer-value(), vhLbseq:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete SQDOC no-error.
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

