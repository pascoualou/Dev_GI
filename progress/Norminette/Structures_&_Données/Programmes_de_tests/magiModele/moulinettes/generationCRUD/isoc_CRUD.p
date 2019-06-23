/*------------------------------------------------------------------------
File        : isoc_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table isoc
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/isoc.i}
{application/include/error.i}
define variable ghttisoc as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIsoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIsoc.
    run updateIsoc.
    run createIsoc.
end procedure.

procedure setIsoc:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIsoc.
    ghttIsoc = phttIsoc.
    run crudIsoc.
    delete object phttIsoc.
end procedure.

procedure readIsoc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table isoc Informations administratives et juridiques pour une societe
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd as integer    no-undo.
    define input parameter table-handle phttIsoc.
    define variable vhttBuffer as handle no-undo.
    define buffer isoc for isoc.

    vhttBuffer = phttIsoc:default-buffer-handle.
    for first isoc no-lock
        where isoc.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer isoc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIsoc no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIsoc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table isoc Informations administratives et juridiques pour une societe
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIsoc.
    define variable vhttBuffer as handle  no-undo.
    define buffer isoc for isoc.

    vhttBuffer = phttIsoc:default-buffer-handle.
    for each isoc no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer isoc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIsoc no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIsoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define buffer isoc for isoc.

    create query vhttquery.
    vhttBuffer = ghttIsoc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIsoc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first isoc exclusive-lock
                where rowid(isoc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer isoc:handle, 'soc-cd: ', substitute('&1', vhSoc-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer isoc:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIsoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer isoc for isoc.

    create query vhttquery.
    vhttBuffer = ghttIsoc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIsoc:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create isoc.
            if not outils:copyValidField(buffer isoc:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIsoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define buffer isoc for isoc.

    create query vhttquery.
    vhttBuffer = ghttIsoc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIsoc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first isoc exclusive-lock
                where rowid(Isoc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer isoc:handle, 'soc-cd: ', substitute('&1', vhSoc-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete isoc no-error.
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

