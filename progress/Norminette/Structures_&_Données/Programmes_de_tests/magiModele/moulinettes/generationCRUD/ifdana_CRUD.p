/*------------------------------------------------------------------------
File        : ifdana_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifdana
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifdana.i}
{application/include/error.i}
define variable ghttifdana as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phType-cle as handle, output phCdgen-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/type-cle/cdgen-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'type-cle' then phType-cle = phBuffer:buffer-field(vi).
            when 'cdgen-cle' then phCdgen-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfdana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfdana.
    run updateIfdana.
    run createIfdana.
end procedure.

procedure setIfdana:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfdana.
    ghttIfdana = phttIfdana.
    run crudIfdana.
    delete object phttIfdana.
end procedure.

procedure readIfdana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifdana Table de correspondance des codes analytiques
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcType-cle  as character  no-undo.
    define input parameter pcCdgen-cle as character  no-undo.
    define input parameter table-handle phttIfdana.
    define variable vhttBuffer as handle no-undo.
    define buffer ifdana for ifdana.

    vhttBuffer = phttIfdana:default-buffer-handle.
    for first ifdana no-lock
        where ifdana.soc-cd = piSoc-cd
          and ifdana.etab-cd = piEtab-cd
          and ifdana.type-cle = pcType-cle
          and ifdana.cdgen-cle = pcCdgen-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdana no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfdana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifdana Table de correspondance des codes analytiques
    Notes  : service externe. Critère pcType-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcType-cle  as character  no-undo.
    define input parameter table-handle phttIfdana.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifdana for ifdana.

    vhttBuffer = phttIfdana:default-buffer-handle.
    if pcType-cle = ?
    then for each ifdana no-lock
        where ifdana.soc-cd = piSoc-cd
          and ifdana.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifdana no-lock
        where ifdana.soc-cd = piSoc-cd
          and ifdana.etab-cd = piEtab-cd
          and ifdana.type-cle = pcType-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdana no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfdana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhType-cle    as handle  no-undo.
    define variable vhCdgen-cle    as handle  no-undo.
    define buffer ifdana for ifdana.

    create query vhttquery.
    vhttBuffer = ghttIfdana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfdana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhType-cle, output vhCdgen-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdana exclusive-lock
                where rowid(ifdana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdana:handle, 'soc-cd/etab-cd/type-cle/cdgen-cle: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhType-cle:buffer-value(), vhCdgen-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifdana:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfdana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifdana for ifdana.

    create query vhttquery.
    vhttBuffer = ghttIfdana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfdana:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifdana.
            if not outils:copyValidField(buffer ifdana:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfdana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhType-cle    as handle  no-undo.
    define variable vhCdgen-cle    as handle  no-undo.
    define buffer ifdana for ifdana.

    create query vhttquery.
    vhttBuffer = ghttIfdana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfdana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhType-cle, output vhCdgen-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdana exclusive-lock
                where rowid(Ifdana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdana:handle, 'soc-cd/etab-cd/type-cle/cdgen-cle: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhType-cle:buffer-value(), vhCdgen-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifdana no-error.
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

