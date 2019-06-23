/*------------------------------------------------------------------------
File        : ifdartca_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifdartca
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifdartca.i}
{application/include/error.i}
define variable ghttifdartca as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phSoc-dest as handle, output phTypefac-cle as handle, output phArt-cle as handle, output phTaxe-cd as handle, output phFg-type as handle, output phPos as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/soc-dest/typefac-cle/art-cle/taxe-cd/fg-type/pos, 
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
            when 'fg-type' then phFg-type = phBuffer:buffer-field(vi).
            when 'pos' then phPos = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfdartca private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfdartca.
    run updateIfdartca.
    run createIfdartca.
end procedure.

procedure setIfdartca:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfdartca.
    ghttIfdartca = phttIfdartca.
    run crudIfdartca.
    delete object phttIfdartca.
end procedure.

procedure readIfdartca:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifdartca Tables des correspondances comptes analytiques par article
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter piSoc-dest    as integer    no-undo.
    define input parameter pcTypefac-cle as character  no-undo.
    define input parameter pcArt-cle     as character  no-undo.
    define input parameter piTaxe-cd     as integer    no-undo.
    define input parameter plFg-type     as logical    no-undo.
    define input parameter piPos         as integer    no-undo.
    define input parameter table-handle phttIfdartca.
    define variable vhttBuffer as handle no-undo.
    define buffer ifdartca for ifdartca.

    vhttBuffer = phttIfdartca:default-buffer-handle.
    for first ifdartca no-lock
        where ifdartca.soc-cd = piSoc-cd
          and ifdartca.etab-cd = piEtab-cd
          and ifdartca.soc-dest = piSoc-dest
          and ifdartca.typefac-cle = pcTypefac-cle
          and ifdartca.art-cle = pcArt-cle
          and ifdartca.taxe-cd = piTaxe-cd
          and ifdartca.fg-type = plFg-type
          and ifdartca.pos = piPos:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdartca:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdartca no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfdartca:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifdartca Tables des correspondances comptes analytiques par article
    Notes  : service externe. Critère plFg-type = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter piSoc-dest    as integer    no-undo.
    define input parameter pcTypefac-cle as character  no-undo.
    define input parameter pcArt-cle     as character  no-undo.
    define input parameter piTaxe-cd     as integer    no-undo.
    define input parameter plFg-type     as logical    no-undo.
    define input parameter table-handle phttIfdartca.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifdartca for ifdartca.

    vhttBuffer = phttIfdartca:default-buffer-handle.
    if plFg-type = ?
    then for each ifdartca no-lock
        where ifdartca.soc-cd = piSoc-cd
          and ifdartca.etab-cd = piEtab-cd
          and ifdartca.soc-dest = piSoc-dest
          and ifdartca.typefac-cle = pcTypefac-cle
          and ifdartca.art-cle = pcArt-cle
          and ifdartca.taxe-cd = piTaxe-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdartca:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifdartca no-lock
        where ifdartca.soc-cd = piSoc-cd
          and ifdartca.etab-cd = piEtab-cd
          and ifdartca.soc-dest = piSoc-dest
          and ifdartca.typefac-cle = pcTypefac-cle
          and ifdartca.art-cle = pcArt-cle
          and ifdartca.taxe-cd = piTaxe-cd
          and ifdartca.fg-type = plFg-type:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdartca:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdartca no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfdartca private:
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
    define variable vhFg-type    as handle  no-undo.
    define variable vhPos    as handle  no-undo.
    define buffer ifdartca for ifdartca.

    create query vhttquery.
    vhttBuffer = ghttIfdartca:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfdartca:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhSoc-dest, output vhTypefac-cle, output vhArt-cle, output vhTaxe-cd, output vhFg-type, output vhPos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdartca exclusive-lock
                where rowid(ifdartca) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdartca:handle, 'soc-cd/etab-cd/soc-dest/typefac-cle/art-cle/taxe-cd/fg-type/pos: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhSoc-dest:buffer-value(), vhTypefac-cle:buffer-value(), vhArt-cle:buffer-value(), vhTaxe-cd:buffer-value(), vhFg-type:buffer-value(), vhPos:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifdartca:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfdartca private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifdartca for ifdartca.

    create query vhttquery.
    vhttBuffer = ghttIfdartca:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfdartca:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifdartca.
            if not outils:copyValidField(buffer ifdartca:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfdartca private:
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
    define variable vhFg-type    as handle  no-undo.
    define variable vhPos    as handle  no-undo.
    define buffer ifdartca for ifdartca.

    create query vhttquery.
    vhttBuffer = ghttIfdartca:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfdartca:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhSoc-dest, output vhTypefac-cle, output vhArt-cle, output vhTaxe-cd, output vhFg-type, output vhPos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdartca exclusive-lock
                where rowid(Ifdartca) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdartca:handle, 'soc-cd/etab-cd/soc-dest/typefac-cle/art-cle/taxe-cd/fg-type/pos: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhSoc-dest:buffer-value(), vhTypefac-cle:buffer-value(), vhArt-cle:buffer-value(), vhTaxe-cd:buffer-value(), vhFg-type:buffer-value(), vhPos:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifdartca no-error.
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

