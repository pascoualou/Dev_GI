/*------------------------------------------------------------------------
File        : corcpt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table corcpt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/corcpt.i}
{application/include/error.i}
define variable ghttcorcpt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phPrest-cd as handle, output phTaxe-cd as handle, output phSscoll-cle as handle, output phCpt-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/prest-cd/taxe-cd/sscoll-cle/cpt-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'prest-cd' then phPrest-cd = phBuffer:buffer-field(vi).
            when 'taxe-cd' then phTaxe-cd = phBuffer:buffer-field(vi).
            when 'sscoll-cle' then phSscoll-cle = phBuffer:buffer-field(vi).
            when 'cpt-cd' then phCpt-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCorcpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCorcpt.
    run updateCorcpt.
    run createCorcpt.
end procedure.

procedure setCorcpt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCorcpt.
    ghttCorcpt = phttCorcpt.
    run crudCorcpt.
    delete object phttCorcpt.
end procedure.

procedure readCorcpt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table corcpt 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter piPrest-cd   as integer    no-undo.
    define input parameter piTaxe-cd    as integer    no-undo.
    define input parameter pcSscoll-cle as character  no-undo.
    define input parameter pcCpt-cd     as character  no-undo.
    define input parameter table-handle phttCorcpt.
    define variable vhttBuffer as handle no-undo.
    define buffer corcpt for corcpt.

    vhttBuffer = phttCorcpt:default-buffer-handle.
    for first corcpt no-lock
        where corcpt.soc-cd = piSoc-cd
          and corcpt.etab-cd = piEtab-cd
          and corcpt.prest-cd = piPrest-cd
          and corcpt.taxe-cd = piTaxe-cd
          and corcpt.sscoll-cle = pcSscoll-cle
          and corcpt.cpt-cd = pcCpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer corcpt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCorcpt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCorcpt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table corcpt 
    Notes  : service externe. Critère pcSscoll-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter piPrest-cd   as integer    no-undo.
    define input parameter piTaxe-cd    as integer    no-undo.
    define input parameter pcSscoll-cle as character  no-undo.
    define input parameter table-handle phttCorcpt.
    define variable vhttBuffer as handle  no-undo.
    define buffer corcpt for corcpt.

    vhttBuffer = phttCorcpt:default-buffer-handle.
    if pcSscoll-cle = ?
    then for each corcpt no-lock
        where corcpt.soc-cd = piSoc-cd
          and corcpt.etab-cd = piEtab-cd
          and corcpt.prest-cd = piPrest-cd
          and corcpt.taxe-cd = piTaxe-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer corcpt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each corcpt no-lock
        where corcpt.soc-cd = piSoc-cd
          and corcpt.etab-cd = piEtab-cd
          and corcpt.prest-cd = piPrest-cd
          and corcpt.taxe-cd = piTaxe-cd
          and corcpt.sscoll-cle = pcSscoll-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer corcpt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCorcpt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCorcpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhPrest-cd    as handle  no-undo.
    define variable vhTaxe-cd    as handle  no-undo.
    define variable vhSscoll-cle    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer corcpt for corcpt.

    create query vhttquery.
    vhttBuffer = ghttCorcpt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCorcpt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhPrest-cd, output vhTaxe-cd, output vhSscoll-cle, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first corcpt exclusive-lock
                where rowid(corcpt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer corcpt:handle, 'soc-cd/etab-cd/prest-cd/taxe-cd/sscoll-cle/cpt-cd: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhPrest-cd:buffer-value(), vhTaxe-cd:buffer-value(), vhSscoll-cle:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer corcpt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCorcpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer corcpt for corcpt.

    create query vhttquery.
    vhttBuffer = ghttCorcpt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCorcpt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create corcpt.
            if not outils:copyValidField(buffer corcpt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCorcpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhPrest-cd    as handle  no-undo.
    define variable vhTaxe-cd    as handle  no-undo.
    define variable vhSscoll-cle    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer corcpt for corcpt.

    create query vhttquery.
    vhttBuffer = ghttCorcpt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCorcpt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhPrest-cd, output vhTaxe-cd, output vhSscoll-cle, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first corcpt exclusive-lock
                where rowid(Corcpt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer corcpt:handle, 'soc-cd/etab-cd/prest-cd/taxe-cd/sscoll-cle/cpt-cd: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhPrest-cd:buffer-value(), vhTaxe-cd:buffer-value(), vhSscoll-cle:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete corcpt no-error.
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

