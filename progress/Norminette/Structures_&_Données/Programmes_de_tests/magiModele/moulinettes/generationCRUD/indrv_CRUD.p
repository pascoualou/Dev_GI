/*------------------------------------------------------------------------
File        : indrv_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table indrv
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/indrv.i}
{application/include/error.i}
define variable ghttindrv as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdirv as handle, output phAnper as handle, output phNoper as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cdirv/anper/noper, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cdirv' then phCdirv = phBuffer:buffer-field(vi).
            when 'anper' then phAnper = phBuffer:buffer-field(vi).
            when 'noper' then phNoper = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIndrv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIndrv.
    run updateIndrv.
    run createIndrv.
end procedure.

procedure setIndrv:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIndrv.
    ghttIndrv = phttIndrv.
    run crudIndrv.
    delete object phttIndrv.
end procedure.

procedure readIndrv:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table indrv 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piCdirv as integer    no-undo.
    define input parameter piAnper as integer    no-undo.
    define input parameter piNoper as integer    no-undo.
    define input parameter table-handle phttIndrv.
    define variable vhttBuffer as handle no-undo.
    define buffer indrv for indrv.

    vhttBuffer = phttIndrv:default-buffer-handle.
    for first indrv no-lock
        where indrv.cdirv = piCdirv
          and indrv.anper = piAnper
          and indrv.noper = piNoper:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer indrv:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIndrv no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIndrv:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table indrv 
    Notes  : service externe. Critère piAnper = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piCdirv as integer    no-undo.
    define input parameter piAnper as integer    no-undo.
    define input parameter table-handle phttIndrv.
    define variable vhttBuffer as handle  no-undo.
    define buffer indrv for indrv.

    vhttBuffer = phttIndrv:default-buffer-handle.
    if piAnper = ?
    then for each indrv no-lock
        where indrv.cdirv = piCdirv:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer indrv:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each indrv no-lock
        where indrv.cdirv = piCdirv
          and indrv.anper = piAnper:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer indrv:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIndrv no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIndrv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdirv    as handle  no-undo.
    define variable vhAnper    as handle  no-undo.
    define variable vhNoper    as handle  no-undo.
    define buffer indrv for indrv.

    create query vhttquery.
    vhttBuffer = ghttIndrv:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIndrv:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdirv, output vhAnper, output vhNoper).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first indrv exclusive-lock
                where rowid(indrv) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer indrv:handle, 'cdirv/anper/noper: ', substitute('&1/&2/&3', vhCdirv:buffer-value(), vhAnper:buffer-value(), vhNoper:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer indrv:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIndrv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer indrv for indrv.

    create query vhttquery.
    vhttBuffer = ghttIndrv:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIndrv:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create indrv.
            if not outils:copyValidField(buffer indrv:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIndrv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdirv    as handle  no-undo.
    define variable vhAnper    as handle  no-undo.
    define variable vhNoper    as handle  no-undo.
    define buffer indrv for indrv.

    create query vhttquery.
    vhttBuffer = ghttIndrv:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIndrv:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdirv, output vhAnper, output vhNoper).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first indrv exclusive-lock
                where rowid(Indrv) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer indrv:handle, 'cdirv/anper/noper: ', substitute('&1/&2/&3', vhCdirv:buffer-value(), vhAnper:buffer-value(), vhNoper:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete indrv no-error.
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

