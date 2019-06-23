/*------------------------------------------------------------------------
File        : csdtmp_CRUD.p
Purpose     : Librairie contenant les procedures li�es � la mise � jour de la table csdtmp
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table � condition
              que les champs de l'index unique soient tous pr�sents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit �tre positionn�e juste apr�s using
//{include/csdtmp.i}
{application/include/error.i}
define variable ghttcsdtmp as handle no-undo.      // le handle de la temp table � mettre � jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phAna1-cd as handle, output phAna2-cd as handle, output phAna3-cd as handle, output phAna4-cd as handle, output phSscoll-cle as handle, output phCpt-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: r�cup�re les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/ana1-cd/ana2-cd/ana3-cd/ana4-cd/sscoll-cle/cpt-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'ana1-cd' then phAna1-cd = phBuffer:buffer-field(vi).
            when 'ana2-cd' then phAna2-cd = phBuffer:buffer-field(vi).
            when 'ana3-cd' then phAna3-cd = phBuffer:buffer-field(vi).
            when 'ana4-cd' then phAna4-cd = phBuffer:buffer-field(vi).
            when 'sscoll-cle' then phSscoll-cle = phBuffer:buffer-field(vi).
            when 'cpt-cd' then phCpt-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCsdtmp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCsdtmp.
    run updateCsdtmp.
    run createCsdtmp.
end procedure.

procedure setCsdtmp:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCsdtmp.
    ghttCsdtmp = phttCsdtmp.
    run crudCsdtmp.
    delete object phttCsdtmp.
end procedure.

procedure readCsdtmp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table csdtmp Solde des dossiers: fichier temporaire
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcAna1-cd    as character  no-undo.
    define input parameter pcAna2-cd    as character  no-undo.
    define input parameter pcAna3-cd    as character  no-undo.
    define input parameter pcAna4-cd    as character  no-undo.
    define input parameter pcSscoll-cle as character  no-undo.
    define input parameter pcCpt-cd     as character  no-undo.
    define input parameter table-handle phttCsdtmp.
    define variable vhttBuffer as handle no-undo.
    define buffer csdtmp for csdtmp.

    vhttBuffer = phttCsdtmp:default-buffer-handle.
    for first csdtmp no-lock
        where csdtmp.soc-cd = piSoc-cd
          and csdtmp.etab-cd = piEtab-cd
          and csdtmp.ana1-cd = pcAna1-cd
          and csdtmp.ana2-cd = pcAna2-cd
          and csdtmp.ana3-cd = pcAna3-cd
          and csdtmp.ana4-cd = pcAna4-cd
          and csdtmp.sscoll-cle = pcSscoll-cle
          and csdtmp.cpt-cd = pcCpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer csdtmp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCsdtmp no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCsdtmp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table csdtmp Solde des dossiers: fichier temporaire
    Notes  : service externe. Crit�re pcSscoll-cle = ? si pas � prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcAna1-cd    as character  no-undo.
    define input parameter pcAna2-cd    as character  no-undo.
    define input parameter pcAna3-cd    as character  no-undo.
    define input parameter pcAna4-cd    as character  no-undo.
    define input parameter pcSscoll-cle as character  no-undo.
    define input parameter table-handle phttCsdtmp.
    define variable vhttBuffer as handle  no-undo.
    define buffer csdtmp for csdtmp.

    vhttBuffer = phttCsdtmp:default-buffer-handle.
    if pcSscoll-cle = ?
    then for each csdtmp no-lock
        where csdtmp.soc-cd = piSoc-cd
          and csdtmp.etab-cd = piEtab-cd
          and csdtmp.ana1-cd = pcAna1-cd
          and csdtmp.ana2-cd = pcAna2-cd
          and csdtmp.ana3-cd = pcAna3-cd
          and csdtmp.ana4-cd = pcAna4-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer csdtmp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each csdtmp no-lock
        where csdtmp.soc-cd = piSoc-cd
          and csdtmp.etab-cd = piEtab-cd
          and csdtmp.ana1-cd = pcAna1-cd
          and csdtmp.ana2-cd = pcAna2-cd
          and csdtmp.ana3-cd = pcAna3-cd
          and csdtmp.ana4-cd = pcAna4-cd
          and csdtmp.sscoll-cle = pcSscoll-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer csdtmp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCsdtmp no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCsdtmp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhAna1-cd    as handle  no-undo.
    define variable vhAna2-cd    as handle  no-undo.
    define variable vhAna3-cd    as handle  no-undo.
    define variable vhAna4-cd    as handle  no-undo.
    define variable vhSscoll-cle    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer csdtmp for csdtmp.

    create query vhttquery.
    vhttBuffer = ghttCsdtmp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCsdtmp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhAna1-cd, output vhAna2-cd, output vhAna3-cd, output vhAna4-cd, output vhSscoll-cle, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first csdtmp exclusive-lock
                where rowid(csdtmp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer csdtmp:handle, 'soc-cd/etab-cd/ana1-cd/ana2-cd/ana3-cd/ana4-cd/sscoll-cle/cpt-cd: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhAna1-cd:buffer-value(), vhAna2-cd:buffer-value(), vhAna3-cd:buffer-value(), vhAna4-cd:buffer-value(), vhSscoll-cle:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer csdtmp:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCsdtmp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer csdtmp for csdtmp.

    create query vhttquery.
    vhttBuffer = ghttCsdtmp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCsdtmp:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create csdtmp.
            if not outils:copyValidField(buffer csdtmp:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCsdtmp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhAna1-cd    as handle  no-undo.
    define variable vhAna2-cd    as handle  no-undo.
    define variable vhAna3-cd    as handle  no-undo.
    define variable vhAna4-cd    as handle  no-undo.
    define variable vhSscoll-cle    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer csdtmp for csdtmp.

    create query vhttquery.
    vhttBuffer = ghttCsdtmp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCsdtmp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhAna1-cd, output vhAna2-cd, output vhAna3-cd, output vhAna4-cd, output vhSscoll-cle, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first csdtmp exclusive-lock
                where rowid(Csdtmp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer csdtmp:handle, 'soc-cd/etab-cd/ana1-cd/ana2-cd/ana3-cd/ana4-cd/sscoll-cle/cpt-cd: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhAna1-cd:buffer-value(), vhAna2-cd:buffer-value(), vhAna3-cd:buffer-value(), vhAna4-cd:buffer-value(), vhSscoll-cle:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete csdtmp no-error.
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

