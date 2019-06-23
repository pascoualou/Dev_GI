/*------------------------------------------------------------------------
File        : ifpartcg_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifpartcg
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifpartcg.i}
{application/include/error.i}
define variable ghttifpartcg as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phTypefac-cle as handle, output phArt-cle as handle, output phTaxe-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/typefac-cle/art-cle/taxe-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'typefac-cle' then phTypefac-cle = phBuffer:buffer-field(vi).
            when 'art-cle' then phArt-cle = phBuffer:buffer-field(vi).
            when 'taxe-cd' then phTaxe-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfpartcg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfpartcg.
    run updateIfpartcg.
    run createIfpartcg.
end procedure.

procedure setIfpartcg:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfpartcg.
    ghttIfpartcg = phttIfpartcg.
    run crudIfpartcg.
    delete object phttIfpartcg.
end procedure.

procedure readIfpartcg:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifpartcg Tables des correspondances comptes generaux par article
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter pcTypefac-cle as character  no-undo.
    define input parameter pcArt-cle     as character  no-undo.
    define input parameter piTaxe-cd     as integer    no-undo.
    define input parameter table-handle phttIfpartcg.
    define variable vhttBuffer as handle no-undo.
    define buffer ifpartcg for ifpartcg.

    vhttBuffer = phttIfpartcg:default-buffer-handle.
    for first ifpartcg no-lock
        where ifpartcg.soc-cd = piSoc-cd
          and ifpartcg.etab-cd = piEtab-cd
          and ifpartcg.typefac-cle = pcTypefac-cle
          and ifpartcg.art-cle = pcArt-cle
          and ifpartcg.taxe-cd = piTaxe-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpartcg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfpartcg no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfpartcg:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifpartcg Tables des correspondances comptes generaux par article
    Notes  : service externe. Critère pcArt-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter pcTypefac-cle as character  no-undo.
    define input parameter pcArt-cle     as character  no-undo.
    define input parameter table-handle phttIfpartcg.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifpartcg for ifpartcg.

    vhttBuffer = phttIfpartcg:default-buffer-handle.
    if pcArt-cle = ?
    then for each ifpartcg no-lock
        where ifpartcg.soc-cd = piSoc-cd
          and ifpartcg.etab-cd = piEtab-cd
          and ifpartcg.typefac-cle = pcTypefac-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpartcg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifpartcg no-lock
        where ifpartcg.soc-cd = piSoc-cd
          and ifpartcg.etab-cd = piEtab-cd
          and ifpartcg.typefac-cle = pcTypefac-cle
          and ifpartcg.art-cle = pcArt-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpartcg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfpartcg no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfpartcg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhTypefac-cle    as handle  no-undo.
    define variable vhArt-cle    as handle  no-undo.
    define variable vhTaxe-cd    as handle  no-undo.
    define buffer ifpartcg for ifpartcg.

    create query vhttquery.
    vhttBuffer = ghttIfpartcg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfpartcg:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTypefac-cle, output vhArt-cle, output vhTaxe-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifpartcg exclusive-lock
                where rowid(ifpartcg) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifpartcg:handle, 'soc-cd/etab-cd/typefac-cle/art-cle/taxe-cd: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTypefac-cle:buffer-value(), vhArt-cle:buffer-value(), vhTaxe-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifpartcg:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfpartcg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifpartcg for ifpartcg.

    create query vhttquery.
    vhttBuffer = ghttIfpartcg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfpartcg:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifpartcg.
            if not outils:copyValidField(buffer ifpartcg:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfpartcg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhTypefac-cle    as handle  no-undo.
    define variable vhArt-cle    as handle  no-undo.
    define variable vhTaxe-cd    as handle  no-undo.
    define buffer ifpartcg for ifpartcg.

    create query vhttquery.
    vhttBuffer = ghttIfpartcg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfpartcg:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTypefac-cle, output vhArt-cle, output vhTaxe-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifpartcg exclusive-lock
                where rowid(Ifpartcg) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifpartcg:handle, 'soc-cd/etab-cd/typefac-cle/art-cle/taxe-cd: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTypefac-cle:buffer-value(), vhArt-cle:buffer-value(), vhTaxe-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifpartcg no-error.
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

