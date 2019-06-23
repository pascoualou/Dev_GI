/*------------------------------------------------------------------------
File        : iexpe_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iexpe
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iexpe.i}
{application/include/error.i}
define variable ghttiexpe as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phExpe-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur expe-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'expe-cd' then phExpe-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIexpe private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIexpe.
    run updateIexpe.
    run createIexpe.
end procedure.

procedure setIexpe:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIexpe.
    ghttIexpe = phttIexpe.
    run crudIexpe.
    delete object phttIexpe.
end procedure.

procedure readIexpe:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iexpe parametrage des expeditions
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcExpe-cd as character  no-undo.
    define input parameter table-handle phttIexpe.
    define variable vhttBuffer as handle no-undo.
    define buffer iexpe for iexpe.

    vhttBuffer = phttIexpe:default-buffer-handle.
    for first iexpe no-lock
        where iexpe.expe-cd = pcExpe-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iexpe:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIexpe no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIexpe:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iexpe parametrage des expeditions
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIexpe.
    define variable vhttBuffer as handle  no-undo.
    define buffer iexpe for iexpe.

    vhttBuffer = phttIexpe:default-buffer-handle.
    for each iexpe no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iexpe:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIexpe no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIexpe private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhExpe-cd    as handle  no-undo.
    define buffer iexpe for iexpe.

    create query vhttquery.
    vhttBuffer = ghttIexpe:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIexpe:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhExpe-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iexpe exclusive-lock
                where rowid(iexpe) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iexpe:handle, 'expe-cd: ', substitute('&1', vhExpe-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iexpe:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIexpe private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iexpe for iexpe.

    create query vhttquery.
    vhttBuffer = ghttIexpe:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIexpe:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iexpe.
            if not outils:copyValidField(buffer iexpe:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIexpe private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhExpe-cd    as handle  no-undo.
    define buffer iexpe for iexpe.

    create query vhttquery.
    vhttBuffer = ghttIexpe:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIexpe:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhExpe-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iexpe exclusive-lock
                where rowid(Iexpe) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iexpe:handle, 'expe-cd: ', substitute('&1', vhExpe-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iexpe no-error.
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

