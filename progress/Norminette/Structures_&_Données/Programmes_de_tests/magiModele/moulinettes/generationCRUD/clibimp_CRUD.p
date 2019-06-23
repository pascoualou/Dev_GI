/*------------------------------------------------------------------------
File        : clibimp_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table clibimp
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/clibimp.i}
{application/include/error.i}
define variable ghttclibimp as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phLibimp-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur libimp-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'libimp-cd' then phLibimp-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudClibimp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteClibimp.
    run updateClibimp.
    run createClibimp.
end procedure.

procedure setClibimp:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttClibimp.
    ghttClibimp = phttClibimp.
    run crudClibimp.
    delete object phttClibimp.
end procedure.

procedure readClibimp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table clibimp Liste des libelles des imputations analytiques
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piLibimp-cd as integer    no-undo.
    define input parameter table-handle phttClibimp.
    define variable vhttBuffer as handle no-undo.
    define buffer clibimp for clibimp.

    vhttBuffer = phttClibimp:default-buffer-handle.
    for first clibimp no-lock
        where clibimp.libimp-cd = piLibimp-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer clibimp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttClibimp no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getClibimp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table clibimp Liste des libelles des imputations analytiques
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttClibimp.
    define variable vhttBuffer as handle  no-undo.
    define buffer clibimp for clibimp.

    vhttBuffer = phttClibimp:default-buffer-handle.
    for each clibimp no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer clibimp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttClibimp no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateClibimp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLibimp-cd    as handle  no-undo.
    define buffer clibimp for clibimp.

    create query vhttquery.
    vhttBuffer = ghttClibimp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttClibimp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLibimp-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first clibimp exclusive-lock
                where rowid(clibimp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer clibimp:handle, 'libimp-cd: ', substitute('&1', vhLibimp-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer clibimp:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createClibimp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer clibimp for clibimp.

    create query vhttquery.
    vhttBuffer = ghttClibimp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttClibimp:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create clibimp.
            if not outils:copyValidField(buffer clibimp:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteClibimp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLibimp-cd    as handle  no-undo.
    define buffer clibimp for clibimp.

    create query vhttquery.
    vhttBuffer = ghttClibimp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttClibimp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLibimp-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first clibimp exclusive-lock
                where rowid(Clibimp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer clibimp:handle, 'libimp-cd: ', substitute('&1', vhLibimp-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete clibimp no-error.
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

