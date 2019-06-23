/*------------------------------------------------------------------------
File        : pcorln_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table pcorln
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/pcorln.i}
{application/include/error.i}
define variable ghttpcorln as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phAnacor-cle as handle, output phAna1-cd as handle, output phAna2-cd as handle, output phAna3-cd as handle, output phAna4-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/anacor-cle/ana1-cd/ana2-cd/ana3-cd/ana4-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'anacor-cle' then phAnacor-cle = phBuffer:buffer-field(vi).
            when 'ana1-cd' then phAna1-cd = phBuffer:buffer-field(vi).
            when 'ana2-cd' then phAna2-cd = phBuffer:buffer-field(vi).
            when 'ana3-cd' then phAna3-cd = phBuffer:buffer-field(vi).
            when 'ana4-cd' then phAna4-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPcorln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePcorln.
    run updatePcorln.
    run createPcorln.
end procedure.

procedure setPcorln:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPcorln.
    ghttPcorln = phttPcorln.
    run crudPcorln.
    delete object phttPcorln.
end procedure.

procedure readPcorln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table pcorln Fichier table de correspondance
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcAnacor-cle as character  no-undo.
    define input parameter pcAna1-cd    as character  no-undo.
    define input parameter pcAna2-cd    as character  no-undo.
    define input parameter pcAna3-cd    as character  no-undo.
    define input parameter pcAna4-cd    as character  no-undo.
    define input parameter table-handle phttPcorln.
    define variable vhttBuffer as handle no-undo.
    define buffer pcorln for pcorln.

    vhttBuffer = phttPcorln:default-buffer-handle.
    for first pcorln no-lock
        where pcorln.soc-cd = piSoc-cd
          and pcorln.etab-cd = piEtab-cd
          and pcorln.anacor-cle = pcAnacor-cle
          and pcorln.ana1-cd = pcAna1-cd
          and pcorln.ana2-cd = pcAna2-cd
          and pcorln.ana3-cd = pcAna3-cd
          and pcorln.ana4-cd = pcAna4-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pcorln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPcorln no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPcorln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table pcorln Fichier table de correspondance
    Notes  : service externe. Critère pcAna3-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcAnacor-cle as character  no-undo.
    define input parameter pcAna1-cd    as character  no-undo.
    define input parameter pcAna2-cd    as character  no-undo.
    define input parameter pcAna3-cd    as character  no-undo.
    define input parameter table-handle phttPcorln.
    define variable vhttBuffer as handle  no-undo.
    define buffer pcorln for pcorln.

    vhttBuffer = phttPcorln:default-buffer-handle.
    if pcAna3-cd = ?
    then for each pcorln no-lock
        where pcorln.soc-cd = piSoc-cd
          and pcorln.etab-cd = piEtab-cd
          and pcorln.anacor-cle = pcAnacor-cle
          and pcorln.ana1-cd = pcAna1-cd
          and pcorln.ana2-cd = pcAna2-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pcorln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each pcorln no-lock
        where pcorln.soc-cd = piSoc-cd
          and pcorln.etab-cd = piEtab-cd
          and pcorln.anacor-cle = pcAnacor-cle
          and pcorln.ana1-cd = pcAna1-cd
          and pcorln.ana2-cd = pcAna2-cd
          and pcorln.ana3-cd = pcAna3-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pcorln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPcorln no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePcorln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhAnacor-cle    as handle  no-undo.
    define variable vhAna1-cd    as handle  no-undo.
    define variable vhAna2-cd    as handle  no-undo.
    define variable vhAna3-cd    as handle  no-undo.
    define variable vhAna4-cd    as handle  no-undo.
    define buffer pcorln for pcorln.

    create query vhttquery.
    vhttBuffer = ghttPcorln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPcorln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhAnacor-cle, output vhAna1-cd, output vhAna2-cd, output vhAna3-cd, output vhAna4-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pcorln exclusive-lock
                where rowid(pcorln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pcorln:handle, 'soc-cd/etab-cd/anacor-cle/ana1-cd/ana2-cd/ana3-cd/ana4-cd: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhAnacor-cle:buffer-value(), vhAna1-cd:buffer-value(), vhAna2-cd:buffer-value(), vhAna3-cd:buffer-value(), vhAna4-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer pcorln:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPcorln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer pcorln for pcorln.

    create query vhttquery.
    vhttBuffer = ghttPcorln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPcorln:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create pcorln.
            if not outils:copyValidField(buffer pcorln:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePcorln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhAnacor-cle    as handle  no-undo.
    define variable vhAna1-cd    as handle  no-undo.
    define variable vhAna2-cd    as handle  no-undo.
    define variable vhAna3-cd    as handle  no-undo.
    define variable vhAna4-cd    as handle  no-undo.
    define buffer pcorln for pcorln.

    create query vhttquery.
    vhttBuffer = ghttPcorln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPcorln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhAnacor-cle, output vhAna1-cd, output vhAna2-cd, output vhAna3-cd, output vhAna4-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pcorln exclusive-lock
                where rowid(Pcorln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pcorln:handle, 'soc-cd/etab-cd/anacor-cle/ana1-cd/ana2-cd/ana3-cd/ana4-cd: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhAnacor-cle:buffer-value(), vhAna1-cd:buffer-value(), vhAna2-cd:buffer-value(), vhAna3-cd:buffer-value(), vhAna4-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete pcorln no-error.
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

