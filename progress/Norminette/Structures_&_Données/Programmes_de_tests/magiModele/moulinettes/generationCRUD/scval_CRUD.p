/*------------------------------------------------------------------------
File        : scval_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table scval
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/scval.i}
{application/include/error.i}
define variable ghttscval as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNosoc as handle, output phDthist as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nosoc/dthist, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nosoc' then phNosoc = phBuffer:buffer-field(vi).
            when 'dthist' then phDthist = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudScval private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteScval.
    run updateScval.
    run createScval.
end procedure.

procedure setScval:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttScval.
    ghttScval = phttScval.
    run crudScval.
    delete object phttScval.
end procedure.

procedure readScval:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table scval 0110/0169 : Mémoriser la valeur des parts par date
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNosoc  as integer    no-undo.
    define input parameter pdaDthist as date       no-undo.
    define input parameter table-handle phttScval.
    define variable vhttBuffer as handle no-undo.
    define buffer scval for scval.

    vhttBuffer = phttScval:default-buffer-handle.
    for first scval no-lock
        where scval.nosoc = piNosoc
          and scval.dthist = pdaDthist:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer scval:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttScval no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getScval:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table scval 0110/0169 : Mémoriser la valeur des parts par date
    Notes  : service externe. Critère piNosoc = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNosoc  as integer    no-undo.
    define input parameter table-handle phttScval.
    define variable vhttBuffer as handle  no-undo.
    define buffer scval for scval.

    vhttBuffer = phttScval:default-buffer-handle.
    if piNosoc = ?
    then for each scval no-lock
        where scval.nosoc = piNosoc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer scval:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each scval no-lock
        where scval.nosoc = piNosoc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer scval:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttScval no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateScval private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNosoc    as handle  no-undo.
    define variable vhDthist    as handle  no-undo.
    define buffer scval for scval.

    create query vhttquery.
    vhttBuffer = ghttScval:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttScval:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNosoc, output vhDthist).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first scval exclusive-lock
                where rowid(scval) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer scval:handle, 'nosoc/dthist: ', substitute('&1/&2', vhNosoc:buffer-value(), vhDthist:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer scval:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createScval private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer scval for scval.

    create query vhttquery.
    vhttBuffer = ghttScval:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttScval:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create scval.
            if not outils:copyValidField(buffer scval:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteScval private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNosoc    as handle  no-undo.
    define variable vhDthist    as handle  no-undo.
    define buffer scval for scval.

    create query vhttquery.
    vhttBuffer = ghttScval:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttScval:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNosoc, output vhDthist).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first scval exclusive-lock
                where rowid(Scval) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer scval:handle, 'nosoc/dthist: ', substitute('&1/&2', vhNosoc:buffer-value(), vhDthist:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete scval no-error.
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

