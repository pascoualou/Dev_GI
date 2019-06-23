/*------------------------------------------------------------------------
File        : ifpartca_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifpartca
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifpartca.i}
{application/include/error.i}
define variable ghttifpartca as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phTypefac-cle as handle, output phArt-cle as handle, output phTaxe-cd as handle, output phPos as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/typefac-cle/art-cle/taxe-cd/pos, 
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
            when 'pos' then phPos = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfpartca private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfpartca.
    run updateIfpartca.
    run createIfpartca.
end procedure.

procedure setIfpartca:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfpartca.
    ghttIfpartca = phttIfpartca.
    run crudIfpartca.
    delete object phttIfpartca.
end procedure.

procedure readIfpartca:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifpartca Tables des correspondances comptes analytiques par article
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter pcTypefac-cle as character  no-undo.
    define input parameter pcArt-cle     as character  no-undo.
    define input parameter piTaxe-cd     as integer    no-undo.
    define input parameter piPos         as integer    no-undo.
    define input parameter table-handle phttIfpartca.
    define variable vhttBuffer as handle no-undo.
    define buffer ifpartca for ifpartca.

    vhttBuffer = phttIfpartca:default-buffer-handle.
    for first ifpartca no-lock
        where ifpartca.soc-cd = piSoc-cd
          and ifpartca.etab-cd = piEtab-cd
          and ifpartca.typefac-cle = pcTypefac-cle
          and ifpartca.art-cle = pcArt-cle
          and ifpartca.taxe-cd = piTaxe-cd
          and ifpartca.pos = piPos:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpartca:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfpartca no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfpartca:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifpartca Tables des correspondances comptes analytiques par article
    Notes  : service externe. Critère piTaxe-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter pcTypefac-cle as character  no-undo.
    define input parameter pcArt-cle     as character  no-undo.
    define input parameter piTaxe-cd     as integer    no-undo.
    define input parameter table-handle phttIfpartca.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifpartca for ifpartca.

    vhttBuffer = phttIfpartca:default-buffer-handle.
    if piTaxe-cd = ?
    then for each ifpartca no-lock
        where ifpartca.soc-cd = piSoc-cd
          and ifpartca.etab-cd = piEtab-cd
          and ifpartca.typefac-cle = pcTypefac-cle
          and ifpartca.art-cle = pcArt-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpartca:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifpartca no-lock
        where ifpartca.soc-cd = piSoc-cd
          and ifpartca.etab-cd = piEtab-cd
          and ifpartca.typefac-cle = pcTypefac-cle
          and ifpartca.art-cle = pcArt-cle
          and ifpartca.taxe-cd = piTaxe-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpartca:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfpartca no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfpartca private:
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
    define variable vhPos    as handle  no-undo.
    define buffer ifpartca for ifpartca.

    create query vhttquery.
    vhttBuffer = ghttIfpartca:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfpartca:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTypefac-cle, output vhArt-cle, output vhTaxe-cd, output vhPos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifpartca exclusive-lock
                where rowid(ifpartca) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifpartca:handle, 'soc-cd/etab-cd/typefac-cle/art-cle/taxe-cd/pos: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTypefac-cle:buffer-value(), vhArt-cle:buffer-value(), vhTaxe-cd:buffer-value(), vhPos:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifpartca:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfpartca private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifpartca for ifpartca.

    create query vhttquery.
    vhttBuffer = ghttIfpartca:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfpartca:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifpartca.
            if not outils:copyValidField(buffer ifpartca:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfpartca private:
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
    define variable vhPos    as handle  no-undo.
    define buffer ifpartca for ifpartca.

    create query vhttquery.
    vhttBuffer = ghttIfpartca:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfpartca:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTypefac-cle, output vhArt-cle, output vhTaxe-cd, output vhPos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifpartca exclusive-lock
                where rowid(Ifpartca) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifpartca:handle, 'soc-cd/etab-cd/typefac-cle/art-cle/taxe-cd/pos: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTypefac-cle:buffer-value(), vhArt-cle:buffer-value(), vhTaxe-cd:buffer-value(), vhPos:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifpartca no-error.
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

