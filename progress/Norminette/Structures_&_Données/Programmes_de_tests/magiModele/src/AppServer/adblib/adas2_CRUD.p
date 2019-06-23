/*------------------------------------------------------------------------
File        : adas2_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table adas2
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttadas2 as handle no-undo.     // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNomdt as handle, output phCdexe as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nomdt/cdexe, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
            when 'cdexe' then phCdexe = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAdas2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAdas2.
    run updateAdas2.
    run createAdas2.
end procedure.

procedure setAdas2:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAdas2.
    ghttAdas2 = phttAdas2.
    run crudAdas2.
    delete object phttAdas2.
end procedure.

procedure readAdas2:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table adas2 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNomdt as integer    no-undo.
    define input parameter piCdexe as integer    no-undo.
    define input parameter table-handle phttAdas2.
    define variable vhttBuffer as handle no-undo.
    define buffer adas2 for adas2.

    vhttBuffer = phttAdas2:default-buffer-handle.
    for first adas2 no-lock
        where adas2.nomdt = piNomdt
          and adas2.cdexe = piCdexe:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer adas2:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAdas2 no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAdas2:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table adas2 
    Notes  : service externe. Critère piNomdt = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNomdt as integer    no-undo.
    define input parameter table-handle phttAdas2.
    define variable vhttBuffer as handle  no-undo.
    define buffer adas2 for adas2.

    vhttBuffer = phttAdas2:default-buffer-handle.
    if piNomdt = ?
    then for each adas2 no-lock
        where adas2.nomdt = piNomdt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer adas2:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each adas2 no-lock
        where adas2.nomdt = piNomdt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer adas2:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAdas2 no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAdas2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhCdexe    as handle  no-undo.
    define buffer adas2 for adas2.

    create query vhttquery.
    vhttBuffer = ghttAdas2:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAdas2:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt, output vhCdexe).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first adas2 exclusive-lock
                where rowid(adas2) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer adas2:handle, 'nomdt/cdexe: ', substitute('&1/&2', vhNomdt:buffer-value(), vhCdexe:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer adas2:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAdas2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer adas2 for adas2.

    create query vhttquery.
    vhttBuffer = ghttAdas2:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAdas2:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create adas2.
            if not outils:copyValidField(buffer adas2:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAdas2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhCdexe    as handle  no-undo.
    define buffer adas2 for adas2.

    create query vhttquery.
    vhttBuffer = ghttAdas2:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAdas2:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt, output vhCdexe).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first adas2 exclusive-lock
                where rowid(Adas2) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer adas2:handle, 'nomdt/cdexe: ', substitute('&1/&2', vhNomdt:buffer-value(), vhCdexe:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete adas2 no-error.
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

procedure deleteAdas2SurMandat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as integer no-undo.
    
    define buffer adas2 for adas2.

message "deleteAdas2SurMandat "  piNumeroMandat.

blocTrans:
    do transaction:
        for each adas2 exclusive-lock
           where adas2.nomdt = piNumeroMandat:
            delete adas2 no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
