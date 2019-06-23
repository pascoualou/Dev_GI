/*------------------------------------------------------------------------
File        : pinterf_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table pinterf
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/pinterf.i}
{application/include/error.i}
define variable ghttpinterf as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phType-int as handle, output phTaxe-cd as handle, output phGroupe as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/type-int/taxe-cd/groupe, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'type-int' then phType-int = phBuffer:buffer-field(vi).
            when 'taxe-cd' then phTaxe-cd = phBuffer:buffer-field(vi).
            when 'groupe' then phGroupe = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPinterf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePinterf.
    run updatePinterf.
    run createPinterf.
end procedure.

procedure setPinterf:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPinterf.
    ghttPinterf = phttPinterf.
    run crudPinterf.
    delete object phttPinterf.
end procedure.

procedure readPinterf:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table pinterf Fichier interface comptabilite
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter piType-int as integer    no-undo.
    define input parameter piTaxe-cd  as integer    no-undo.
    define input parameter plGroupe   as logical    no-undo.
    define input parameter table-handle phttPinterf.
    define variable vhttBuffer as handle no-undo.
    define buffer pinterf for pinterf.

    vhttBuffer = phttPinterf:default-buffer-handle.
    for first pinterf no-lock
        where pinterf.soc-cd = piSoc-cd
          and pinterf.etab-cd = piEtab-cd
          and pinterf.type-int = piType-int
          and pinterf.taxe-cd = piTaxe-cd
          and pinterf.groupe = plGroupe:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pinterf:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPinterf no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPinterf:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table pinterf Fichier interface comptabilite
    Notes  : service externe. Critère piTaxe-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter piType-int as integer    no-undo.
    define input parameter piTaxe-cd  as integer    no-undo.
    define input parameter table-handle phttPinterf.
    define variable vhttBuffer as handle  no-undo.
    define buffer pinterf for pinterf.

    vhttBuffer = phttPinterf:default-buffer-handle.
    if piTaxe-cd = ?
    then for each pinterf no-lock
        where pinterf.soc-cd = piSoc-cd
          and pinterf.etab-cd = piEtab-cd
          and pinterf.type-int = piType-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pinterf:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each pinterf no-lock
        where pinterf.soc-cd = piSoc-cd
          and pinterf.etab-cd = piEtab-cd
          and pinterf.type-int = piType-int
          and pinterf.taxe-cd = piTaxe-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pinterf:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPinterf no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePinterf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhType-int    as handle  no-undo.
    define variable vhTaxe-cd    as handle  no-undo.
    define variable vhGroupe    as handle  no-undo.
    define buffer pinterf for pinterf.

    create query vhttquery.
    vhttBuffer = ghttPinterf:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPinterf:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhType-int, output vhTaxe-cd, output vhGroupe).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pinterf exclusive-lock
                where rowid(pinterf) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pinterf:handle, 'soc-cd/etab-cd/type-int/taxe-cd/groupe: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhType-int:buffer-value(), vhTaxe-cd:buffer-value(), vhGroupe:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer pinterf:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPinterf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer pinterf for pinterf.

    create query vhttquery.
    vhttBuffer = ghttPinterf:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPinterf:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create pinterf.
            if not outils:copyValidField(buffer pinterf:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePinterf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhType-int    as handle  no-undo.
    define variable vhTaxe-cd    as handle  no-undo.
    define variable vhGroupe    as handle  no-undo.
    define buffer pinterf for pinterf.

    create query vhttquery.
    vhttBuffer = ghttPinterf:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPinterf:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhType-int, output vhTaxe-cd, output vhGroupe).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pinterf exclusive-lock
                where rowid(Pinterf) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pinterf:handle, 'soc-cd/etab-cd/type-int/taxe-cd/groupe: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhType-int:buffer-value(), vhTaxe-cd:buffer-value(), vhGroupe:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete pinterf no-error.
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

