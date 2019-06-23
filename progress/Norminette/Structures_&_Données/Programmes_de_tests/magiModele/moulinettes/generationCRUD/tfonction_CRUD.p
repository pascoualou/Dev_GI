/*------------------------------------------------------------------------
File        : tfonction_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table tfonction
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/tfonction.i}
{application/include/error.i}
define variable ghtttfonction as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoite as handle, output phCode_fonction as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noite/code_fonction, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noite' then phNoite = phBuffer:buffer-field(vi).
            when 'code_fonction' then phCode_fonction = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTfonction private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTfonction.
    run updateTfonction.
    run createTfonction.
end procedure.

procedure setTfonction:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTfonction.
    ghttTfonction = phttTfonction.
    run crudTfonction.
    delete object phttTfonction.
end procedure.

procedure readTfonction:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table tfonction 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoite         as integer    no-undo.
    define input parameter pcCode_fonction as character  no-undo.
    define input parameter table-handle phttTfonction.
    define variable vhttBuffer as handle no-undo.
    define buffer tfonction for tfonction.

    vhttBuffer = phttTfonction:default-buffer-handle.
    for first tfonction no-lock
        where tfonction.noite = piNoite
          and tfonction.code_fonction = pcCode_fonction:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tfonction:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTfonction no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTfonction:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table tfonction 
    Notes  : service externe. Critère piNoite = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoite         as integer    no-undo.
    define input parameter table-handle phttTfonction.
    define variable vhttBuffer as handle  no-undo.
    define buffer tfonction for tfonction.

    vhttBuffer = phttTfonction:default-buffer-handle.
    if piNoite = ?
    then for each tfonction no-lock
        where tfonction.noite = piNoite:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tfonction:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each tfonction no-lock
        where tfonction.noite = piNoite:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tfonction:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTfonction no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTfonction private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoite    as handle  no-undo.
    define variable vhCode_fonction    as handle  no-undo.
    define buffer tfonction for tfonction.

    create query vhttquery.
    vhttBuffer = ghttTfonction:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTfonction:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoite, output vhCode_fonction).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tfonction exclusive-lock
                where rowid(tfonction) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tfonction:handle, 'noite/code_fonction: ', substitute('&1/&2', vhNoite:buffer-value(), vhCode_fonction:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer tfonction:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTfonction private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer tfonction for tfonction.

    create query vhttquery.
    vhttBuffer = ghttTfonction:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTfonction:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create tfonction.
            if not outils:copyValidField(buffer tfonction:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTfonction private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoite    as handle  no-undo.
    define variable vhCode_fonction    as handle  no-undo.
    define buffer tfonction for tfonction.

    create query vhttquery.
    vhttBuffer = ghttTfonction:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTfonction:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoite, output vhCode_fonction).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tfonction exclusive-lock
                where rowid(Tfonction) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tfonction:handle, 'noite/code_fonction: ', substitute('&1/&2', vhNoite:buffer-value(), vhCode_fonction:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete tfonction no-error.
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

