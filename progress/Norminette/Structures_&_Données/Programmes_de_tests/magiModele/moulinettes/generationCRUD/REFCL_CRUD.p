/*------------------------------------------------------------------------
File        : REFCL_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table REFCL
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/REFCL.i}
{application/include/error.i}
define variable ghttREFCL as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNodot as handle, output phNochp as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nodot/nochp, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nodot' then phNodot = phBuffer:buffer-field(vi).
            when 'nochp' then phNochp = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudRefcl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteRefcl.
    run updateRefcl.
    run createRefcl.
end procedure.

procedure setRefcl:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRefcl.
    ghttRefcl = phttRefcl.
    run crudRefcl.
    delete object phttRefcl.
end procedure.

procedure readRefcl:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table REFCL Référence client
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNodot as integer    no-undo.
    define input parameter piNochp as integer    no-undo.
    define input parameter table-handle phttRefcl.
    define variable vhttBuffer as handle no-undo.
    define buffer REFCL for REFCL.

    vhttBuffer = phttRefcl:default-buffer-handle.
    for first REFCL no-lock
        where REFCL.nodot = piNodot
          and REFCL.nochp = piNochp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer REFCL:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRefcl no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getRefcl:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table REFCL Référence client
    Notes  : service externe. Critère piNodot = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNodot as integer    no-undo.
    define input parameter table-handle phttRefcl.
    define variable vhttBuffer as handle  no-undo.
    define buffer REFCL for REFCL.

    vhttBuffer = phttRefcl:default-buffer-handle.
    if piNodot = ?
    then for each REFCL no-lock
        where REFCL.nodot = piNodot:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer REFCL:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each REFCL no-lock
        where REFCL.nodot = piNodot:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer REFCL:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRefcl no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateRefcl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNodot    as handle  no-undo.
    define variable vhNochp    as handle  no-undo.
    define buffer REFCL for REFCL.

    create query vhttquery.
    vhttBuffer = ghttRefcl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttRefcl:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNodot, output vhNochp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first REFCL exclusive-lock
                where rowid(REFCL) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer REFCL:handle, 'nodot/nochp: ', substitute('&1/&2', vhNodot:buffer-value(), vhNochp:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer REFCL:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createRefcl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer REFCL for REFCL.

    create query vhttquery.
    vhttBuffer = ghttRefcl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttRefcl:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create REFCL.
            if not outils:copyValidField(buffer REFCL:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteRefcl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNodot    as handle  no-undo.
    define variable vhNochp    as handle  no-undo.
    define buffer REFCL for REFCL.

    create query vhttquery.
    vhttBuffer = ghttRefcl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttRefcl:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNodot, output vhNochp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first REFCL exclusive-lock
                where rowid(Refcl) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer REFCL:handle, 'nodot/nochp: ', substitute('&1/&2', vhNodot:buffer-value(), vhNochp:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete REFCL no-error.
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

