/*------------------------------------------------------------------------
File        : iaffair_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iaffair
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iaffair.i}
{application/include/error.i}
define variable ghttiaffair as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phAffair-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/affair-num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'affair-num' then phAffair-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIaffair private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIaffair.
    run updateIaffair.
    run createIaffair.
end procedure.

procedure setIaffair:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIaffair.
    ghttIaffair = phttIaffair.
    run crudIaffair.
    delete object phttIaffair.
end procedure.

procedure readIaffair:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iaffair Gestion des affaires
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pdeAffair-num as decimal    no-undo.
    define input parameter table-handle phttIaffair.
    define variable vhttBuffer as handle no-undo.
    define buffer iaffair for iaffair.

    vhttBuffer = phttIaffair:default-buffer-handle.
    for first iaffair no-lock
        where iaffair.soc-cd = piSoc-cd
          and iaffair.etab-cd = piEtab-cd
          and iaffair.affair-num = pdeAffair-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iaffair:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIaffair no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIaffair:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iaffair Gestion des affaires
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter table-handle phttIaffair.
    define variable vhttBuffer as handle  no-undo.
    define buffer iaffair for iaffair.

    vhttBuffer = phttIaffair:default-buffer-handle.
    if piEtab-cd = ?
    then for each iaffair no-lock
        where iaffair.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iaffair:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iaffair no-lock
        where iaffair.soc-cd = piSoc-cd
          and iaffair.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iaffair:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIaffair no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIaffair private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhAffair-num    as handle  no-undo.
    define buffer iaffair for iaffair.

    create query vhttquery.
    vhttBuffer = ghttIaffair:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIaffair:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhAffair-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iaffair exclusive-lock
                where rowid(iaffair) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iaffair:handle, 'soc-cd/etab-cd/affair-num: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhAffair-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iaffair:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIaffair private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iaffair for iaffair.

    create query vhttquery.
    vhttBuffer = ghttIaffair:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIaffair:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iaffair.
            if not outils:copyValidField(buffer iaffair:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIaffair private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhAffair-num    as handle  no-undo.
    define buffer iaffair for iaffair.

    create query vhttquery.
    vhttBuffer = ghttIaffair:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIaffair:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhAffair-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iaffair exclusive-lock
                where rowid(Iaffair) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iaffair:handle, 'soc-cd/etab-cd/affair-num: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhAffair-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iaffair no-error.
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

