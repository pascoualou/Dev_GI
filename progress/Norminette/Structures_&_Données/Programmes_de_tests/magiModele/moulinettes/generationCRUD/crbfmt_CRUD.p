/*------------------------------------------------------------------------
File        : crbfmt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table crbfmt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/crbfmt.i}
{application/include/error.i}
define variable ghttcrbfmt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phLog-cle as handle, output phPosdeb as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/log-cle/posdeb, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'log-cle' then phLog-cle = phBuffer:buffer-field(vi).
            when 'posdeb' then phPosdeb = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCrbfmt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCrbfmt.
    run updateCrbfmt.
    run createCrbfmt.
end procedure.

procedure setCrbfmt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCrbfmt.
    ghttCrbfmt = phttCrbfmt.
    run crudCrbfmt.
    delete object phttCrbfmt.
end procedure.

procedure readCrbfmt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table crbfmt 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter pcLog-cle as character  no-undo.
    define input parameter piPosdeb  as integer    no-undo.
    define input parameter table-handle phttCrbfmt.
    define variable vhttBuffer as handle no-undo.
    define buffer crbfmt for crbfmt.

    vhttBuffer = phttCrbfmt:default-buffer-handle.
    for first crbfmt no-lock
        where crbfmt.soc-cd = piSoc-cd
          and crbfmt.log-cle = pcLog-cle
          and crbfmt.posdeb = piPosdeb:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crbfmt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCrbfmt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCrbfmt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table crbfmt 
    Notes  : service externe. Critère pcLog-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter pcLog-cle as character  no-undo.
    define input parameter table-handle phttCrbfmt.
    define variable vhttBuffer as handle  no-undo.
    define buffer crbfmt for crbfmt.

    vhttBuffer = phttCrbfmt:default-buffer-handle.
    if pcLog-cle = ?
    then for each crbfmt no-lock
        where crbfmt.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crbfmt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each crbfmt no-lock
        where crbfmt.soc-cd = piSoc-cd
          and crbfmt.log-cle = pcLog-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crbfmt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCrbfmt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCrbfmt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhLog-cle    as handle  no-undo.
    define variable vhPosdeb    as handle  no-undo.
    define buffer crbfmt for crbfmt.

    create query vhttquery.
    vhttBuffer = ghttCrbfmt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCrbfmt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhLog-cle, output vhPosdeb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first crbfmt exclusive-lock
                where rowid(crbfmt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer crbfmt:handle, 'soc-cd/log-cle/posdeb: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhLog-cle:buffer-value(), vhPosdeb:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer crbfmt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCrbfmt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer crbfmt for crbfmt.

    create query vhttquery.
    vhttBuffer = ghttCrbfmt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCrbfmt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create crbfmt.
            if not outils:copyValidField(buffer crbfmt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCrbfmt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhLog-cle    as handle  no-undo.
    define variable vhPosdeb    as handle  no-undo.
    define buffer crbfmt for crbfmt.

    create query vhttquery.
    vhttBuffer = ghttCrbfmt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCrbfmt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhLog-cle, output vhPosdeb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first crbfmt exclusive-lock
                where rowid(Crbfmt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer crbfmt:handle, 'soc-cd/log-cle/posdeb: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhLog-cle:buffer-value(), vhPosdeb:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete crbfmt no-error.
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

