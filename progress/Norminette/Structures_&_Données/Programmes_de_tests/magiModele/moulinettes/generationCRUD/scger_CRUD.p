/*------------------------------------------------------------------------
File        : scger_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table scger
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/scger.i}
{application/include/error.i}
define variable ghttscger as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNosoc as handle, output phNoger as handle, output phFgact as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nosoc/noger/fgact, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nosoc' then phNosoc = phBuffer:buffer-field(vi).
            when 'noger' then phNoger = phBuffer:buffer-field(vi).
            when 'fgact' then phFgact = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudScger private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteScger.
    run updateScger.
    run createScger.
end procedure.

procedure setScger:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttScger.
    ghttScger = phttScger.
    run crudScger.
    delete object phttScger.
end procedure.

procedure readScger:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table scger 0110/0169 : Liste des membres du conseil de gérance
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNosoc as integer    no-undo.
    define input parameter piNoger as integer    no-undo.
    define input parameter plFgact as logical    no-undo.
    define input parameter table-handle phttScger.
    define variable vhttBuffer as handle no-undo.
    define buffer scger for scger.

    vhttBuffer = phttScger:default-buffer-handle.
    for first scger no-lock
        where scger.nosoc = piNosoc
          and scger.noger = piNoger
          and scger.fgact = plFgact:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer scger:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttScger no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getScger:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table scger 0110/0169 : Liste des membres du conseil de gérance
    Notes  : service externe. Critère piNoger = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNosoc as integer    no-undo.
    define input parameter piNoger as integer    no-undo.
    define input parameter table-handle phttScger.
    define variable vhttBuffer as handle  no-undo.
    define buffer scger for scger.

    vhttBuffer = phttScger:default-buffer-handle.
    if piNoger = ?
    then for each scger no-lock
        where scger.nosoc = piNosoc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer scger:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each scger no-lock
        where scger.nosoc = piNosoc
          and scger.noger = piNoger:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer scger:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttScger no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateScger private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNosoc    as handle  no-undo.
    define variable vhNoger    as handle  no-undo.
    define variable vhFgact    as handle  no-undo.
    define buffer scger for scger.

    create query vhttquery.
    vhttBuffer = ghttScger:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttScger:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNosoc, output vhNoger, output vhFgact).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first scger exclusive-lock
                where rowid(scger) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer scger:handle, 'nosoc/noger/fgact: ', substitute('&1/&2/&3', vhNosoc:buffer-value(), vhNoger:buffer-value(), vhFgact:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer scger:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createScger private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer scger for scger.

    create query vhttquery.
    vhttBuffer = ghttScger:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttScger:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create scger.
            if not outils:copyValidField(buffer scger:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteScger private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNosoc    as handle  no-undo.
    define variable vhNoger    as handle  no-undo.
    define variable vhFgact    as handle  no-undo.
    define buffer scger for scger.

    create query vhttquery.
    vhttBuffer = ghttScger:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttScger:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNosoc, output vhNoger, output vhFgact).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first scger exclusive-lock
                where rowid(Scger) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer scger:handle, 'nosoc/noger/fgact: ', substitute('&1/&2/&3', vhNosoc:buffer-value(), vhNoger:buffer-value(), vhFgact:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete scger no-error.
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

