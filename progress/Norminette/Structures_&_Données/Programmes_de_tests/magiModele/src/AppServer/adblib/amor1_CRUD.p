/*------------------------------------------------------------------------
File        : amor1_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table amor1
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttamor1 as handle no-undo.     // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phNofic as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcon/nocon/nofic, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'nofic' then phNofic = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAmor1 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAmor1.
    run updateAmor1.
    run createAmor1.
end procedure.

procedure setAmor1:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAmor1.
    ghttAmor1 = phttAmor1.
    run crudAmor1.
    delete object phttAmor1.
end procedure.

procedure readAmor1:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table amor1 Amortissement locataires (1)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as int64      no-undo.
    define input parameter piNofic as integer    no-undo.
    define input parameter table-handle phttAmor1.
    define variable vhttBuffer as handle no-undo.
    define buffer amor1 for amor1.

    vhttBuffer = phttAmor1:default-buffer-handle.
    for first amor1 no-lock
        where amor1.tpcon = pcTpcon
          and amor1.nocon = piNocon
          and amor1.nofic = piNofic:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer amor1:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAmor1 no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAmor1:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table amor1 Amortissement locataires (1)
    Notes  : service externe. Critère piNocon = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as int64      no-undo.
    define input parameter table-handle phttAmor1.
    define variable vhttBuffer as handle  no-undo.
    define buffer amor1 for amor1.

    vhttBuffer = phttAmor1:default-buffer-handle.
    if piNocon = ?
    then for each amor1 no-lock
        where amor1.tpcon = pcTpcon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer amor1:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each amor1 no-lock
        where amor1.tpcon = pcTpcon
          and amor1.nocon = piNocon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer amor1:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAmor1 no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAmor1 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNofic    as handle  no-undo.
    define buffer amor1 for amor1.

    create query vhttquery.
    vhttBuffer = ghttAmor1:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAmor1:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNofic).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first amor1 exclusive-lock
                where rowid(amor1) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer amor1:handle, 'tpcon/nocon/nofic: ', substitute('&1/&2/&3', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNofic:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer amor1:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAmor1 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer amor1 for amor1.

    create query vhttquery.
    vhttBuffer = ghttAmor1:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAmor1:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create amor1.
            if not outils:copyValidField(buffer amor1:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAmor1 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNofic    as handle  no-undo.
    define buffer amor1 for amor1.

    create query vhttquery.
    vhttBuffer = ghttAmor1:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAmor1:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNofic).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first amor1 exclusive-lock
                where rowid(Amor1) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer amor1:handle, 'tpcon/nocon/nofic: ', substitute('&1/&2/&3', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNofic:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete amor1 no-error.
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

procedure deleteAmor1SurContrat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.

    define buffer amor1 for amor1.

blocTrans:
    do transaction:
        for each amor1 exclusive-lock 
            where amor1.tpcon = pcTypeContrat 
              and amor1.nocon = piNumeroContrat:
            delete amor1 no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status
end procedure.
