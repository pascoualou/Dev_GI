/*------------------------------------------------------------------------
File        : ebail_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ebail
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttebail as handle no-undo.     // le handle de la temp table à mettre à jour


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

procedure crudEbail private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteEbail.
    run updateEbail.
    run createEbail.
end procedure.

procedure setEbail:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEbail.
    ghttEbail = phttEbail.
    run crudEbail.
    delete object phttEbail.
end procedure.

procedure readEbail:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ebail 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNoexe as integer    no-undo.
    define input parameter piNoloc as int64      no-undo.
    define input parameter table-handle phttEbail.
    define variable vhttBuffer as handle no-undo.
    define buffer ebail for ebail.

    vhttBuffer = phttEbail:default-buffer-handle.
    for first ebail no-lock
        where ebail.nomdt = piNomdt
          and ebail.noexe = piNoexe
          and ebail.noloc = piNoloc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ebail:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEbail no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getEbail:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ebail 
    Notes  : service externe. Critère piNoexe = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNoexe as integer    no-undo.
    define input parameter table-handle phttEbail.
    define variable vhttBuffer as handle  no-undo.
    define buffer ebail for ebail.

    vhttBuffer = phttEbail:default-buffer-handle.
    if piNoexe = ?
    then for each ebail no-lock
        where ebail.nomdt = piNomdt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ebail:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ebail no-lock
        where ebail.nomdt = piNomdt
          and ebail.noexe = piNoexe:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ebail:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEbail no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateEbail private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoexe    as handle  no-undo.
    define variable vhNoloc    as handle  no-undo.
    define buffer ebail for ebail.

    create query vhttquery.
    vhttBuffer = ghttEbail:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttEbail:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt, output vhNoexe, output vhNoloc).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ebail exclusive-lock
                where rowid(ebail) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ebail:handle, 'nomdt/noexe/noloc: ', substitute('&1/&2/&3', vhNomdt:buffer-value(), vhNoexe:buffer-value(), vhNoloc:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ebail:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createEbail private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer ebail for ebail.

    create query vhttquery.
    vhttBuffer = ghttEbail:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttEbail:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ebail.
            if not outils:copyValidField(buffer ebail:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteEbail private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoexe    as handle  no-undo.
    define variable vhNoloc    as handle  no-undo.
    define buffer ebail for ebail.

    create query vhttquery.
    vhttBuffer = ghttEbail:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttEbail:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt, output vhNoexe, output vhNoloc).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ebail exclusive-lock
                where rowid(Ebail) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ebail:handle, 'nomdt/noexe/noloc: ', substitute('&1/&2/&3', vhNomdt:buffer-value(), vhNoexe:buffer-value(), vhNoloc:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ebail no-error.
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

procedure deleteEbailSurMandat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as integer no-undo.
    
    define buffer ebail for ebail.

message "deleteEbailSurMandat "  piNumeroMandat.

blocTrans:
    do transaction:
        for each ebail exclusive-lock
           where ebail.nomdt = piNumeroMandat:
            delete ebail no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
