/*------------------------------------------------------------------------
File        : abail_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table abail
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttabail as handle no-undo.     // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNomdt as handle, output phNoexe as handle, output phNoloc as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nomdt/noexe/noloc, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
            when 'noexe' then phNoexe = phBuffer:buffer-field(vi).
            when 'noloc' then phNoloc = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAbail private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAbail.
    run updateAbail.
    run createAbail.
end procedure.

procedure setAbail:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAbail.
    ghttAbail = phttAbail.
    run crudAbail.
    delete object phttAbail.
end procedure.

procedure readAbail:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table abail Historique Droit de Bail
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNoexe as integer    no-undo.
    define input parameter piNoloc as int64      no-undo.
    define input parameter table-handle phttAbail.
    define variable vhttBuffer as handle no-undo.
    define buffer abail for abail.

    vhttBuffer = phttAbail:default-buffer-handle.
    for first abail no-lock
        where abail.nomdt = piNomdt
          and abail.noexe = piNoexe
          and abail.noloc = piNoloc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer abail:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAbail no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAbail:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table abail Historique Droit de Bail
    Notes  : service externe. Critère piNoexe = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNoexe as integer    no-undo.
    define input parameter table-handle phttAbail.
    define variable vhttBuffer as handle  no-undo.
    define buffer abail for abail.

    vhttBuffer = phttAbail:default-buffer-handle.
    if piNoexe = ?
    then for each abail no-lock
        where abail.nomdt = piNomdt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer abail:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each abail no-lock
        where abail.nomdt = piNomdt
          and abail.noexe = piNoexe:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer abail:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAbail no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAbail private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoexe    as handle  no-undo.
    define variable vhNoloc    as handle  no-undo.
    define buffer abail for abail.

    create query vhttquery.
    vhttBuffer = ghttAbail:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAbail:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt, output vhNoexe, output vhNoloc).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first abail exclusive-lock
                where rowid(abail) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer abail:handle, 'nomdt/noexe/noloc: ', substitute('&1/&2/&3', vhNomdt:buffer-value(), vhNoexe:buffer-value(), vhNoloc:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer abail:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAbail private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer abail for abail.

    create query vhttquery.
    vhttBuffer = ghttAbail:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAbail:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create abail.
            if not outils:copyValidField(buffer abail:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAbail private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoexe    as handle  no-undo.
    define variable vhNoloc    as handle  no-undo.
    define buffer abail for abail.

    create query vhttquery.
    vhttBuffer = ghttAbail:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAbail:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt, output vhNoexe, output vhNoloc).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first abail exclusive-lock
                where rowid(Abail) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer abail:handle, 'nomdt/noexe/noloc: ', substitute('&1/&2/&3', vhNomdt:buffer-value(), vhNoexe:buffer-value(), vhNoloc:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete abail no-error.
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

procedure deleteAbailSurMandat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as integer no-undo.
    
    define buffer abail for abail.

message "deleteAbailSurMandat "  piNumeroMandat.

blocTrans:
    do transaction:
        for each abail exclusive-lock
           where abail.nomdt = piNumeroMandat:
            delete abail no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
