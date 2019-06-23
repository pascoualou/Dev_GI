/*------------------------------------------------------------------------
File        : repimg_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table repimg
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/repimg.i}
{application/include/error.i}
define variable ghttrepimg as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpidt as handle, output phNoimm as handle, output phNolot as handle, output phNmrep as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpidt/noimm/nolot/nmrep, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpidt' then phTpidt = phBuffer:buffer-field(vi).
            when 'noimm' then phNoimm = phBuffer:buffer-field(vi).
            when 'nolot' then phNolot = phBuffer:buffer-field(vi).
            when 'nmrep' then phNmrep = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudRepimg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteRepimg.
    run updateRepimg.
    run createRepimg.
end procedure.

procedure setRepimg:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRepimg.
    ghttRepimg = phttRepimg.
    run crudRepimg.
    delete object phttRepimg.
end procedure.

procedure readRepimg:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table repimg Repertoire stockage images
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpidt as character  no-undo.
    define input parameter piNoimm as integer    no-undo.
    define input parameter piNolot as integer    no-undo.
    define input parameter pcNmrep as character  no-undo.
    define input parameter table-handle phttRepimg.
    define variable vhttBuffer as handle no-undo.
    define buffer repimg for repimg.

    vhttBuffer = phttRepimg:default-buffer-handle.
    for first repimg no-lock
        where repimg.tpidt = pcTpidt
          and repimg.noimm = piNoimm
          and repimg.nolot = piNolot
          and repimg.nmrep = pcNmrep:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer repimg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRepimg no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getRepimg:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table repimg Repertoire stockage images
    Notes  : service externe. Critère piNolot = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpidt as character  no-undo.
    define input parameter piNoimm as integer    no-undo.
    define input parameter piNolot as integer    no-undo.
    define input parameter table-handle phttRepimg.
    define variable vhttBuffer as handle  no-undo.
    define buffer repimg for repimg.

    vhttBuffer = phttRepimg:default-buffer-handle.
    if piNolot = ?
    then for each repimg no-lock
        where repimg.tpidt = pcTpidt
          and repimg.noimm = piNoimm:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer repimg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each repimg no-lock
        where repimg.tpidt = pcTpidt
          and repimg.noimm = piNoimm
          and repimg.nolot = piNolot:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer repimg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRepimg no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateRepimg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define variable vhNmrep    as handle  no-undo.
    define buffer repimg for repimg.

    create query vhttquery.
    vhttBuffer = ghttRepimg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttRepimg:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpidt, output vhNoimm, output vhNolot, output vhNmrep).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first repimg exclusive-lock
                where rowid(repimg) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer repimg:handle, 'tpidt/noimm/nolot/nmrep: ', substitute('&1/&2/&3/&4', vhTpidt:buffer-value(), vhNoimm:buffer-value(), vhNolot:buffer-value(), vhNmrep:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer repimg:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createRepimg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer repimg for repimg.

    create query vhttquery.
    vhttBuffer = ghttRepimg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttRepimg:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create repimg.
            if not outils:copyValidField(buffer repimg:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteRepimg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define variable vhNmrep    as handle  no-undo.
    define buffer repimg for repimg.

    create query vhttquery.
    vhttBuffer = ghttRepimg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttRepimg:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpidt, output vhNoimm, output vhNolot, output vhNmrep).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first repimg exclusive-lock
                where rowid(Repimg) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer repimg:handle, 'tpidt/noimm/nolot/nmrep: ', substitute('&1/&2/&3/&4', vhTpidt:buffer-value(), vhNoimm:buffer-value(), vhNolot:buffer-value(), vhNmrep:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete repimg no-error.
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

