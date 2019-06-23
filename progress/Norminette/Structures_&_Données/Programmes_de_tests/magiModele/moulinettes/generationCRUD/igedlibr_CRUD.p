/*------------------------------------------------------------------------
File        : igedlibr_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table igedlibr
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/igedlibr.i}
{application/include/error.i}
define variable ghttigedlibr as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phPlan-cd as handle, output phPlan-niv as handle, output phLibr-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur plan-cd/plan-niv/libr-num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'plan-cd' then phPlan-cd = phBuffer:buffer-field(vi).
            when 'plan-niv' then phPlan-niv = phBuffer:buffer-field(vi).
            when 'libr-num' then phLibr-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIgedlibr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIgedlibr.
    run updateIgedlibr.
    run createIgedlibr.
end procedure.

procedure setIgedlibr:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIgedlibr.
    ghttIgedlibr = phttIgedlibr.
    run crudIgedlibr.
    delete object phttIgedlibr.
end procedure.

procedure readIgedlibr:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table igedlibr 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcPlan-cd  as character  no-undo.
    define input parameter piPlan-niv as integer    no-undo.
    define input parameter piLibr-num as integer    no-undo.
    define input parameter table-handle phttIgedlibr.
    define variable vhttBuffer as handle no-undo.
    define buffer igedlibr for igedlibr.

    vhttBuffer = phttIgedlibr:default-buffer-handle.
    for first igedlibr no-lock
        where igedlibr.plan-cd = pcPlan-cd
          and igedlibr.plan-niv = piPlan-niv
          and igedlibr.libr-num = piLibr-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer igedlibr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIgedlibr no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIgedlibr:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table igedlibr 
    Notes  : service externe. Critère piPlan-niv = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcPlan-cd  as character  no-undo.
    define input parameter piPlan-niv as integer    no-undo.
    define input parameter table-handle phttIgedlibr.
    define variable vhttBuffer as handle  no-undo.
    define buffer igedlibr for igedlibr.

    vhttBuffer = phttIgedlibr:default-buffer-handle.
    if piPlan-niv = ?
    then for each igedlibr no-lock
        where igedlibr.plan-cd = pcPlan-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer igedlibr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each igedlibr no-lock
        where igedlibr.plan-cd = pcPlan-cd
          and igedlibr.plan-niv = piPlan-niv:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer igedlibr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIgedlibr no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIgedlibr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhPlan-cd    as handle  no-undo.
    define variable vhPlan-niv    as handle  no-undo.
    define variable vhLibr-num    as handle  no-undo.
    define buffer igedlibr for igedlibr.

    create query vhttquery.
    vhttBuffer = ghttIgedlibr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIgedlibr:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhPlan-cd, output vhPlan-niv, output vhLibr-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first igedlibr exclusive-lock
                where rowid(igedlibr) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer igedlibr:handle, 'plan-cd/plan-niv/libr-num: ', substitute('&1/&2/&3', vhPlan-cd:buffer-value(), vhPlan-niv:buffer-value(), vhLibr-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer igedlibr:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIgedlibr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer igedlibr for igedlibr.

    create query vhttquery.
    vhttBuffer = ghttIgedlibr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIgedlibr:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create igedlibr.
            if not outils:copyValidField(buffer igedlibr:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIgedlibr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhPlan-cd    as handle  no-undo.
    define variable vhPlan-niv    as handle  no-undo.
    define variable vhLibr-num    as handle  no-undo.
    define buffer igedlibr for igedlibr.

    create query vhttquery.
    vhttBuffer = ghttIgedlibr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIgedlibr:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhPlan-cd, output vhPlan-niv, output vhLibr-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first igedlibr exclusive-lock
                where rowid(Igedlibr) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer igedlibr:handle, 'plan-cd/plan-niv/libr-num: ', substitute('&1/&2/&3', vhPlan-cd:buffer-value(), vhPlan-niv:buffer-value(), vhLibr-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete igedlibr no-error.
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

