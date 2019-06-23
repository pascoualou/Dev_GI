/*------------------------------------------------------------------------
File        : zsdcor_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table zsdcor
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/zsdcor.i}
{application/include/error.i}
define variable ghttzsdcor as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phSscoll-cle as handle, output phAna1-cd as handle, output phAna2-cd as handle, output phAna3-cd as handle, output phAna4-cd as handle, output phCpt-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/sscoll-cle/ana1-cd/ana2-cd/ana3-cd/ana4-cd/cpt-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'sscoll-cle' then phSscoll-cle = phBuffer:buffer-field(vi).
            when 'ana1-cd' then phAna1-cd = phBuffer:buffer-field(vi).
            when 'ana2-cd' then phAna2-cd = phBuffer:buffer-field(vi).
            when 'ana3-cd' then phAna3-cd = phBuffer:buffer-field(vi).
            when 'ana4-cd' then phAna4-cd = phBuffer:buffer-field(vi).
            when 'cpt-cd' then phCpt-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudZsdcor private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteZsdcor.
    run updateZsdcor.
    run createZsdcor.
end procedure.

procedure setZsdcor:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttZsdcor.
    ghttZsdcor = phttZsdcor.
    run crudZsdcor.
    delete object phttZsdcor.
end procedure.

procedure readZsdcor:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table zsdcor Solde des dossiers: correspondance analytique - comptes
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcSscoll-cle as character  no-undo.
    define input parameter pcAna1-cd    as character  no-undo.
    define input parameter pcAna2-cd    as character  no-undo.
    define input parameter pcAna3-cd    as character  no-undo.
    define input parameter pcAna4-cd    as character  no-undo.
    define input parameter pcCpt-cd     as character  no-undo.
    define input parameter table-handle phttZsdcor.
    define variable vhttBuffer as handle no-undo.
    define buffer zsdcor for zsdcor.

    vhttBuffer = phttZsdcor:default-buffer-handle.
    for first zsdcor no-lock
        where zsdcor.soc-cd = piSoc-cd
          and zsdcor.etab-cd = piEtab-cd
          and zsdcor.sscoll-cle = pcSscoll-cle
          and zsdcor.ana1-cd = pcAna1-cd
          and zsdcor.ana2-cd = pcAna2-cd
          and zsdcor.ana3-cd = pcAna3-cd
          and zsdcor.ana4-cd = pcAna4-cd
          and zsdcor.cpt-cd = pcCpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer zsdcor:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttZsdcor no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getZsdcor:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table zsdcor Solde des dossiers: correspondance analytique - comptes
    Notes  : service externe. Critère pcAna4-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcSscoll-cle as character  no-undo.
    define input parameter pcAna1-cd    as character  no-undo.
    define input parameter pcAna2-cd    as character  no-undo.
    define input parameter pcAna3-cd    as character  no-undo.
    define input parameter pcAna4-cd    as character  no-undo.
    define input parameter table-handle phttZsdcor.
    define variable vhttBuffer as handle  no-undo.
    define buffer zsdcor for zsdcor.

    vhttBuffer = phttZsdcor:default-buffer-handle.
    if pcAna4-cd = ?
    then for each zsdcor no-lock
        where zsdcor.soc-cd = piSoc-cd
          and zsdcor.etab-cd = piEtab-cd
          and zsdcor.sscoll-cle = pcSscoll-cle
          and zsdcor.ana1-cd = pcAna1-cd
          and zsdcor.ana2-cd = pcAna2-cd
          and zsdcor.ana3-cd = pcAna3-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer zsdcor:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each zsdcor no-lock
        where zsdcor.soc-cd = piSoc-cd
          and zsdcor.etab-cd = piEtab-cd
          and zsdcor.sscoll-cle = pcSscoll-cle
          and zsdcor.ana1-cd = pcAna1-cd
          and zsdcor.ana2-cd = pcAna2-cd
          and zsdcor.ana3-cd = pcAna3-cd
          and zsdcor.ana4-cd = pcAna4-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer zsdcor:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttZsdcor no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateZsdcor private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhSscoll-cle    as handle  no-undo.
    define variable vhAna1-cd    as handle  no-undo.
    define variable vhAna2-cd    as handle  no-undo.
    define variable vhAna3-cd    as handle  no-undo.
    define variable vhAna4-cd    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer zsdcor for zsdcor.

    create query vhttquery.
    vhttBuffer = ghttZsdcor:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttZsdcor:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhSscoll-cle, output vhAna1-cd, output vhAna2-cd, output vhAna3-cd, output vhAna4-cd, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first zsdcor exclusive-lock
                where rowid(zsdcor) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer zsdcor:handle, 'soc-cd/etab-cd/sscoll-cle/ana1-cd/ana2-cd/ana3-cd/ana4-cd/cpt-cd: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhSscoll-cle:buffer-value(), vhAna1-cd:buffer-value(), vhAna2-cd:buffer-value(), vhAna3-cd:buffer-value(), vhAna4-cd:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer zsdcor:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createZsdcor private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer zsdcor for zsdcor.

    create query vhttquery.
    vhttBuffer = ghttZsdcor:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttZsdcor:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create zsdcor.
            if not outils:copyValidField(buffer zsdcor:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteZsdcor private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhSscoll-cle    as handle  no-undo.
    define variable vhAna1-cd    as handle  no-undo.
    define variable vhAna2-cd    as handle  no-undo.
    define variable vhAna3-cd    as handle  no-undo.
    define variable vhAna4-cd    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer zsdcor for zsdcor.

    create query vhttquery.
    vhttBuffer = ghttZsdcor:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttZsdcor:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhSscoll-cle, output vhAna1-cd, output vhAna2-cd, output vhAna3-cd, output vhAna4-cd, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first zsdcor exclusive-lock
                where rowid(Zsdcor) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer zsdcor:handle, 'soc-cd/etab-cd/sscoll-cle/ana1-cd/ana2-cd/ana3-cd/ana4-cd/cpt-cd: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhSscoll-cle:buffer-value(), vhAna1-cd:buffer-value(), vhAna2-cd:buffer-value(), vhAna3-cd:buffer-value(), vhAna4-cd:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete zsdcor no-error.
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

