/*------------------------------------------------------------------------
File        : sigle_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table sigle
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/sigle.i}
{application/include/error.i}
define variable ghttsigle as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTprol as handle, output phNorol as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tprol/norol, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tprol' then phTprol = phBuffer:buffer-field(vi).
            when 'norol' then phNorol = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSigle private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSigle.
    run updateSigle.
    run createSigle.
end procedure.

procedure setSigle:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSigle.
    ghttSigle = phttSigle.
    run crudSigle.
    delete object phttSigle.
end procedure.

procedure readSigle:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table sigle Sigle cabinet
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTprol as character  no-undo.
    define input parameter piNorol as integer    no-undo.
    define input parameter table-handle phttSigle.
    define variable vhttBuffer as handle no-undo.
    define buffer sigle for sigle.

    vhttBuffer = phttSigle:default-buffer-handle.
    for first sigle no-lock
        where sigle.tprol = pcTprol
          and sigle.norol = piNorol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer sigle:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSigle no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSigle:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table sigle Sigle cabinet
    Notes  : service externe. Critère pcTprol = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTprol as character  no-undo.
    define input parameter table-handle phttSigle.
    define variable vhttBuffer as handle  no-undo.
    define buffer sigle for sigle.

    vhttBuffer = phttSigle:default-buffer-handle.
    if pcTprol = ?
    then for each sigle no-lock
        where sigle.tprol = pcTprol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer sigle:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each sigle no-lock
        where sigle.tprol = pcTprol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer sigle:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSigle no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSigle private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define buffer sigle for sigle.

    create query vhttquery.
    vhttBuffer = ghttSigle:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSigle:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTprol, output vhNorol).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first sigle exclusive-lock
                where rowid(sigle) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer sigle:handle, 'tprol/norol: ', substitute('&1/&2', vhTprol:buffer-value(), vhNorol:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer sigle:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSigle private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer sigle for sigle.

    create query vhttquery.
    vhttBuffer = ghttSigle:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSigle:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create sigle.
            if not outils:copyValidField(buffer sigle:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSigle private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define buffer sigle for sigle.

    create query vhttquery.
    vhttBuffer = ghttSigle:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSigle:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTprol, output vhNorol).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first sigle exclusive-lock
                where rowid(Sigle) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer sigle:handle, 'tprol/norol: ', substitute('&1/&2', vhTprol:buffer-value(), vhNorol:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete sigle no-error.
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

procedure deleteSigleSurNorol:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeRole   as character no-undo.
    define input parameter piNumeroRole as integer   no-undo.
    
    define buffer sigle for sigle.

blocTrans:
    do transaction:
        for each sigle exclusive-lock
           where sigle.tprol = pcTypeRole
             and sigle.norol = piNumeroRole:
            delete sigle no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.

