/*------------------------------------------------------------------------
File        : igedtypd_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table igedtypd
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/igedtypd.i}
{application/include/error.i}
define variable ghttigedtypd as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTypdoc-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur typdoc-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'typdoc-cd' then phTypdoc-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIgedtypd private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIgedtypd.
    run updateIgedtypd.
    run createIgedtypd.
end procedure.

procedure setIgedtypd:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIgedtypd.
    ghttIgedtypd = phttIgedtypd.
    run crudIgedtypd.
    delete object phttIgedtypd.
end procedure.

procedure readIgedtypd:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table igedtypd 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piTypdoc-cd as integer    no-undo.
    define input parameter table-handle phttIgedtypd.
    define variable vhttBuffer as handle no-undo.
    define buffer igedtypd for igedtypd.

    vhttBuffer = phttIgedtypd:default-buffer-handle.
    for first igedtypd no-lock
        where igedtypd.typdoc-cd = piTypdoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer igedtypd:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIgedtypd no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIgedtypd:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table igedtypd 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIgedtypd.
    define variable vhttBuffer as handle  no-undo.
    define buffer igedtypd for igedtypd.

    vhttBuffer = phttIgedtypd:default-buffer-handle.
    for each igedtypd no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer igedtypd:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIgedtypd no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIgedtypd private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTypdoc-cd    as handle  no-undo.
    define buffer igedtypd for igedtypd.

    create query vhttquery.
    vhttBuffer = ghttIgedtypd:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIgedtypd:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTypdoc-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first igedtypd exclusive-lock
                where rowid(igedtypd) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer igedtypd:handle, 'typdoc-cd: ', substitute('&1', vhTypdoc-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer igedtypd:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIgedtypd private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer igedtypd for igedtypd.

    create query vhttquery.
    vhttBuffer = ghttIgedtypd:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIgedtypd:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create igedtypd.
            if not outils:copyValidField(buffer igedtypd:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIgedtypd private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTypdoc-cd    as handle  no-undo.
    define buffer igedtypd for igedtypd.

    create query vhttquery.
    vhttBuffer = ghttIgedtypd:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIgedtypd:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTypdoc-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first igedtypd exclusive-lock
                where rowid(Igedtypd) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer igedtypd:handle, 'typdoc-cd: ', substitute('&1', vhTypdoc-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete igedtypd no-error.
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

