/*------------------------------------------------------------------------
File        : scprt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table scprt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/scprt.i}
{application/include/error.i}
define variable ghttscprt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNosoc as handle, output phDtope as handle, output phNomin as handle, output phCdope as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nosoc/dtope/nomin/cdope, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nosoc' then phNosoc = phBuffer:buffer-field(vi).
            when 'dtope' then phDtope = phBuffer:buffer-field(vi).
            when 'nomin' then phNomin = phBuffer:buffer-field(vi).
            when 'cdope' then phCdope = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudScprt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteScprt.
    run updateScprt.
    run createScprt.
end procedure.

procedure setScprt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttScprt.
    ghttScprt = phttScprt.
    run crudScprt.
    delete object phttScprt.
end procedure.

procedure readScprt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table scprt Mouvements des parts de société
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNosoc as integer    no-undo.
    define input parameter pdaDtope as date       no-undo.
    define input parameter piNomin as integer    no-undo.
    define input parameter pcCdope as character  no-undo.
    define input parameter table-handle phttScprt.
    define variable vhttBuffer as handle no-undo.
    define buffer scprt for scprt.

    vhttBuffer = phttScprt:default-buffer-handle.
    for first scprt no-lock
        where scprt.nosoc = piNosoc
          and scprt.dtope = pdaDtope
          and scprt.nomin = piNomin
          and scprt.cdope = pcCdope:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer scprt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttScprt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getScprt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table scprt Mouvements des parts de société
    Notes  : service externe. Critère piNomin = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNosoc as integer    no-undo.
    define input parameter pdaDtope as date       no-undo.
    define input parameter piNomin as integer    no-undo.
    define input parameter table-handle phttScprt.
    define variable vhttBuffer as handle  no-undo.
    define buffer scprt for scprt.

    vhttBuffer = phttScprt:default-buffer-handle.
    if piNomin = ?
    then for each scprt no-lock
        where scprt.nosoc = piNosoc
          and scprt.dtope = pdaDtope:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer scprt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each scprt no-lock
        where scprt.nosoc = piNosoc
          and scprt.dtope = pdaDtope
          and scprt.nomin = piNomin:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer scprt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttScprt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateScprt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNosoc    as handle  no-undo.
    define variable vhDtope    as handle  no-undo.
    define variable vhNomin    as handle  no-undo.
    define variable vhCdope    as handle  no-undo.
    define buffer scprt for scprt.

    create query vhttquery.
    vhttBuffer = ghttScprt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttScprt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNosoc, output vhDtope, output vhNomin, output vhCdope).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first scprt exclusive-lock
                where rowid(scprt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer scprt:handle, 'nosoc/dtope/nomin/cdope: ', substitute('&1/&2/&3/&4', vhNosoc:buffer-value(), vhDtope:buffer-value(), vhNomin:buffer-value(), vhCdope:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer scprt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createScprt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer scprt for scprt.

    create query vhttquery.
    vhttBuffer = ghttScprt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttScprt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create scprt.
            if not outils:copyValidField(buffer scprt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteScprt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNosoc    as handle  no-undo.
    define variable vhDtope    as handle  no-undo.
    define variable vhNomin    as handle  no-undo.
    define variable vhCdope    as handle  no-undo.
    define buffer scprt for scprt.

    create query vhttquery.
    vhttBuffer = ghttScprt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttScprt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNosoc, output vhDtope, output vhNomin, output vhCdope).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first scprt exclusive-lock
                where rowid(Scprt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer scprt:handle, 'nosoc/dtope/nomin/cdope: ', substitute('&1/&2/&3/&4', vhNosoc:buffer-value(), vhDtope:buffer-value(), vhNomin:buffer-value(), vhCdope:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete scprt no-error.
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

