/*------------------------------------------------------------------------
File        : crblog_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table crblog
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/crblog.i}
{application/include/error.i}
define variable ghttcrblog as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phLog-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/log-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'log-cle' then phLog-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCrblog private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCrblog.
    run updateCrblog.
    run createCrblog.
end procedure.

procedure setCrblog:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCrblog.
    ghttCrblog = phttCrblog.
    run crudCrblog.
    delete object phttCrblog.
end procedure.

procedure readCrblog:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table crblog 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter pcLog-cle as character  no-undo.
    define input parameter table-handle phttCrblog.
    define variable vhttBuffer as handle no-undo.
    define buffer crblog for crblog.

    vhttBuffer = phttCrblog:default-buffer-handle.
    for first crblog no-lock
        where crblog.soc-cd = piSoc-cd
          and crblog.log-cle = pcLog-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crblog:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCrblog no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCrblog:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table crblog 
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter table-handle phttCrblog.
    define variable vhttBuffer as handle  no-undo.
    define buffer crblog for crblog.

    vhttBuffer = phttCrblog:default-buffer-handle.
    if piSoc-cd = ?
    then for each crblog no-lock
        where crblog.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crblog:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each crblog no-lock
        where crblog.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crblog:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCrblog no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCrblog private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhLog-cle    as handle  no-undo.
    define buffer crblog for crblog.

    create query vhttquery.
    vhttBuffer = ghttCrblog:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCrblog:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhLog-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first crblog exclusive-lock
                where rowid(crblog) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer crblog:handle, 'soc-cd/log-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhLog-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer crblog:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCrblog private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer crblog for crblog.

    create query vhttquery.
    vhttBuffer = ghttCrblog:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCrblog:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create crblog.
            if not outils:copyValidField(buffer crblog:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCrblog private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhLog-cle    as handle  no-undo.
    define buffer crblog for crblog.

    create query vhttquery.
    vhttBuffer = ghttCrblog:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCrblog:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhLog-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first crblog exclusive-lock
                where rowid(Crblog) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer crblog:handle, 'soc-cd/log-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhLog-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete crblog no-error.
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

