/*------------------------------------------------------------------------
File        : scmvthist_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table scmvthist
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/scmvthist.i}
{application/include/error.i}
define variable ghttscmvthist as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudScmvthist private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteScmvthist.
    run updateScmvthist.
    run createScmvthist.
end procedure.

procedure setScmvthist:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttScmvthist.
    ghttScmvthist = phttScmvthist.
    run crudScmvthist.
    delete object phttScmvthist.
end procedure.

procedure readScmvthist:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table scmvthist Table d'historisation des mouvements de parts
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNosoc  as integer    no-undo.
    define input parameter pdaDthist as date       no-undo.
    define input parameter pdaDtope  as date       no-undo.
    define input parameter piNomin  as integer    no-undo.
    define input parameter pcCdope  as character  no-undo.
    define input parameter table-handle phttScmvthist.
    define variable vhttBuffer as handle no-undo.
    define buffer scmvthist for scmvthist.

    vhttBuffer = phttScmvthist:default-buffer-handle.
    for first scmvthist no-lock
        where scmvthist.nosoc = piNosoc
          and scmvthist.dthist = pdaDthist
          and scmvthist.dtope = pdaDtope
          and scmvthist.nomin = piNomin
          and scmvthist.cdope = pcCdope:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer scmvthist:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttScmvthist no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getScmvthist:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table scmvthist Table d'historisation des mouvements de parts
    Notes  : service externe. Critère piNomin = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNosoc  as integer    no-undo.
    define input parameter pdaDthist as date       no-undo.
    define input parameter pdaDtope  as date       no-undo.
    define input parameter piNomin  as integer    no-undo.
    define input parameter table-handle phttScmvthist.
    define variable vhttBuffer as handle  no-undo.
    define buffer scmvthist for scmvthist.

    vhttBuffer = phttScmvthist:default-buffer-handle.
    if piNomin = ?
    then for each scmvthist no-lock
        where scmvthist.nosoc = piNosoc
          and scmvthist.dthist = pdaDthist
          and scmvthist.dtope = pdaDtope:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer scmvthist:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each scmvthist no-lock
        where scmvthist.nosoc = piNosoc
          and scmvthist.dthist = pdaDthist
          and scmvthist.dtope = pdaDtope
          and scmvthist.nomin = piNomin:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer scmvthist:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttScmvthist no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateScmvthist private:
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
    define buffer scmvthist for scmvthist.

    create query vhttquery.
    vhttBuffer = ghttScmvthist:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttScmvthist:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNosoc, output vhDthist, output vhDtope, output vhNomin, output vhCdope).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first scmvthist exclusive-lock
                where rowid(scmvthist) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer scmvthist:handle, 'nosoc/dthist/dtope/nomin/cdope: ', substitute('&1/&2/&3/&4/&5', vhNosoc:buffer-value(), vhDthist:buffer-value(), vhDtope:buffer-value(), vhNomin:buffer-value(), vhCdope:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer scmvthist:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createScmvthist private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer scmvthist for scmvthist.

    create query vhttquery.
    vhttBuffer = ghttScmvthist:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttScmvthist:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create scmvthist.
            if not outils:copyValidField(buffer scmvthist:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteScmvthist private:
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
    define buffer scmvthist for scmvthist.

    create query vhttquery.
    vhttBuffer = ghttScmvthist:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttScmvthist:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNosoc, output vhDthist, output vhDtope, output vhNomin, output vhCdope).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first scmvthist exclusive-lock
                where rowid(Scmvthist) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer scmvthist:handle, 'nosoc/dthist/dtope/nomin/cdope: ', substitute('&1/&2/&3/&4/&5', vhNosoc:buffer-value(), vhDthist:buffer-value(), vhDtope:buffer-value(), vhNomin:buffer-value(), vhCdope:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete scmvthist no-error.
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

