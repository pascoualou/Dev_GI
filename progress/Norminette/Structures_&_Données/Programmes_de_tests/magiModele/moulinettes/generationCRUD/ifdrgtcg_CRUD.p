/*------------------------------------------------------------------------
File        : ifdrgtcg_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifdrgtcg
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifdrgtcg.i}
{application/include/error.i}
define variable ghttifdrgtcg as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phSoc-dest as handle, output phTypefac-cle as handle, output phRgt-cle as handle, output phTaxe-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/soc-dest/typefac-cle/rgt-cle/taxe-cd, 
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
       end case.
    end.
end function.

procedure crudIfdrgtcg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfdrgtcg.
    run updateIfdrgtcg.
    run createIfdrgtcg.
end procedure.

procedure setIfdrgtcg:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfdrgtcg.
    ghttIfdrgtcg = phttIfdrgtcg.
    run crudIfdrgtcg.
    delete object phttIfdrgtcg.
end procedure.

procedure readIfdrgtcg:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifdrgtcg Tables des correspondances comptes generaux par regroupement
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter piSoc-dest    as integer    no-undo.
    define input parameter pcTypefac-cle as character  no-undo.
    define input parameter pcRgt-cle     as character  no-undo.
    define input parameter piTaxe-cd     as integer    no-undo.
    define input parameter table-handle phttIfdrgtcg.
    define variable vhttBuffer as handle no-undo.
    define buffer ifdrgtcg for ifdrgtcg.

    vhttBuffer = phttIfdrgtcg:default-buffer-handle.
    for first ifdrgtcg no-lock
        where ifdrgtcg.soc-cd = piSoc-cd
          and ifdrgtcg.etab-cd = piEtab-cd
          and ifdrgtcg.soc-dest = piSoc-dest
          and ifdrgtcg.typefac-cle = pcTypefac-cle
          and ifdrgtcg.rgt-cle = pcRgt-cle
          and ifdrgtcg.taxe-cd = piTaxe-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdrgtcg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdrgtcg no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfdrgtcg:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifdrgtcg Tables des correspondances comptes generaux par regroupement
    Notes  : service externe. Critère pcRgt-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter piSoc-dest    as integer    no-undo.
    define input parameter pcTypefac-cle as character  no-undo.
    define input parameter pcRgt-cle     as character  no-undo.
    define input parameter table-handle phttIfdrgtcg.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifdrgtcg for ifdrgtcg.

    vhttBuffer = phttIfdrgtcg:default-buffer-handle.
    if pcRgt-cle = ?
    then for each ifdrgtcg no-lock
        where ifdrgtcg.soc-cd = piSoc-cd
          and ifdrgtcg.etab-cd = piEtab-cd
          and ifdrgtcg.soc-dest = piSoc-dest
          and ifdrgtcg.typefac-cle = pcTypefac-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdrgtcg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifdrgtcg no-lock
        where ifdrgtcg.soc-cd = piSoc-cd
          and ifdrgtcg.etab-cd = piEtab-cd
          and ifdrgtcg.soc-dest = piSoc-dest
          and ifdrgtcg.typefac-cle = pcTypefac-cle
          and ifdrgtcg.rgt-cle = pcRgt-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdrgtcg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdrgtcg no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfdrgtcg private:
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
    define buffer ifdrgtcg for ifdrgtcg.

    create query vhttquery.
    vhttBuffer = ghttIfdrgtcg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfdrgtcg:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhSoc-dest, output vhTypefac-cle, output vhRgt-cle, output vhTaxe-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdrgtcg exclusive-lock
                where rowid(ifdrgtcg) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdrgtcg:handle, 'soc-cd/etab-cd/soc-dest/typefac-cle/rgt-cle/taxe-cd: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhSoc-dest:buffer-value(), vhTypefac-cle:buffer-value(), vhRgt-cle:buffer-value(), vhTaxe-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifdrgtcg:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfdrgtcg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifdrgtcg for ifdrgtcg.

    create query vhttquery.
    vhttBuffer = ghttIfdrgtcg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfdrgtcg:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifdrgtcg.
            if not outils:copyValidField(buffer ifdrgtcg:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfdrgtcg private:
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
    define buffer ifdrgtcg for ifdrgtcg.

    create query vhttquery.
    vhttBuffer = ghttIfdrgtcg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfdrgtcg:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhSoc-dest, output vhTypefac-cle, output vhRgt-cle, output vhTaxe-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdrgtcg exclusive-lock
                where rowid(Ifdrgtcg) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdrgtcg:handle, 'soc-cd/etab-cd/soc-dest/typefac-cle/rgt-cle/taxe-cd: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhSoc-dest:buffer-value(), vhTypefac-cle:buffer-value(), vhRgt-cle:buffer-value(), vhTaxe-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifdrgtcg no-error.
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

