/*------------------------------------------------------------------------
File        : zexport_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table zexport
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/zexport.i}
{application/include/error.i}
define variable ghttzexport as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phLibtype-cd as handle, output phTiers-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/libtype-cd/tiers-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'libtype-cd' then phLibtype-cd = phBuffer:buffer-field(vi).
            when 'tiers-cle' then phTiers-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudZexport private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteZexport.
    run updateZexport.
    run createZexport.
end procedure.

procedure setZexport:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttZexport.
    ghttZexport = phttZexport.
    run crudZexport.
    delete object phttZexport.
end procedure.

procedure readZexport:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table zexport 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piLibtype-cd as integer    no-undo.
    define input parameter pcTiers-cle  as character  no-undo.
    define input parameter table-handle phttZexport.
    define variable vhttBuffer as handle no-undo.
    define buffer zexport for zexport.

    vhttBuffer = phttZexport:default-buffer-handle.
    for first zexport no-lock
        where zexport.soc-cd = piSoc-cd
          and zexport.libtype-cd = piLibtype-cd
          and zexport.tiers-cle = pcTiers-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer zexport:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttZexport no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getZexport:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table zexport 
    Notes  : service externe. Critère piLibtype-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piLibtype-cd as integer    no-undo.
    define input parameter table-handle phttZexport.
    define variable vhttBuffer as handle  no-undo.
    define buffer zexport for zexport.

    vhttBuffer = phttZexport:default-buffer-handle.
    if piLibtype-cd = ?
    then for each zexport no-lock
        where zexport.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer zexport:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each zexport no-lock
        where zexport.soc-cd = piSoc-cd
          and zexport.libtype-cd = piLibtype-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer zexport:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttZexport no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateZexport private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhLibtype-cd    as handle  no-undo.
    define variable vhTiers-cle    as handle  no-undo.
    define buffer zexport for zexport.

    create query vhttquery.
    vhttBuffer = ghttZexport:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttZexport:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhLibtype-cd, output vhTiers-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first zexport exclusive-lock
                where rowid(zexport) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer zexport:handle, 'soc-cd/libtype-cd/tiers-cle: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhLibtype-cd:buffer-value(), vhTiers-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer zexport:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createZexport private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer zexport for zexport.

    create query vhttquery.
    vhttBuffer = ghttZexport:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttZexport:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create zexport.
            if not outils:copyValidField(buffer zexport:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteZexport private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhLibtype-cd    as handle  no-undo.
    define variable vhTiers-cle    as handle  no-undo.
    define buffer zexport for zexport.

    create query vhttquery.
    vhttBuffer = ghttZexport:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttZexport:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhLibtype-cd, output vhTiers-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first zexport exclusive-lock
                where rowid(Zexport) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer zexport:handle, 'soc-cd/libtype-cd/tiers-cle: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhLibtype-cd:buffer-value(), vhTiers-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete zexport no-error.
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

