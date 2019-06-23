/*------------------------------------------------------------------------
File        : ilibcred_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ilibcred
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ilibcred.i}
{application/include/error.i}
define variable ghttilibcred as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phAsscred-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/asscred-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'asscred-cd' then phAsscred-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIlibcred private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIlibcred.
    run updateIlibcred.
    run createIlibcred.
end procedure.

procedure setIlibcred:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIlibcred.
    ghttIlibcred = phttIlibcred.
    run crudIlibcred.
    delete object phttIlibcred.
end procedure.

procedure readIlibcred:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ilibcred Libelle assurance credit
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piAsscred-cd as integer    no-undo.
    define input parameter table-handle phttIlibcred.
    define variable vhttBuffer as handle no-undo.
    define buffer ilibcred for ilibcred.

    vhttBuffer = phttIlibcred:default-buffer-handle.
    for first ilibcred no-lock
        where ilibcred.soc-cd = piSoc-cd
          and ilibcred.asscred-cd = piAsscred-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibcred:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibcred no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIlibcred:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ilibcred Libelle assurance credit
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter table-handle phttIlibcred.
    define variable vhttBuffer as handle  no-undo.
    define buffer ilibcred for ilibcred.

    vhttBuffer = phttIlibcred:default-buffer-handle.
    if piSoc-cd = ?
    then for each ilibcred no-lock
        where ilibcred.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibcred:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ilibcred no-lock
        where ilibcred.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibcred:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibcred no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIlibcred private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhAsscred-cd    as handle  no-undo.
    define buffer ilibcred for ilibcred.

    create query vhttquery.
    vhttBuffer = ghttIlibcred:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIlibcred:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhAsscred-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibcred exclusive-lock
                where rowid(ilibcred) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibcred:handle, 'soc-cd/asscred-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhAsscred-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ilibcred:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIlibcred private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ilibcred for ilibcred.

    create query vhttquery.
    vhttBuffer = ghttIlibcred:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIlibcred:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ilibcred.
            if not outils:copyValidField(buffer ilibcred:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIlibcred private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhAsscred-cd    as handle  no-undo.
    define buffer ilibcred for ilibcred.

    create query vhttquery.
    vhttBuffer = ghttIlibcred:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIlibcred:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhAsscred-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibcred exclusive-lock
                where rowid(Ilibcred) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibcred:handle, 'soc-cd/asscred-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhAsscred-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ilibcred no-error.
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

