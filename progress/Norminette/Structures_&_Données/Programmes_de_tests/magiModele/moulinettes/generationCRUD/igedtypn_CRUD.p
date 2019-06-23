/*------------------------------------------------------------------------
File        : igedtypn_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table igedtypn
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/igedtypn.i}
{application/include/error.i}
define variable ghttigedtypn as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phPlan-cd as handle, output phPlan-niv as handle, output phTypdoc-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur plan-cd/plan-niv/typdoc-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'plan-cd' then phPlan-cd = phBuffer:buffer-field(vi).
            when 'plan-niv' then phPlan-niv = phBuffer:buffer-field(vi).
            when 'typdoc-cd' then phTypdoc-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIgedtypn private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIgedtypn.
    run updateIgedtypn.
    run createIgedtypn.
end procedure.

procedure setIgedtypn:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIgedtypn.
    ghttIgedtypn = phttIgedtypn.
    run crudIgedtypn.
    delete object phttIgedtypn.
end procedure.

procedure readIgedtypn:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table igedtypn Association type de doc / niveau 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcPlan-cd   as character  no-undo.
    define input parameter piPlan-niv  as integer    no-undo.
    define input parameter piTypdoc-cd as integer    no-undo.
    define input parameter table-handle phttIgedtypn.
    define variable vhttBuffer as handle no-undo.
    define buffer igedtypn for igedtypn.

    vhttBuffer = phttIgedtypn:default-buffer-handle.
    for first igedtypn no-lock
        where igedtypn.plan-cd = pcPlan-cd
          and igedtypn.plan-niv = piPlan-niv
          and igedtypn.typdoc-cd = piTypdoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer igedtypn:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIgedtypn no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIgedtypn:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table igedtypn Association type de doc / niveau 
    Notes  : service externe. Critère piPlan-niv = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcPlan-cd   as character  no-undo.
    define input parameter piPlan-niv  as integer    no-undo.
    define input parameter table-handle phttIgedtypn.
    define variable vhttBuffer as handle  no-undo.
    define buffer igedtypn for igedtypn.

    vhttBuffer = phttIgedtypn:default-buffer-handle.
    if piPlan-niv = ?
    then for each igedtypn no-lock
        where igedtypn.plan-cd = pcPlan-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer igedtypn:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each igedtypn no-lock
        where igedtypn.plan-cd = pcPlan-cd
          and igedtypn.plan-niv = piPlan-niv:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer igedtypn:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIgedtypn no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIgedtypn private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhPlan-cd    as handle  no-undo.
    define variable vhPlan-niv    as handle  no-undo.
    define variable vhTypdoc-cd    as handle  no-undo.
    define buffer igedtypn for igedtypn.

    create query vhttquery.
    vhttBuffer = ghttIgedtypn:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIgedtypn:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhPlan-cd, output vhPlan-niv, output vhTypdoc-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first igedtypn exclusive-lock
                where rowid(igedtypn) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer igedtypn:handle, 'plan-cd/plan-niv/typdoc-cd: ', substitute('&1/&2/&3', vhPlan-cd:buffer-value(), vhPlan-niv:buffer-value(), vhTypdoc-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer igedtypn:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIgedtypn private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer igedtypn for igedtypn.

    create query vhttquery.
    vhttBuffer = ghttIgedtypn:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIgedtypn:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create igedtypn.
            if not outils:copyValidField(buffer igedtypn:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIgedtypn private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhPlan-cd    as handle  no-undo.
    define variable vhPlan-niv    as handle  no-undo.
    define variable vhTypdoc-cd    as handle  no-undo.
    define buffer igedtypn for igedtypn.

    create query vhttquery.
    vhttBuffer = ghttIgedtypn:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIgedtypn:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhPlan-cd, output vhPlan-niv, output vhTypdoc-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first igedtypn exclusive-lock
                where rowid(Igedtypn) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer igedtypn:handle, 'plan-cd/plan-niv/typdoc-cd: ', substitute('&1/&2/&3', vhPlan-cd:buffer-value(), vhPlan-niv:buffer-value(), vhTypdoc-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete igedtypn no-error.
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

