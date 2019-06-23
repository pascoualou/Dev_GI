/*------------------------------------------------------------------------
File        : iautoref_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iautoref
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iautoref.i}
{application/include/error.i}
define variable ghttiautoref as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCmodule as handle, output phIreference as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cModule/iReference, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cModule' then phCmodule = phBuffer:buffer-field(vi).
            when 'iReference' then phIreference = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIautoref private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIautoref.
    run updateIautoref.
    run createIautoref.
end procedure.

procedure setIautoref:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIautoref.
    ghttIautoref = phttIautoref.
    run crudIautoref.
    delete object phttIautoref.
end procedure.

procedure readIautoref:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iautoref 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCmodule    as character  no-undo.
    define input parameter piIreference as integer    no-undo.
    define input parameter table-handle phttIautoref.
    define variable vhttBuffer as handle no-undo.
    define buffer iautoref for iautoref.

    vhttBuffer = phttIautoref:default-buffer-handle.
    for first iautoref no-lock
        where iautoref.cModule = pcCmodule
          and iautoref.iReference = piIreference:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iautoref:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIautoref no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIautoref:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iautoref 
    Notes  : service externe. Critère pcCmodule = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCmodule    as character  no-undo.
    define input parameter table-handle phttIautoref.
    define variable vhttBuffer as handle  no-undo.
    define buffer iautoref for iautoref.

    vhttBuffer = phttIautoref:default-buffer-handle.
    if pcCmodule = ?
    then for each iautoref no-lock
        where iautoref.cModule = pcCmodule:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iautoref:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iautoref no-lock
        where iautoref.cModule = pcCmodule:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iautoref:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIautoref no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIautoref private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCmodule    as handle  no-undo.
    define variable vhIreference    as handle  no-undo.
    define buffer iautoref for iautoref.

    create query vhttquery.
    vhttBuffer = ghttIautoref:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIautoref:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCmodule, output vhIreference).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iautoref exclusive-lock
                where rowid(iautoref) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iautoref:handle, 'cModule/iReference: ', substitute('&1/&2', vhCmodule:buffer-value(), vhIreference:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iautoref:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIautoref private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iautoref for iautoref.

    create query vhttquery.
    vhttBuffer = ghttIautoref:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIautoref:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iautoref.
            if not outils:copyValidField(buffer iautoref:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIautoref private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCmodule    as handle  no-undo.
    define variable vhIreference    as handle  no-undo.
    define buffer iautoref for iautoref.

    create query vhttquery.
    vhttBuffer = ghttIautoref:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIautoref:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCmodule, output vhIreference).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iautoref exclusive-lock
                where rowid(Iautoref) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iautoref:handle, 'cModule/iReference: ', substitute('&1/&2', vhCmodule:buffer-value(), vhIreference:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iautoref no-error.
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

