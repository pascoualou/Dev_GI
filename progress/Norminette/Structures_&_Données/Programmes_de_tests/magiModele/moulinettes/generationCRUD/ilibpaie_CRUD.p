/*------------------------------------------------------------------------
File        : ilibpaie_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ilibpaie
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ilibpaie.i}
{application/include/error.i}
define variable ghttilibpaie as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phLibpaie-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur libpaie-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'libpaie-cd' then phLibpaie-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIlibpaie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIlibpaie.
    run updateIlibpaie.
    run createIlibpaie.
end procedure.

procedure setIlibpaie:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIlibpaie.
    ghttIlibpaie = phttIlibpaie.
    run crudIlibpaie.
    delete object phttIlibpaie.
end procedure.

procedure readIlibpaie:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ilibpaie Liste des libelles de type de paiement.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piLibpaie-cd as integer    no-undo.
    define input parameter table-handle phttIlibpaie.
    define variable vhttBuffer as handle no-undo.
    define buffer ilibpaie for ilibpaie.

    vhttBuffer = phttIlibpaie:default-buffer-handle.
    for first ilibpaie no-lock
        where ilibpaie.libpaie-cd = piLibpaie-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibpaie:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibpaie no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIlibpaie:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ilibpaie Liste des libelles de type de paiement.
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIlibpaie.
    define variable vhttBuffer as handle  no-undo.
    define buffer ilibpaie for ilibpaie.

    vhttBuffer = phttIlibpaie:default-buffer-handle.
    for each ilibpaie no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibpaie:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibpaie no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIlibpaie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLibpaie-cd    as handle  no-undo.
    define buffer ilibpaie for ilibpaie.

    create query vhttquery.
    vhttBuffer = ghttIlibpaie:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIlibpaie:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLibpaie-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibpaie exclusive-lock
                where rowid(ilibpaie) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibpaie:handle, 'libpaie-cd: ', substitute('&1', vhLibpaie-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ilibpaie:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIlibpaie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ilibpaie for ilibpaie.

    create query vhttquery.
    vhttBuffer = ghttIlibpaie:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIlibpaie:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ilibpaie.
            if not outils:copyValidField(buffer ilibpaie:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIlibpaie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLibpaie-cd    as handle  no-undo.
    define buffer ilibpaie for ilibpaie.

    create query vhttquery.
    vhttBuffer = ghttIlibpaie:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIlibpaie:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLibpaie-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibpaie exclusive-lock
                where rowid(Ilibpaie) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibpaie:handle, 'libpaie-cd: ', substitute('&1', vhLibpaie-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ilibpaie no-error.
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

