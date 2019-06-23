/*------------------------------------------------------------------------
File        : com_pg_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table com_pg
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/com_pg.i}
{application/include/error.i}
define variable ghttcom_pg as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTppar as handle, output phCdpar as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tppar/cdpar, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tppar' then phTppar = phBuffer:buffer-field(vi).
            when 'cdpar' then phCdpar = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCom_pg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCom_pg.
    run updateCom_pg.
    run createCom_pg.
end procedure.

procedure setCom_pg:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCom_pg.
    ghttCom_pg = phttCom_pg.
    run crudCom_pg.
    delete object phttCom_pg.
end procedure.

procedure readCom_pg:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table com_pg 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTppar as character  no-undo.
    define input parameter pcCdpar as character  no-undo.
    define input parameter table-handle phttCom_pg.
    define variable vhttBuffer as handle no-undo.
    define buffer com_pg for com_pg.

    vhttBuffer = phttCom_pg:default-buffer-handle.
    for first com_pg no-lock
        where com_pg.tppar = pcTppar
          and com_pg.cdpar = pcCdpar:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer com_pg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCom_pg no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCom_pg:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table com_pg 
    Notes  : service externe. Critère pcTppar = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTppar as character  no-undo.
    define input parameter table-handle phttCom_pg.
    define variable vhttBuffer as handle  no-undo.
    define buffer com_pg for com_pg.

    vhttBuffer = phttCom_pg:default-buffer-handle.
    if pcTppar = ?
    then for each com_pg no-lock
        where com_pg.tppar = pcTppar:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer com_pg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each com_pg no-lock
        where com_pg.tppar = pcTppar:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer com_pg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCom_pg no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCom_pg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTppar    as handle  no-undo.
    define variable vhCdpar    as handle  no-undo.
    define buffer com_pg for com_pg.

    create query vhttquery.
    vhttBuffer = ghttCom_pg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCom_pg:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTppar, output vhCdpar).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first com_pg exclusive-lock
                where rowid(com_pg) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer com_pg:handle, 'tppar/cdpar: ', substitute('&1/&2', vhTppar:buffer-value(), vhCdpar:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer com_pg:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCom_pg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer com_pg for com_pg.

    create query vhttquery.
    vhttBuffer = ghttCom_pg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCom_pg:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create com_pg.
            if not outils:copyValidField(buffer com_pg:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCom_pg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTppar    as handle  no-undo.
    define variable vhCdpar    as handle  no-undo.
    define buffer com_pg for com_pg.

    create query vhttquery.
    vhttBuffer = ghttCom_pg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCom_pg:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTppar, output vhCdpar).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first com_pg exclusive-lock
                where rowid(Com_pg) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer com_pg:handle, 'tppar/cdpar: ', substitute('&1/&2', vhTppar:buffer-value(), vhCdpar:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete com_pg no-error.
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

