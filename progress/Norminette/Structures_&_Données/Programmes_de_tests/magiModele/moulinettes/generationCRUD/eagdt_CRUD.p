/*------------------------------------------------------------------------
File        : eagdt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table eagdt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/eagdt.i}
{application/include/error.i}
define variable ghtteagdt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoint as handle, output phNores as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noint/nores, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noint' then phNoint = phBuffer:buffer-field(vi).
            when 'nores' then phNores = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudEagdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteEagdt.
    run updateEagdt.
    run createEagdt.
end procedure.

procedure setEagdt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEagdt.
    ghttEagdt = phttEagdt.
    run crudEagdt.
    delete object phttEagdt.
end procedure.

procedure readEagdt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table eagdt 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoint as integer    no-undo.
    define input parameter piNores as integer    no-undo.
    define input parameter table-handle phttEagdt.
    define variable vhttBuffer as handle no-undo.
    define buffer eagdt for eagdt.

    vhttBuffer = phttEagdt:default-buffer-handle.
    for first eagdt no-lock
        where eagdt.noint = piNoint
          and eagdt.nores = piNores:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer eagdt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEagdt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getEagdt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table eagdt 
    Notes  : service externe. Critère piNoint = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoint as integer    no-undo.
    define input parameter table-handle phttEagdt.
    define variable vhttBuffer as handle  no-undo.
    define buffer eagdt for eagdt.

    vhttBuffer = phttEagdt:default-buffer-handle.
    if piNoint = ?
    then for each eagdt no-lock
        where eagdt.noint = piNoint:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer eagdt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each eagdt no-lock
        where eagdt.noint = piNoint:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer eagdt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEagdt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateEagdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoint    as handle  no-undo.
    define variable vhNores    as handle  no-undo.
    define buffer eagdt for eagdt.

    create query vhttquery.
    vhttBuffer = ghttEagdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttEagdt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoint, output vhNores).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first eagdt exclusive-lock
                where rowid(eagdt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer eagdt:handle, 'noint/nores: ', substitute('&1/&2', vhNoint:buffer-value(), vhNores:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer eagdt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createEagdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer eagdt for eagdt.

    create query vhttquery.
    vhttBuffer = ghttEagdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttEagdt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create eagdt.
            if not outils:copyValidField(buffer eagdt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteEagdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoint    as handle  no-undo.
    define variable vhNores    as handle  no-undo.
    define buffer eagdt for eagdt.

    create query vhttquery.
    vhttBuffer = ghttEagdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttEagdt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoint, output vhNores).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first eagdt exclusive-lock
                where rowid(Eagdt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer eagdt:handle, 'noint/nores: ', substitute('&1/&2', vhNoint:buffer-value(), vhNores:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete eagdt no-error.
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

