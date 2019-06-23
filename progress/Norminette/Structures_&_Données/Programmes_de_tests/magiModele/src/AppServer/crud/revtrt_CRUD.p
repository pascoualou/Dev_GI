/*------------------------------------------------------------------------
File        : revtrt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table revtrt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/06/18 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}       // Doit être positionnée juste après using
define variable ghttrevtrt as handle no-undo.     // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phInotrtrev as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur inotrtrev, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'inotrtrev' then phInotrtrev = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudRevtrt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteRevtrt.
    run updateRevtrt.
    run createRevtrt.
end procedure.

procedure setRevtrt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRevtrt.
    ghttRevtrt = phttRevtrt.
    run crudRevtrt.
    delete object phttRevtrt.
end procedure.

procedure readRevtrt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table revtrt 0908/0110 - révisions legales / conventionnelles
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piInotrtrev as integer  no-undo.
    define input parameter table-handle phttRevtrt.

    define variable vhttBuffer as handle no-undo.
    define buffer revtrt for revtrt.

    vhttBuffer = phttRevtrt:default-buffer-handle.
    for first revtrt no-lock
        where revtrt.inotrtrev = piInotrtrev:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer revtrt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRevtrt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getRevtrt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table revtrt 0908/0110 - révisions legales / conventionnelles
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRevtrt.

    define variable vhttBuffer as handle  no-undo.
    define buffer revtrt for revtrt.

    vhttBuffer = phttRevtrt:default-buffer-handle.
    for each revtrt no-lock:                                      // fonctionnellement, aucun intérêt.
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer revtrt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRevtrt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure getRevtrtSurContrat:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table revtrt
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character no-undo.
    define input parameter piNocon as int64     no-undo.
    define input parameter pcCdtrt as character no-undo.
    define input parameter piNotrt as integer   no-undo.
    define input parameter table-handle phttRevtrt.

    define variable vhttBuffer as handle  no-undo.
    define buffer revtrt for revtrt.

    vhttBuffer = phttRevtrt:default-buffer-handle.
    if piNotrt = ? and pcCdtrt = ?
    then for each revtrt no-lock
        where revtrt.tpcon = pcTpcon
          and revtrt.nocon = piNocon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer revtrt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else if piNotrt = ?
    then for each revtrt no-lock
        where revtrt.tpcon = pcTpcon
          and revtrt.nocon = piNocon
          and revtrt.cdtrt = pcCdtrt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer revtrt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each revtrt no-lock
        where revtrt.tpcon = pcTpcon
          and revtrt.nocon = piNocon
          and revtrt.cdtrt = pcCdtrt
          and revtrt.notrt = piNotrt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer revtrt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRevtrt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateRevtrt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery   as handle  no-undo.
    define variable vhttBuffer  as handle  no-undo.
    define variable vhInotrtrev as handle  no-undo.
    define buffer revtrt for revtrt.

    create query vhttquery.
    vhttBuffer = ghttRevtrt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttRevtrt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhInotrtrev).

blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first revtrt exclusive-lock
                where rowid(revtrt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer revtrt:handle, 'inotrtrev: ', substitute('&1', vhInotrtrev:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer revtrt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createRevtrt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer revtrt for revtrt.

    create query vhttquery.
    vhttBuffer = ghttRevtrt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttRevtrt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create revtrt.
            if not outils:copyValidField(buffer revtrt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteRevtrt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery   as handle  no-undo.
    define variable vhttBuffer  as handle  no-undo.
    define variable vhInotrtrev as handle  no-undo.
    define buffer revtrt for revtrt.

    create query vhttquery.
    vhttBuffer = ghttRevtrt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttRevtrt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhInotrtrev).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first revtrt exclusive-lock
                where rowid(Revtrt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer revtrt:handle, 'inotrtrev: ', substitute('&1', vhInotrtrev:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete revtrt no-error.
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

procedure deleteRevtrtSurContrat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.

    define buffer revtrt for revtrt.

blocTrans:
    do transaction:
        for each revtrt exclusive-lock   
           where revtrt.tpcon = pcTypeContrat
             and revtrt.nocon = piNumeroContrat:
            delete revtrt no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status
end procedure.
