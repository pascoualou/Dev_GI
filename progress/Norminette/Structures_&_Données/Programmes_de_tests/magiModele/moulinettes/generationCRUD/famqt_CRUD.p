/*------------------------------------------------------------------------
File        : famqt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table famqt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/famqt.i}
{application/include/error.i}
define variable ghttfamqt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdfam as handle, output phCdsfa as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cdfam/cdsfa, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cdfam' then phCdfam = phBuffer:buffer-field(vi).
            when 'cdsfa' then phCdsfa = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudFamqt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteFamqt.
    run updateFamqt.
    run createFamqt.
end procedure.

procedure setFamqt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttFamqt.
    ghttFamqt = phttFamqt.
    run crudFamqt.
    delete object phttFamqt.
end procedure.

procedure readFamqt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table famqt 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piCdfam as integer    no-undo.
    define input parameter piCdsfa as integer    no-undo.
    define input parameter table-handle phttFamqt.
    define variable vhttBuffer as handle no-undo.
    define buffer famqt for famqt.

    vhttBuffer = phttFamqt:default-buffer-handle.
    for first famqt no-lock
        where famqt.cdfam = piCdfam
          and famqt.cdsfa = piCdsfa:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer famqt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttFamqt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getFamqt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table famqt 
    Notes  : service externe. Critère piCdfam = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piCdfam as integer    no-undo.
    define input parameter table-handle phttFamqt.
    define variable vhttBuffer as handle  no-undo.
    define buffer famqt for famqt.

    vhttBuffer = phttFamqt:default-buffer-handle.
    if piCdfam = ?
    then for each famqt no-lock
        where famqt.cdfam = piCdfam:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer famqt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each famqt no-lock
        where famqt.cdfam = piCdfam:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer famqt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttFamqt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateFamqt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdfam    as handle  no-undo.
    define variable vhCdsfa    as handle  no-undo.
    define buffer famqt for famqt.

    create query vhttquery.
    vhttBuffer = ghttFamqt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttFamqt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdfam, output vhCdsfa).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first famqt exclusive-lock
                where rowid(famqt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer famqt:handle, 'cdfam/cdsfa: ', substitute('&1/&2', vhCdfam:buffer-value(), vhCdsfa:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer famqt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createFamqt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer famqt for famqt.

    create query vhttquery.
    vhttBuffer = ghttFamqt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttFamqt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create famqt.
            if not outils:copyValidField(buffer famqt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteFamqt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdfam    as handle  no-undo.
    define variable vhCdsfa    as handle  no-undo.
    define buffer famqt for famqt.

    create query vhttquery.
    vhttBuffer = ghttFamqt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttFamqt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdfam, output vhCdsfa).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first famqt exclusive-lock
                where rowid(Famqt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer famqt:handle, 'cdfam/cdsfa: ', substitute('&1/&2', vhCdfam:buffer-value(), vhCdsfa:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete famqt no-error.
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

