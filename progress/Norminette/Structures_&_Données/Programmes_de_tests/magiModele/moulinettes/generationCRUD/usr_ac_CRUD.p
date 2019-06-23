/*------------------------------------------------------------------------
File        : usr_ac_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table usr_ac
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/usr_ac.i}
{application/include/error.i}
define variable ghttusr_ac as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCduti as handle, output phNmtbl as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur CdUti/NmTbl, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'CdUti' then phCduti = phBuffer:buffer-field(vi).
            when 'NmTbl' then phNmtbl = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudUsr_ac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteUsr_ac.
    run updateUsr_ac.
    run createUsr_ac.
end procedure.

procedure setUsr_ac:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttUsr_ac.
    ghttUsr_ac = phttUsr_ac.
    run crudUsr_ac.
    delete object phttUsr_ac.
end procedure.

procedure readUsr_ac:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table usr_ac 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCduti as character  no-undo.
    define input parameter pcNmtbl as character  no-undo.
    define input parameter table-handle phttUsr_ac.
    define variable vhttBuffer as handle no-undo.
    define buffer usr_ac for usr_ac.

    vhttBuffer = phttUsr_ac:default-buffer-handle.
    for first usr_ac no-lock
        where usr_ac.CdUti = pcCduti
          and usr_ac.NmTbl = pcNmtbl:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer usr_ac:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttUsr_ac no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getUsr_ac:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table usr_ac 
    Notes  : service externe. Critère pcCduti = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCduti as character  no-undo.
    define input parameter table-handle phttUsr_ac.
    define variable vhttBuffer as handle  no-undo.
    define buffer usr_ac for usr_ac.

    vhttBuffer = phttUsr_ac:default-buffer-handle.
    if pcCduti = ?
    then for each usr_ac no-lock
        where usr_ac.CdUti = pcCduti:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer usr_ac:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each usr_ac no-lock
        where usr_ac.CdUti = pcCduti:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer usr_ac:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttUsr_ac no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateUsr_ac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCduti    as handle  no-undo.
    define variable vhNmtbl    as handle  no-undo.
    define buffer usr_ac for usr_ac.

    create query vhttquery.
    vhttBuffer = ghttUsr_ac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttUsr_ac:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCduti, output vhNmtbl).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first usr_ac exclusive-lock
                where rowid(usr_ac) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer usr_ac:handle, 'CdUti/NmTbl: ', substitute('&1/&2', vhCduti:buffer-value(), vhNmtbl:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer usr_ac:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createUsr_ac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer usr_ac for usr_ac.

    create query vhttquery.
    vhttBuffer = ghttUsr_ac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttUsr_ac:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create usr_ac.
            if not outils:copyValidField(buffer usr_ac:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteUsr_ac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCduti    as handle  no-undo.
    define variable vhNmtbl    as handle  no-undo.
    define buffer usr_ac for usr_ac.

    create query vhttquery.
    vhttBuffer = ghttUsr_ac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttUsr_ac:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCduti, output vhNmtbl).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first usr_ac exclusive-lock
                where rowid(Usr_ac) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer usr_ac:handle, 'CdUti/NmTbl: ', substitute('&1/&2', vhCduti:buffer-value(), vhNmtbl:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete usr_ac no-error.
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

