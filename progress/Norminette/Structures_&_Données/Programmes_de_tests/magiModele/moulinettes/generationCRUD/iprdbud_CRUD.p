/*------------------------------------------------------------------------
File        : iprdbud_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iprdbud
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iprdbud.i}
{application/include/error.i}
define variable ghttiprdbud as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phPrd-cd as handle, output phPrd-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/prd-cd/prd-num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'prd-cd' then phPrd-cd = phBuffer:buffer-field(vi).
            when 'prd-num' then phPrd-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIprdbud private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIprdbud.
    run updateIprdbud.
    run createIprdbud.
end procedure.

procedure setIprdbud:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIprdbud.
    ghttIprdbud = phttIprdbud.
    run crudIprdbud.
    delete object phttIprdbud.
end procedure.

procedure readIprdbud:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iprdbud 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piPrd-cd  as integer    no-undo.
    define input parameter piPrd-num as integer    no-undo.
    define input parameter table-handle phttIprdbud.
    define variable vhttBuffer as handle no-undo.
    define buffer iprdbud for iprdbud.

    vhttBuffer = phttIprdbud:default-buffer-handle.
    for first iprdbud no-lock
        where iprdbud.soc-cd = piSoc-cd
          and iprdbud.etab-cd = piEtab-cd
          and iprdbud.prd-cd = piPrd-cd
          and iprdbud.prd-num = piPrd-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iprdbud:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIprdbud no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIprdbud:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iprdbud 
    Notes  : service externe. Critère piPrd-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piPrd-cd  as integer    no-undo.
    define input parameter table-handle phttIprdbud.
    define variable vhttBuffer as handle  no-undo.
    define buffer iprdbud for iprdbud.

    vhttBuffer = phttIprdbud:default-buffer-handle.
    if piPrd-cd = ?
    then for each iprdbud no-lock
        where iprdbud.soc-cd = piSoc-cd
          and iprdbud.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iprdbud:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iprdbud no-lock
        where iprdbud.soc-cd = piSoc-cd
          and iprdbud.etab-cd = piEtab-cd
          and iprdbud.prd-cd = piPrd-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iprdbud:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIprdbud no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIprdbud private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhPrd-cd    as handle  no-undo.
    define variable vhPrd-num    as handle  no-undo.
    define buffer iprdbud for iprdbud.

    create query vhttquery.
    vhttBuffer = ghttIprdbud:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIprdbud:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhPrd-cd, output vhPrd-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iprdbud exclusive-lock
                where rowid(iprdbud) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iprdbud:handle, 'soc-cd/etab-cd/prd-cd/prd-num: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iprdbud:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIprdbud private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iprdbud for iprdbud.

    create query vhttquery.
    vhttBuffer = ghttIprdbud:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIprdbud:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iprdbud.
            if not outils:copyValidField(buffer iprdbud:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIprdbud private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhPrd-cd    as handle  no-undo.
    define variable vhPrd-num    as handle  no-undo.
    define buffer iprdbud for iprdbud.

    create query vhttquery.
    vhttBuffer = ghttIprdbud:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIprdbud:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhPrd-cd, output vhPrd-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iprdbud exclusive-lock
                where rowid(Iprdbud) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iprdbud:handle, 'soc-cd/etab-cd/prd-cd/prd-num: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iprdbud no-error.
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

