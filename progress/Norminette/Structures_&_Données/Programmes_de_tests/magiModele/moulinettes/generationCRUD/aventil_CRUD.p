/*------------------------------------------------------------------------
File        : aventil_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table aventil
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/aventil.i}
{application/include/error.i}
define variable ghttaventil as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phNolot as handle, output phType as handle, output phRub-cd as handle, output phSsrub-cd as handle, output phFisc-cle as handle, output phDtdeb as handle, output phCpt-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/Nolot/type/rub-cd/ssrub-cd/fisc-cle/dtdeb/cpt-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'Nolot' then phNolot = phBuffer:buffer-field(vi).
            when 'type' then phType = phBuffer:buffer-field(vi).
            when 'rub-cd' then phRub-cd = phBuffer:buffer-field(vi).
            when 'ssrub-cd' then phSsrub-cd = phBuffer:buffer-field(vi).
            when 'fisc-cle' then phFisc-cle = phBuffer:buffer-field(vi).
            when 'dtdeb' then phDtdeb = phBuffer:buffer-field(vi).
            when 'cpt-cd' then phCpt-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAventil private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAventil.
    run updateAventil.
    run createAventil.
end procedure.

procedure setAventil:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAventil.
    ghttAventil = phttAventil.
    run crudAventil.
    delete object phttAventil.
end procedure.

procedure readAventil:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table aventil Table de ventilation des dépenses de nu propriété
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter piNolot    as integer    no-undo.
    define input parameter pcType     as character  no-undo.
    define input parameter pcRub-cd   as character  no-undo.
    define input parameter pcSsrub-cd as character  no-undo.
    define input parameter pcFisc-cle as character  no-undo.
    define input parameter pdaDtdeb    as date       no-undo.
    define input parameter pcCpt-cd   as character  no-undo.
    define input parameter table-handle phttAventil.
    define variable vhttBuffer as handle no-undo.
    define buffer aventil for aventil.

    vhttBuffer = phttAventil:default-buffer-handle.
    for first aventil no-lock
        where aventil.soc-cd = piSoc-cd
          and aventil.etab-cd = piEtab-cd
          and aventil.Nolot = piNolot
          and aventil.type = pcType
          and aventil.rub-cd = pcRub-cd
          and aventil.ssrub-cd = pcSsrub-cd
          and aventil.fisc-cle = pcFisc-cle
          and aventil.dtdeb = pdaDtdeb
          and aventil.cpt-cd = pcCpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aventil:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAventil no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAventil:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table aventil Table de ventilation des dépenses de nu propriété
    Notes  : service externe. Critère pdaDtdeb = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter piNolot    as integer    no-undo.
    define input parameter pcType     as character  no-undo.
    define input parameter pcRub-cd   as character  no-undo.
    define input parameter pcSsrub-cd as character  no-undo.
    define input parameter pcFisc-cle as character  no-undo.
    define input parameter pdaDtdeb    as date       no-undo.
    define input parameter table-handle phttAventil.
    define variable vhttBuffer as handle  no-undo.
    define buffer aventil for aventil.

    vhttBuffer = phttAventil:default-buffer-handle.
    if pdaDtdeb = ?
    then for each aventil no-lock
        where aventil.soc-cd = piSoc-cd
          and aventil.etab-cd = piEtab-cd
          and aventil.Nolot = piNolot
          and aventil.type = pcType
          and aventil.rub-cd = pcRub-cd
          and aventil.ssrub-cd = pcSsrub-cd
          and aventil.fisc-cle = pcFisc-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aventil:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each aventil no-lock
        where aventil.soc-cd = piSoc-cd
          and aventil.etab-cd = piEtab-cd
          and aventil.Nolot = piNolot
          and aventil.type = pcType
          and aventil.rub-cd = pcRub-cd
          and aventil.ssrub-cd = pcSsrub-cd
          and aventil.fisc-cle = pcFisc-cle
          and aventil.dtdeb = pdaDtdeb:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aventil:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAventil no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAventil private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define variable vhType    as handle  no-undo.
    define variable vhRub-cd    as handle  no-undo.
    define variable vhSsrub-cd    as handle  no-undo.
    define variable vhFisc-cle    as handle  no-undo.
    define variable vhDtdeb    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer aventil for aventil.

    create query vhttquery.
    vhttBuffer = ghttAventil:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAventil:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNolot, output vhType, output vhRub-cd, output vhSsrub-cd, output vhFisc-cle, output vhDtdeb, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aventil exclusive-lock
                where rowid(aventil) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aventil:handle, 'soc-cd/etab-cd/Nolot/type/rub-cd/ssrub-cd/fisc-cle/dtdeb/cpt-cd: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNolot:buffer-value(), vhType:buffer-value(), vhRub-cd:buffer-value(), vhSsrub-cd:buffer-value(), vhFisc-cle:buffer-value(), vhDtdeb:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer aventil:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAventil private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer aventil for aventil.

    create query vhttquery.
    vhttBuffer = ghttAventil:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAventil:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create aventil.
            if not outils:copyValidField(buffer aventil:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAventil private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define variable vhType    as handle  no-undo.
    define variable vhRub-cd    as handle  no-undo.
    define variable vhSsrub-cd    as handle  no-undo.
    define variable vhFisc-cle    as handle  no-undo.
    define variable vhDtdeb    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer aventil for aventil.

    create query vhttquery.
    vhttBuffer = ghttAventil:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAventil:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNolot, output vhType, output vhRub-cd, output vhSsrub-cd, output vhFisc-cle, output vhDtdeb, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aventil exclusive-lock
                where rowid(Aventil) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aventil:handle, 'soc-cd/etab-cd/Nolot/type/rub-cd/ssrub-cd/fisc-cle/dtdeb/cpt-cd: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNolot:buffer-value(), vhType:buffer-value(), vhRub-cd:buffer-value(), vhSsrub-cd:buffer-value(), vhFisc-cle:buffer-value(), vhDtdeb:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete aventil no-error.
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

