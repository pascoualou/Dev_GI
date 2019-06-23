/*------------------------------------------------------------------------
File        : bascule_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table bascule
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/bascule.i}
{application/include/error.i}
define variable ghttbascule as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudBascule private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteBascule.
    run updateBascule.
    run createBascule.
end procedure.

procedure setBascule:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttBascule.
    ghttBascule = phttBascule.
    run crudBascule.
    delete object phttBascule.
end procedure.

procedure readBascule:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table bascule Informations relatives à la bascule
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd as integer    no-undo.
    define input parameter table-handle phttBascule.
    define variable vhttBuffer as handle no-undo.
    define buffer bascule for bascule.

    vhttBuffer = phttBascule:default-buffer-handle.
    for first bascule no-lock
        where bascule.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer bascule:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttBascule no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getBascule:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table bascule Informations relatives à la bascule
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttBascule.
    define variable vhttBuffer as handle  no-undo.
    define buffer bascule for bascule.

    vhttBuffer = phttBascule:default-buffer-handle.
    for each bascule no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer bascule:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttBascule no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateBascule private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define buffer bascule for bascule.

    create query vhttquery.
    vhttBuffer = ghttBascule:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttBascule:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first bascule exclusive-lock
                where rowid(bascule) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer bascule:handle, 'soc-cd: ', substitute('&1', vhSoc-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer bascule:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createBascule private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer bascule for bascule.

    create query vhttquery.
    vhttBuffer = ghttBascule:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttBascule:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create bascule.
            if not outils:copyValidField(buffer bascule:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteBascule private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define buffer bascule for bascule.

    create query vhttquery.
    vhttBuffer = ghttBascule:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttBascule:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first bascule exclusive-lock
                where rowid(Bascule) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer bascule:handle, 'soc-cd: ', substitute('&1', vhSoc-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete bascule no-error.
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

