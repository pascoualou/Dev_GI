/*------------------------------------------------------------------------
File        : itcgen_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table itcgen
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/itcgen.i}
{application/include/error.i}
define variable ghttitcgen as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phNature-cd as handle, output phType-cd as handle, output phCod-op as handle, output phTaxe-cd as handle, output phSscoll-cle as handle, output phRgt-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/nature-cd/type-cd/cod-op/taxe-cd/sscoll-cle/rgt-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'nature-cd' then phNature-cd = phBuffer:buffer-field(vi).
            when 'type-cd' then phType-cd = phBuffer:buffer-field(vi).
            when 'cod-op' then phCod-op = phBuffer:buffer-field(vi).
            when 'taxe-cd' then phTaxe-cd = phBuffer:buffer-field(vi).
            when 'sscoll-cle' then phSscoll-cle = phBuffer:buffer-field(vi).
            when 'rgt-cd' then phRgt-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudItcgen private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteItcgen.
    run updateItcgen.
    run createItcgen.
end procedure.

procedure setItcgen:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttItcgen.
    ghttItcgen = phttItcgen.
    run crudItcgen.
    delete object phttItcgen.
end procedure.

procedure readItcgen:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table itcgen Transfert compta - parametres compta generale
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcNature-cd  as character  no-undo.
    define input parameter piType-cd    as integer    no-undo.
    define input parameter pcCod-op     as character  no-undo.
    define input parameter piTaxe-cd    as integer    no-undo.
    define input parameter pcSscoll-cle as character  no-undo.
    define input parameter pcRgt-cd     as character  no-undo.
    define input parameter table-handle phttItcgen.
    define variable vhttBuffer as handle no-undo.
    define buffer itcgen for itcgen.

    vhttBuffer = phttItcgen:default-buffer-handle.
    for first itcgen no-lock
        where itcgen.soc-cd = piSoc-cd
          and itcgen.etab-cd = piEtab-cd
          and itcgen.nature-cd = pcNature-cd
          and itcgen.type-cd = piType-cd
          and itcgen.cod-op = pcCod-op
          and itcgen.taxe-cd = piTaxe-cd
          and itcgen.sscoll-cle = pcSscoll-cle
          and itcgen.rgt-cd = pcRgt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itcgen:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttItcgen no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getItcgen:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table itcgen Transfert compta - parametres compta generale
    Notes  : service externe. Critère pcSscoll-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcNature-cd  as character  no-undo.
    define input parameter piType-cd    as integer    no-undo.
    define input parameter pcCod-op     as character  no-undo.
    define input parameter piTaxe-cd    as integer    no-undo.
    define input parameter pcSscoll-cle as character  no-undo.
    define input parameter table-handle phttItcgen.
    define variable vhttBuffer as handle  no-undo.
    define buffer itcgen for itcgen.

    vhttBuffer = phttItcgen:default-buffer-handle.
    if pcSscoll-cle = ?
    then for each itcgen no-lock
        where itcgen.soc-cd = piSoc-cd
          and itcgen.etab-cd = piEtab-cd
          and itcgen.nature-cd = pcNature-cd
          and itcgen.type-cd = piType-cd
          and itcgen.cod-op = pcCod-op
          and itcgen.taxe-cd = piTaxe-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itcgen:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each itcgen no-lock
        where itcgen.soc-cd = piSoc-cd
          and itcgen.etab-cd = piEtab-cd
          and itcgen.nature-cd = pcNature-cd
          and itcgen.type-cd = piType-cd
          and itcgen.cod-op = pcCod-op
          and itcgen.taxe-cd = piTaxe-cd
          and itcgen.sscoll-cle = pcSscoll-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itcgen:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttItcgen no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateItcgen private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNature-cd    as handle  no-undo.
    define variable vhType-cd    as handle  no-undo.
    define variable vhCod-op    as handle  no-undo.
    define variable vhTaxe-cd    as handle  no-undo.
    define variable vhSscoll-cle    as handle  no-undo.
    define variable vhRgt-cd    as handle  no-undo.
    define buffer itcgen for itcgen.

    create query vhttquery.
    vhttBuffer = ghttItcgen:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttItcgen:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNature-cd, output vhType-cd, output vhCod-op, output vhTaxe-cd, output vhSscoll-cle, output vhRgt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first itcgen exclusive-lock
                where rowid(itcgen) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer itcgen:handle, 'soc-cd/etab-cd/nature-cd/type-cd/cod-op/taxe-cd/sscoll-cle/rgt-cd: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNature-cd:buffer-value(), vhType-cd:buffer-value(), vhCod-op:buffer-value(), vhTaxe-cd:buffer-value(), vhSscoll-cle:buffer-value(), vhRgt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer itcgen:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createItcgen private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer itcgen for itcgen.

    create query vhttquery.
    vhttBuffer = ghttItcgen:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttItcgen:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create itcgen.
            if not outils:copyValidField(buffer itcgen:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteItcgen private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNature-cd    as handle  no-undo.
    define variable vhType-cd    as handle  no-undo.
    define variable vhCod-op    as handle  no-undo.
    define variable vhTaxe-cd    as handle  no-undo.
    define variable vhSscoll-cle    as handle  no-undo.
    define variable vhRgt-cd    as handle  no-undo.
    define buffer itcgen for itcgen.

    create query vhttquery.
    vhttBuffer = ghttItcgen:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttItcgen:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNature-cd, output vhType-cd, output vhCod-op, output vhTaxe-cd, output vhSscoll-cle, output vhRgt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first itcgen exclusive-lock
                where rowid(Itcgen) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer itcgen:handle, 'soc-cd/etab-cd/nature-cd/type-cd/cod-op/taxe-cd/sscoll-cle/rgt-cd: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNature-cd:buffer-value(), vhType-cd:buffer-value(), vhCod-op:buffer-value(), vhTaxe-cd:buffer-value(), vhSscoll-cle:buffer-value(), vhRgt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete itcgen no-error.
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

