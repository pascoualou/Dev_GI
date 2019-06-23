/*------------------------------------------------------------------------
File        : scprthist_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table scprthist
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/scprthist.i}
{application/include/error.i}
define variable ghttscprthist as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNosoc as handle, output phDthist as handle, output phDtope as handle, output phNomin as handle, output phCdope as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nosoc/dthist/dtope/nomin/cdope, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nosoc' then phNosoc = phBuffer:buffer-field(vi).
            when 'dthist' then phDthist = phBuffer:buffer-field(vi).
            when 'dtope' then phDtope = phBuffer:buffer-field(vi).
            when 'nomin' then phNomin = phBuffer:buffer-field(vi).
            when 'cdope' then phCdope = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudScprthist private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteScprthist.
    run updateScprthist.
    run createScprthist.
end procedure.

procedure setScprthist:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttScprthist.
    ghttScprthist = phttScprthist.
    run crudScprthist.
    delete object phttScprthist.
end procedure.

procedure readScprthist:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table scprthist Table d'historisation des mouvements de parts
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNosoc  as integer    no-undo.
    define input parameter pdaDthist as date       no-undo.
    define input parameter pdaDtope  as date       no-undo.
    define input parameter piNomin  as integer    no-undo.
    define input parameter pcCdope  as character  no-undo.
    define input parameter table-handle phttScprthist.
    define variable vhttBuffer as handle no-undo.
    define buffer scprthist for scprthist.

    vhttBuffer = phttScprthist:default-buffer-handle.
    for first scprthist no-lock
        where scprthist.nosoc = piNosoc
          and scprthist.dthist = pdaDthist
          and scprthist.dtope = pdaDtope
          and scprthist.nomin = piNomin
          and scprthist.cdope = pcCdope:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer scprthist:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttScprthist no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getScprthist:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table scprthist Table d'historisation des mouvements de parts
    Notes  : service externe. Critère piNomin = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNosoc  as integer    no-undo.
    define input parameter pdaDthist as date       no-undo.
    define input parameter pdaDtope  as date       no-undo.
    define input parameter piNomin  as integer    no-undo.
    define input parameter table-handle phttScprthist.
    define variable vhttBuffer as handle  no-undo.
    define buffer scprthist for scprthist.

    vhttBuffer = phttScprthist:default-buffer-handle.
    if piNomin = ?
    then for each scprthist no-lock
        where scprthist.nosoc = piNosoc
          and scprthist.dthist = pdaDthist
          and scprthist.dtope = pdaDtope:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer scprthist:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each scprthist no-lock
        where scprthist.nosoc = piNosoc
          and scprthist.dthist = pdaDthist
          and scprthist.dtope = pdaDtope
          and scprthist.nomin = piNomin:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer scprthist:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttScprthist no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateScprthist private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNosoc    as handle  no-undo.
    define variable vhDthist    as handle  no-undo.
    define variable vhDtope    as handle  no-undo.
    define variable vhNomin    as handle  no-undo.
    define variable vhCdope    as handle  no-undo.
    define buffer scprthist for scprthist.

    create query vhttquery.
    vhttBuffer = ghttScprthist:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttScprthist:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNosoc, output vhDthist, output vhDtope, output vhNomin, output vhCdope).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first scprthist exclusive-lock
                where rowid(scprthist) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer scprthist:handle, 'nosoc/dthist/dtope/nomin/cdope: ', substitute('&1/&2/&3/&4/&5', vhNosoc:buffer-value(), vhDthist:buffer-value(), vhDtope:buffer-value(), vhNomin:buffer-value(), vhCdope:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer scprthist:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createScprthist private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer scprthist for scprthist.

    create query vhttquery.
    vhttBuffer = ghttScprthist:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttScprthist:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create scprthist.
            if not outils:copyValidField(buffer scprthist:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteScprthist private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNosoc    as handle  no-undo.
    define variable vhDthist    as handle  no-undo.
    define variable vhDtope    as handle  no-undo.
    define variable vhNomin    as handle  no-undo.
    define variable vhCdope    as handle  no-undo.
    define buffer scprthist for scprthist.

    create query vhttquery.
    vhttBuffer = ghttScprthist:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttScprthist:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNosoc, output vhDthist, output vhDtope, output vhNomin, output vhCdope).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first scprthist exclusive-lock
                where rowid(Scprthist) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer scprthist:handle, 'nosoc/dthist/dtope/nomin/cdope: ', substitute('&1/&2/&3/&4/&5', vhNosoc:buffer-value(), vhDthist:buffer-value(), vhDtope:buffer-value(), vhNomin:buffer-value(), vhCdope:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete scprthist no-error.
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

