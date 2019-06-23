/*------------------------------------------------------------------------
File        : ifdtprgt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifdtprgt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifdtprgt.i}
{application/include/error.i}
define variable ghttifdtprgt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTypergt-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur typergt-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'typergt-cd' then phTypergt-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfdtprgt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfdtprgt.
    run updateIfdtprgt.
    run createIfdtprgt.
end procedure.

procedure setIfdtprgt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfdtprgt.
    ghttIfdtprgt = phttIfdtprgt.
    run crudIfdtprgt.
    delete object phttIfdtprgt.
end procedure.

procedure readIfdtprgt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifdtprgt Table des types de regroupement
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piTypergt-cd as integer    no-undo.
    define input parameter table-handle phttIfdtprgt.
    define variable vhttBuffer as handle no-undo.
    define buffer ifdtprgt for ifdtprgt.

    vhttBuffer = phttIfdtprgt:default-buffer-handle.
    for first ifdtprgt no-lock
        where ifdtprgt.typergt-cd = piTypergt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdtprgt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdtprgt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfdtprgt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifdtprgt Table des types de regroupement
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfdtprgt.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifdtprgt for ifdtprgt.

    vhttBuffer = phttIfdtprgt:default-buffer-handle.
    for each ifdtprgt no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdtprgt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdtprgt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfdtprgt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTypergt-cd    as handle  no-undo.
    define buffer ifdtprgt for ifdtprgt.

    create query vhttquery.
    vhttBuffer = ghttIfdtprgt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfdtprgt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTypergt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdtprgt exclusive-lock
                where rowid(ifdtprgt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdtprgt:handle, 'typergt-cd: ', substitute('&1', vhTypergt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifdtprgt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfdtprgt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifdtprgt for ifdtprgt.

    create query vhttquery.
    vhttBuffer = ghttIfdtprgt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfdtprgt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifdtprgt.
            if not outils:copyValidField(buffer ifdtprgt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfdtprgt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTypergt-cd    as handle  no-undo.
    define buffer ifdtprgt for ifdtprgt.

    create query vhttquery.
    vhttBuffer = ghttIfdtprgt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfdtprgt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTypergt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdtprgt exclusive-lock
                where rowid(Ifdtprgt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdtprgt:handle, 'typergt-cd: ', substitute('&1', vhTypergt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifdtprgt no-error.
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

