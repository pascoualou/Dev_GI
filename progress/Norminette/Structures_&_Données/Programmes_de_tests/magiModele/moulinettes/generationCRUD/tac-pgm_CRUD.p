/*------------------------------------------------------------------------
File        : tac-pgm_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table tac-pgm
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/tac-pgm.i}
{application/include/error.i}
define variable ghtttac-pgm as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoact as handle, output phNoord as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur NoAct/NoOrd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'NoAct' then phNoact = phBuffer:buffer-field(vi).
            when 'NoOrd' then phNoord = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTac-pgm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTac-pgm.
    run updateTac-pgm.
    run createTac-pgm.
end procedure.

procedure setTac-pgm:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTac-pgm.
    ghttTac-pgm = phttTac-pgm.
    run crudTac-pgm.
    delete object phttTac-pgm.
end procedure.

procedure readTac-pgm:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table tac-pgm Lien entre tache et menu
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoact as integer    no-undo.
    define input parameter piNoord as integer    no-undo.
    define input parameter table-handle phttTac-pgm.
    define variable vhttBuffer as handle no-undo.
    define buffer tac-pgm for tac-pgm.

    vhttBuffer = phttTac-pgm:default-buffer-handle.
    for first tac-pgm no-lock
        where tac-pgm.NoAct = piNoact
          and tac-pgm.NoOrd = piNoord:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tac-pgm:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTac-pgm no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTac-pgm:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table tac-pgm Lien entre tache et menu
    Notes  : service externe. Critère piNoact = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoact as integer    no-undo.
    define input parameter table-handle phttTac-pgm.
    define variable vhttBuffer as handle  no-undo.
    define buffer tac-pgm for tac-pgm.

    vhttBuffer = phttTac-pgm:default-buffer-handle.
    if piNoact = ?
    then for each tac-pgm no-lock
        where tac-pgm.NoAct = piNoact:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tac-pgm:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each tac-pgm no-lock
        where tac-pgm.NoAct = piNoact:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tac-pgm:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTac-pgm no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTac-pgm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoact    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer tac-pgm for tac-pgm.

    create query vhttquery.
    vhttBuffer = ghttTac-pgm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTac-pgm:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoact, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tac-pgm exclusive-lock
                where rowid(tac-pgm) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tac-pgm:handle, 'NoAct/NoOrd: ', substitute('&1/&2', vhNoact:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer tac-pgm:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTac-pgm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer tac-pgm for tac-pgm.

    create query vhttquery.
    vhttBuffer = ghttTac-pgm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTac-pgm:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create tac-pgm.
            if not outils:copyValidField(buffer tac-pgm:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTac-pgm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoact    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer tac-pgm for tac-pgm.

    create query vhttquery.
    vhttBuffer = ghttTac-pgm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTac-pgm:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoact, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tac-pgm exclusive-lock
                where rowid(Tac-pgm) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tac-pgm:handle, 'NoAct/NoOrd: ', substitute('&1/&2', vhNoact:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete tac-pgm no-error.
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

