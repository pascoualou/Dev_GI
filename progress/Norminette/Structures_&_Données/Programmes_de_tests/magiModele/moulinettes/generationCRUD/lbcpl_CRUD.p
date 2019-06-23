/*------------------------------------------------------------------------
File        : lbcpl_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table lbcpl
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/lbcpl.i}
{application/include/error.i}
define variable ghttlbcpl as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNolib as handle, output phNorng as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nolib/norng, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nolib' then phNolib = phBuffer:buffer-field(vi).
            when 'norng' then phNorng = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudLbcpl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteLbcpl.
    run updateLbcpl.
    run createLbcpl.
end procedure.

procedure setLbcpl:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttLbcpl.
    ghttLbcpl = phttLbcpl.
    run crudLbcpl.
    delete object phttLbcpl.
end procedure.

procedure readLbcpl:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table lbcpl 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNolib as integer    no-undo.
    define input parameter piNorng as integer    no-undo.
    define input parameter table-handle phttLbcpl.
    define variable vhttBuffer as handle no-undo.
    define buffer lbcpl for lbcpl.

    vhttBuffer = phttLbcpl:default-buffer-handle.
    for first lbcpl no-lock
        where lbcpl.nolib = piNolib
          and lbcpl.norng = piNorng:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer lbcpl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLbcpl no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getLbcpl:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table lbcpl 
    Notes  : service externe. Critère piNolib = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNolib as integer    no-undo.
    define input parameter table-handle phttLbcpl.
    define variable vhttBuffer as handle  no-undo.
    define buffer lbcpl for lbcpl.

    vhttBuffer = phttLbcpl:default-buffer-handle.
    if piNolib = ?
    then for each lbcpl no-lock
        where lbcpl.nolib = piNolib:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer lbcpl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each lbcpl no-lock
        where lbcpl.nolib = piNolib:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer lbcpl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLbcpl no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateLbcpl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNolib    as handle  no-undo.
    define variable vhNorng    as handle  no-undo.
    define buffer lbcpl for lbcpl.

    create query vhttquery.
    vhttBuffer = ghttLbcpl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttLbcpl:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNolib, output vhNorng).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first lbcpl exclusive-lock
                where rowid(lbcpl) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer lbcpl:handle, 'nolib/norng: ', substitute('&1/&2', vhNolib:buffer-value(), vhNorng:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer lbcpl:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createLbcpl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer lbcpl for lbcpl.

    create query vhttquery.
    vhttBuffer = ghttLbcpl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttLbcpl:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create lbcpl.
            if not outils:copyValidField(buffer lbcpl:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteLbcpl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNolib    as handle  no-undo.
    define variable vhNorng    as handle  no-undo.
    define buffer lbcpl for lbcpl.

    create query vhttquery.
    vhttBuffer = ghttLbcpl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttLbcpl:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNolib, output vhNorng).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first lbcpl exclusive-lock
                where rowid(Lbcpl) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer lbcpl:handle, 'nolib/norng: ', substitute('&1/&2', vhNolib:buffer-value(), vhNorng:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete lbcpl no-error.
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

