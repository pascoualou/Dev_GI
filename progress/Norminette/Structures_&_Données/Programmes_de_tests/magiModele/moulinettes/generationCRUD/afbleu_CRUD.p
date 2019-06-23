/*------------------------------------------------------------------------
File        : afbleu_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table afbleu
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/afbleu.i}
{application/include/error.i}
define variable ghttafbleu as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCfb-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cfb-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cfb-cd' then phCfb-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAfbleu private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAfbleu.
    run updateAfbleu.
    run createAfbleu.
end procedure.

procedure setAfbleu:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAfbleu.
    ghttAfbleu = phttAfbleu.
    run crudAfbleu.
    delete object phttAfbleu.
end procedure.

procedure readAfbleu:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table afbleu 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCfb-cd as character  no-undo.
    define input parameter table-handle phttAfbleu.
    define variable vhttBuffer as handle no-undo.
    define buffer afbleu for afbleu.

    vhttBuffer = phttAfbleu:default-buffer-handle.
    for first afbleu no-lock
        where afbleu.cfb-cd = pcCfb-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer afbleu:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAfbleu no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAfbleu:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table afbleu 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAfbleu.
    define variable vhttBuffer as handle  no-undo.
    define buffer afbleu for afbleu.

    vhttBuffer = phttAfbleu:default-buffer-handle.
    for each afbleu no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer afbleu:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAfbleu no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAfbleu private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCfb-cd    as handle  no-undo.
    define buffer afbleu for afbleu.

    create query vhttquery.
    vhttBuffer = ghttAfbleu:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAfbleu:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCfb-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first afbleu exclusive-lock
                where rowid(afbleu) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer afbleu:handle, 'cfb-cd: ', substitute('&1', vhCfb-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer afbleu:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAfbleu private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer afbleu for afbleu.

    create query vhttquery.
    vhttBuffer = ghttAfbleu:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAfbleu:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create afbleu.
            if not outils:copyValidField(buffer afbleu:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAfbleu private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCfb-cd    as handle  no-undo.
    define buffer afbleu for afbleu.

    create query vhttquery.
    vhttBuffer = ghttAfbleu:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAfbleu:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCfb-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first afbleu exclusive-lock
                where rowid(Afbleu) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer afbleu:handle, 'cfb-cd: ', substitute('&1', vhCfb-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete afbleu no-error.
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

