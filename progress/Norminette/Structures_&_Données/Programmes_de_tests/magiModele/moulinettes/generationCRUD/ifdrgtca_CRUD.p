/*------------------------------------------------------------------------
File        : ifdrgtca_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifdrgtca
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifdrgtca.i}
{application/include/error.i}
define variable ghttifdrgtca as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phSoc-dest as handle, output phTypefac-cle as handle, output phRgt-cle as handle, output phTaxe-cd as handle, output phFg-type as handle, output phPos as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/soc-dest/typefac-cle/rgt-cle/taxe-cd/fg-type/pos, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'soc-dest' then phSoc-dest = phBuffer:buffer-field(vi).
            when 'typefac-cle' then phTypefac-cle = phBuffer:buffer-field(vi).
            when 'rgt-cle' then phRgt-cle = phBuffer:buffer-field(vi).
            when 'taxe-cd' then phTaxe-cd = phBuffer:buffer-field(vi).
            when 'fg-type' then phFg-type = phBuffer:buffer-field(vi).
            when 'pos' then phPos = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfdrgtca private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfdrgtca.
    run updateIfdrgtca.
    run createIfdrgtca.
end procedure.

procedure setIfdrgtca:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfdrgtca.
    ghttIfdrgtca = phttIfdrgtca.
    run crudIfdrgtca.
    delete object phttIfdrgtca.
end procedure.

procedure readIfdrgtca:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifdrgtca Tables des correspondances comptes analytiques par regroupement
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter piSoc-dest    as integer    no-undo.
    define input parameter pcTypefac-cle as character  no-undo.
    define input parameter pcRgt-cle     as character  no-undo.
    define input parameter piTaxe-cd     as integer    no-undo.
    define input parameter plFg-type     as logical    no-undo.
    define input parameter piPos         as integer    no-undo.
    define input parameter table-handle phttIfdrgtca.
    define variable vhttBuffer as handle no-undo.
    define buffer ifdrgtca for ifdrgtca.

    vhttBuffer = phttIfdrgtca:default-buffer-handle.
    for first ifdrgtca no-lock
        where ifdrgtca.soc-cd = piSoc-cd
          and ifdrgtca.etab-cd = piEtab-cd
          and ifdrgtca.soc-dest = piSoc-dest
          and ifdrgtca.typefac-cle = pcTypefac-cle
          and ifdrgtca.rgt-cle = pcRgt-cle
          and ifdrgtca.taxe-cd = piTaxe-cd
          and ifdrgtca.fg-type = plFg-type
          and ifdrgtca.pos = piPos:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdrgtca:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdrgtca no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfdrgtca:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifdrgtca Tables des correspondances comptes analytiques par regroupement
    Notes  : service externe. Critère plFg-type = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter piSoc-dest    as integer    no-undo.
    define input parameter pcTypefac-cle as character  no-undo.
    define input parameter pcRgt-cle     as character  no-undo.
    define input parameter piTaxe-cd     as integer    no-undo.
    define input parameter plFg-type     as logical    no-undo.
    define input parameter table-handle phttIfdrgtca.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifdrgtca for ifdrgtca.

    vhttBuffer = phttIfdrgtca:default-buffer-handle.
    if plFg-type = ?
    then for each ifdrgtca no-lock
        where ifdrgtca.soc-cd = piSoc-cd
          and ifdrgtca.etab-cd = piEtab-cd
          and ifdrgtca.soc-dest = piSoc-dest
          and ifdrgtca.typefac-cle = pcTypefac-cle
          and ifdrgtca.rgt-cle = pcRgt-cle
          and ifdrgtca.taxe-cd = piTaxe-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdrgtca:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifdrgtca no-lock
        where ifdrgtca.soc-cd = piSoc-cd
          and ifdrgtca.etab-cd = piEtab-cd
          and ifdrgtca.soc-dest = piSoc-dest
          and ifdrgtca.typefac-cle = pcTypefac-cle
          and ifdrgtca.rgt-cle = pcRgt-cle
          and ifdrgtca.taxe-cd = piTaxe-cd
          and ifdrgtca.fg-type = plFg-type:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdrgtca:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdrgtca no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfdrgtca private:
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
    define variable vhRgt-cle    as handle  no-undo.
    define variable vhTaxe-cd    as handle  no-undo.
    define variable vhFg-type    as handle  no-undo.
    define variable vhPos    as handle  no-undo.
    define buffer ifdrgtca for ifdrgtca.

    create query vhttquery.
    vhttBuffer = ghttIfdrgtca:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfdrgtca:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhSoc-dest, output vhTypefac-cle, output vhRgt-cle, output vhTaxe-cd, output vhFg-type, output vhPos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdrgtca exclusive-lock
                where rowid(ifdrgtca) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdrgtca:handle, 'soc-cd/etab-cd/soc-dest/typefac-cle/rgt-cle/taxe-cd/fg-type/pos: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhSoc-dest:buffer-value(), vhTypefac-cle:buffer-value(), vhRgt-cle:buffer-value(), vhTaxe-cd:buffer-value(), vhFg-type:buffer-value(), vhPos:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifdrgtca:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfdrgtca private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifdrgtca for ifdrgtca.

    create query vhttquery.
    vhttBuffer = ghttIfdrgtca:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfdrgtca:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifdrgtca.
            if not outils:copyValidField(buffer ifdrgtca:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfdrgtca private:
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
    define variable vhRgt-cle    as handle  no-undo.
    define variable vhTaxe-cd    as handle  no-undo.
    define variable vhFg-type    as handle  no-undo.
    define variable vhPos    as handle  no-undo.
    define buffer ifdrgtca for ifdrgtca.

    create query vhttquery.
    vhttBuffer = ghttIfdrgtca:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfdrgtca:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhSoc-dest, output vhTypefac-cle, output vhRgt-cle, output vhTaxe-cd, output vhFg-type, output vhPos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdrgtca exclusive-lock
                where rowid(Ifdrgtca) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdrgtca:handle, 'soc-cd/etab-cd/soc-dest/typefac-cle/rgt-cle/taxe-cd/fg-type/pos: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhSoc-dest:buffer-value(), vhTypefac-cle:buffer-value(), vhRgt-cle:buffer-value(), vhTaxe-cd:buffer-value(), vhFg-type:buffer-value(), vhPos:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifdrgtca no-error.
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

