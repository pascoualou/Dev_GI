/*------------------------------------------------------------------------
File        : scfct_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table scfct
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/scfct.i}
{application/include/error.i}
define variable ghttscfct as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdfct as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cdfct, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cdfct' then phCdfct = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudScfct private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteScfct.
    run updateScfct.
    run createScfct.
end procedure.

procedure setScfct:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttScfct.
    ghttScfct = phttScfct.
    run crudScfct.
    delete object phttScfct.
end procedure.

procedure readScfct:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table scfct 0110/0169 : Liste des fonctions pour le conseil de gérance
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdfct as character  no-undo.
    define input parameter table-handle phttScfct.
    define variable vhttBuffer as handle no-undo.
    define buffer scfct for scfct.

    vhttBuffer = phttScfct:default-buffer-handle.
    for first scfct no-lock
        where scfct.cdfct = pcCdfct:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer scfct:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttScfct no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getScfct:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table scfct 0110/0169 : Liste des fonctions pour le conseil de gérance
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttScfct.
    define variable vhttBuffer as handle  no-undo.
    define buffer scfct for scfct.

    vhttBuffer = phttScfct:default-buffer-handle.
    for each scfct no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer scfct:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttScfct no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateScfct private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdfct    as handle  no-undo.
    define buffer scfct for scfct.

    create query vhttquery.
    vhttBuffer = ghttScfct:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttScfct:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdfct).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first scfct exclusive-lock
                where rowid(scfct) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer scfct:handle, 'cdfct: ', substitute('&1', vhCdfct:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer scfct:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createScfct private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer scfct for scfct.

    create query vhttquery.
    vhttBuffer = ghttScfct:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttScfct:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create scfct.
            if not outils:copyValidField(buffer scfct:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteScfct private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdfct    as handle  no-undo.
    define buffer scfct for scfct.

    create query vhttquery.
    vhttBuffer = ghttScfct:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttScfct:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdfct).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first scfct exclusive-lock
                where rowid(Scfct) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer scfct:handle, 'cdfct: ', substitute('&1', vhCdfct:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete scfct no-error.
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

