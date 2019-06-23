/*------------------------------------------------------------------------
File        : ifdcptage_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifdcptage
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifdcptage.i}
{application/include/error.i}
define variable ghttifdcptage as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phSoc-dest as handle, output phTypefac-cle as handle, output phFgrgt as handle, output phCdcle as handle, output phTaxe-cd as handle, output phCdage as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/soc-dest/typefac-cle/FgRgt/CdCle/taxe-cd/cdage, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'soc-dest' then phSoc-dest = phBuffer:buffer-field(vi).
            when 'typefac-cle' then phTypefac-cle = phBuffer:buffer-field(vi).
            when 'FgRgt' then phFgrgt = phBuffer:buffer-field(vi).
            when 'CdCle' then phCdcle = phBuffer:buffer-field(vi).
            when 'taxe-cd' then phTaxe-cd = phBuffer:buffer-field(vi).
            when 'cdage' then phCdage = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfdcptage private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfdcptage.
    run updateIfdcptage.
    run createIfdcptage.
end procedure.

procedure setIfdcptage:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfdcptage.
    ghttIfdcptage = phttIfdcptage.
    run crudIfdcptage.
    delete object phttIfdcptage.
end procedure.

procedure readIfdcptage:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifdcptage Paramétrage des comptes par agence dans la facturation
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter piSoc-dest    as integer    no-undo.
    define input parameter pcTypefac-cle as character  no-undo.
    define input parameter plFgrgt       as logical    no-undo.
    define input parameter pcCdcle       as character  no-undo.
    define input parameter piTaxe-cd     as integer    no-undo.
    define input parameter pcCdage       as character  no-undo.
    define input parameter table-handle phttIfdcptage.
    define variable vhttBuffer as handle no-undo.
    define buffer ifdcptage for ifdcptage.

    vhttBuffer = phttIfdcptage:default-buffer-handle.
    for first ifdcptage no-lock
        where ifdcptage.soc-cd = piSoc-cd
          and ifdcptage.etab-cd = piEtab-cd
          and ifdcptage.soc-dest = piSoc-dest
          and ifdcptage.typefac-cle = pcTypefac-cle
          and ifdcptage.FgRgt = plFgrgt
          and ifdcptage.CdCle = pcCdcle
          and ifdcptage.taxe-cd = piTaxe-cd
          and ifdcptage.cdage = pcCdage:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdcptage:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdcptage no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfdcptage:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifdcptage Paramétrage des comptes par agence dans la facturation
    Notes  : service externe. Critère piTaxe-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter piSoc-dest    as integer    no-undo.
    define input parameter pcTypefac-cle as character  no-undo.
    define input parameter plFgrgt       as logical    no-undo.
    define input parameter pcCdcle       as character  no-undo.
    define input parameter piTaxe-cd     as integer    no-undo.
    define input parameter table-handle phttIfdcptage.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifdcptage for ifdcptage.

    vhttBuffer = phttIfdcptage:default-buffer-handle.
    if piTaxe-cd = ?
    then for each ifdcptage no-lock
        where ifdcptage.soc-cd = piSoc-cd
          and ifdcptage.etab-cd = piEtab-cd
          and ifdcptage.soc-dest = piSoc-dest
          and ifdcptage.typefac-cle = pcTypefac-cle
          and ifdcptage.FgRgt = plFgrgt
          and ifdcptage.CdCle = pcCdcle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdcptage:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifdcptage no-lock
        where ifdcptage.soc-cd = piSoc-cd
          and ifdcptage.etab-cd = piEtab-cd
          and ifdcptage.soc-dest = piSoc-dest
          and ifdcptage.typefac-cle = pcTypefac-cle
          and ifdcptage.FgRgt = plFgrgt
          and ifdcptage.CdCle = pcCdcle
          and ifdcptage.taxe-cd = piTaxe-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdcptage:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdcptage no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfdcptage private:
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
    define variable vhFgrgt    as handle  no-undo.
    define variable vhCdcle    as handle  no-undo.
    define variable vhTaxe-cd    as handle  no-undo.
    define variable vhCdage    as handle  no-undo.
    define buffer ifdcptage for ifdcptage.

    create query vhttquery.
    vhttBuffer = ghttIfdcptage:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfdcptage:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhSoc-dest, output vhTypefac-cle, output vhFgrgt, output vhCdcle, output vhTaxe-cd, output vhCdage).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdcptage exclusive-lock
                where rowid(ifdcptage) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdcptage:handle, 'soc-cd/etab-cd/soc-dest/typefac-cle/FgRgt/CdCle/taxe-cd/cdage: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhSoc-dest:buffer-value(), vhTypefac-cle:buffer-value(), vhFgrgt:buffer-value(), vhCdcle:buffer-value(), vhTaxe-cd:buffer-value(), vhCdage:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifdcptage:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfdcptage private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifdcptage for ifdcptage.

    create query vhttquery.
    vhttBuffer = ghttIfdcptage:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfdcptage:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifdcptage.
            if not outils:copyValidField(buffer ifdcptage:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfdcptage private:
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
    define variable vhFgrgt    as handle  no-undo.
    define variable vhCdcle    as handle  no-undo.
    define variable vhTaxe-cd    as handle  no-undo.
    define variable vhCdage    as handle  no-undo.
    define buffer ifdcptage for ifdcptage.

    create query vhttquery.
    vhttBuffer = ghttIfdcptage:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfdcptage:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhSoc-dest, output vhTypefac-cle, output vhFgrgt, output vhCdcle, output vhTaxe-cd, output vhCdage).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdcptage exclusive-lock
                where rowid(Ifdcptage) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdcptage:handle, 'soc-cd/etab-cd/soc-dest/typefac-cle/FgRgt/CdCle/taxe-cd/cdage: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhSoc-dest:buffer-value(), vhTypefac-cle:buffer-value(), vhFgrgt:buffer-value(), vhCdcle:buffer-value(), vhTaxe-cd:buffer-value(), vhCdage:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifdcptage no-error.
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

