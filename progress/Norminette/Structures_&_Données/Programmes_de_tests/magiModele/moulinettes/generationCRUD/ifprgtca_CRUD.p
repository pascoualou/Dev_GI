/*------------------------------------------------------------------------
File        : ifprgtca_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifprgtca
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifprgtca.i}
{application/include/error.i}
define variable ghttifprgtca as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phTypefac-cle as handle, output phRgt-cle as handle, output phTaxe-cd as handle, output phPos as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/typefac-cle/rgt-cle/taxe-cd/pos, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'typefac-cle' then phTypefac-cle = phBuffer:buffer-field(vi).
            when 'rgt-cle' then phRgt-cle = phBuffer:buffer-field(vi).
            when 'taxe-cd' then phTaxe-cd = phBuffer:buffer-field(vi).
            when 'pos' then phPos = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfprgtca private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfprgtca.
    run updateIfprgtca.
    run createIfprgtca.
end procedure.

procedure setIfprgtca:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfprgtca.
    ghttIfprgtca = phttIfprgtca.
    run crudIfprgtca.
    delete object phttIfprgtca.
end procedure.

procedure readIfprgtca:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifprgtca Tables des correspondances comptes analytiques par regroupement
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter pcTypefac-cle as character  no-undo.
    define input parameter pcRgt-cle     as character  no-undo.
    define input parameter piTaxe-cd     as integer    no-undo.
    define input parameter piPos         as integer    no-undo.
    define input parameter table-handle phttIfprgtca.
    define variable vhttBuffer as handle no-undo.
    define buffer ifprgtca for ifprgtca.

    vhttBuffer = phttIfprgtca:default-buffer-handle.
    for first ifprgtca no-lock
        where ifprgtca.soc-cd = piSoc-cd
          and ifprgtca.etab-cd = piEtab-cd
          and ifprgtca.typefac-cle = pcTypefac-cle
          and ifprgtca.rgt-cle = pcRgt-cle
          and ifprgtca.taxe-cd = piTaxe-cd
          and ifprgtca.pos = piPos:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifprgtca:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfprgtca no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfprgtca:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifprgtca Tables des correspondances comptes analytiques par regroupement
    Notes  : service externe. Critère piTaxe-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter pcTypefac-cle as character  no-undo.
    define input parameter pcRgt-cle     as character  no-undo.
    define input parameter piTaxe-cd     as integer    no-undo.
    define input parameter table-handle phttIfprgtca.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifprgtca for ifprgtca.

    vhttBuffer = phttIfprgtca:default-buffer-handle.
    if piTaxe-cd = ?
    then for each ifprgtca no-lock
        where ifprgtca.soc-cd = piSoc-cd
          and ifprgtca.etab-cd = piEtab-cd
          and ifprgtca.typefac-cle = pcTypefac-cle
          and ifprgtca.rgt-cle = pcRgt-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifprgtca:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifprgtca no-lock
        where ifprgtca.soc-cd = piSoc-cd
          and ifprgtca.etab-cd = piEtab-cd
          and ifprgtca.typefac-cle = pcTypefac-cle
          and ifprgtca.rgt-cle = pcRgt-cle
          and ifprgtca.taxe-cd = piTaxe-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifprgtca:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfprgtca no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfprgtca private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhTypefac-cle    as handle  no-undo.
    define variable vhRgt-cle    as handle  no-undo.
    define variable vhTaxe-cd    as handle  no-undo.
    define variable vhPos    as handle  no-undo.
    define buffer ifprgtca for ifprgtca.

    create query vhttquery.
    vhttBuffer = ghttIfprgtca:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfprgtca:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTypefac-cle, output vhRgt-cle, output vhTaxe-cd, output vhPos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifprgtca exclusive-lock
                where rowid(ifprgtca) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifprgtca:handle, 'soc-cd/etab-cd/typefac-cle/rgt-cle/taxe-cd/pos: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTypefac-cle:buffer-value(), vhRgt-cle:buffer-value(), vhTaxe-cd:buffer-value(), vhPos:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifprgtca:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfprgtca private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifprgtca for ifprgtca.

    create query vhttquery.
    vhttBuffer = ghttIfprgtca:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfprgtca:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifprgtca.
            if not outils:copyValidField(buffer ifprgtca:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfprgtca private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhTypefac-cle    as handle  no-undo.
    define variable vhRgt-cle    as handle  no-undo.
    define variable vhTaxe-cd    as handle  no-undo.
    define variable vhPos    as handle  no-undo.
    define buffer ifprgtca for ifprgtca.

    create query vhttquery.
    vhttBuffer = ghttIfprgtca:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfprgtca:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTypefac-cle, output vhRgt-cle, output vhTaxe-cd, output vhPos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifprgtca exclusive-lock
                where rowid(Ifprgtca) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifprgtca:handle, 'soc-cd/etab-cd/typefac-cle/rgt-cle/taxe-cd/pos: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTypefac-cle:buffer-value(), vhRgt-cle:buffer-value(), vhTaxe-cd:buffer-value(), vhPos:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifprgtca no-error.
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

