/*------------------------------------------------------------------------
File        : ifdartcg_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifdartcg
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifdartcg.i}
{application/include/error.i}
define variable ghttifdartcg as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phSoc-dest as handle, output phTypefac-cle as handle, output phArt-cle as handle, output phTaxe-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/soc-dest/typefac-cle/art-cle/taxe-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'soc-dest' then phSoc-dest = phBuffer:buffer-field(vi).
            when 'typefac-cle' then phTypefac-cle = phBuffer:buffer-field(vi).
            when 'art-cle' then phArt-cle = phBuffer:buffer-field(vi).
            when 'taxe-cd' then phTaxe-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfdartcg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfdartcg.
    run updateIfdartcg.
    run createIfdartcg.
end procedure.

procedure setIfdartcg:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfdartcg.
    ghttIfdartcg = phttIfdartcg.
    run crudIfdartcg.
    delete object phttIfdartcg.
end procedure.

procedure readIfdartcg:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifdartcg Tables des correspondances comptes generaux par article
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter piSoc-dest    as integer    no-undo.
    define input parameter pcTypefac-cle as character  no-undo.
    define input parameter pcArt-cle     as character  no-undo.
    define input parameter piTaxe-cd     as integer    no-undo.
    define input parameter table-handle phttIfdartcg.
    define variable vhttBuffer as handle no-undo.
    define buffer ifdartcg for ifdartcg.

    vhttBuffer = phttIfdartcg:default-buffer-handle.
    for first ifdartcg no-lock
        where ifdartcg.soc-cd = piSoc-cd
          and ifdartcg.etab-cd = piEtab-cd
          and ifdartcg.soc-dest = piSoc-dest
          and ifdartcg.typefac-cle = pcTypefac-cle
          and ifdartcg.art-cle = pcArt-cle
          and ifdartcg.taxe-cd = piTaxe-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdartcg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdartcg no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfdartcg:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifdartcg Tables des correspondances comptes generaux par article
    Notes  : service externe. Critère pcArt-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter piSoc-dest    as integer    no-undo.
    define input parameter pcTypefac-cle as character  no-undo.
    define input parameter pcArt-cle     as character  no-undo.
    define input parameter table-handle phttIfdartcg.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifdartcg for ifdartcg.

    vhttBuffer = phttIfdartcg:default-buffer-handle.
    if pcArt-cle = ?
    then for each ifdartcg no-lock
        where ifdartcg.soc-cd = piSoc-cd
          and ifdartcg.etab-cd = piEtab-cd
          and ifdartcg.soc-dest = piSoc-dest
          and ifdartcg.typefac-cle = pcTypefac-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdartcg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifdartcg no-lock
        where ifdartcg.soc-cd = piSoc-cd
          and ifdartcg.etab-cd = piEtab-cd
          and ifdartcg.soc-dest = piSoc-dest
          and ifdartcg.typefac-cle = pcTypefac-cle
          and ifdartcg.art-cle = pcArt-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdartcg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdartcg no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfdartcg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhSoc-dest    as handle  no-undo.
    define variable vhTypefac-cle    as handle  no-undo.
    define variable vhArt-cle    as handle  no-undo.
    define variable vhTaxe-cd    as handle  no-undo.
    define buffer ifdartcg for ifdartcg.

    create query vhttquery.
    vhttBuffer = ghttIfdartcg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfdartcg:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhSoc-dest, output vhTypefac-cle, output vhArt-cle, output vhTaxe-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdartcg exclusive-lock
                where rowid(ifdartcg) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdartcg:handle, 'soc-cd/etab-cd/soc-dest/typefac-cle/art-cle/taxe-cd: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhSoc-dest:buffer-value(), vhTypefac-cle:buffer-value(), vhArt-cle:buffer-value(), vhTaxe-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifdartcg:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfdartcg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifdartcg for ifdartcg.

    create query vhttquery.
    vhttBuffer = ghttIfdartcg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfdartcg:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifdartcg.
            if not outils:copyValidField(buffer ifdartcg:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfdartcg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhSoc-dest    as handle  no-undo.
    define variable vhTypefac-cle    as handle  no-undo.
    define variable vhArt-cle    as handle  no-undo.
    define variable vhTaxe-cd    as handle  no-undo.
    define buffer ifdartcg for ifdartcg.

    create query vhttquery.
    vhttBuffer = ghttIfdartcg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfdartcg:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhSoc-dest, output vhTypefac-cle, output vhArt-cle, output vhTaxe-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdartcg exclusive-lock
                where rowid(Ifdartcg) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdartcg:handle, 'soc-cd/etab-cd/soc-dest/typefac-cle/art-cle/taxe-cd: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhSoc-dest:buffer-value(), vhTypefac-cle:buffer-value(), vhArt-cle:buffer-value(), vhTaxe-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifdartcg no-error.
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

