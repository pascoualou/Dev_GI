/*------------------------------------------------------------------------
File        : pgenodp_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table pgenodp
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/pgenodp.i}
{application/include/error.i}
define variable ghttpgenodp as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phCpt-cd as handle, output phAna1-cd as handle, output phAna2-cd as handle, output phAna3-cd as handle, output phAna4-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/cpt-cd/ana1-cd/ana2-cd/ana3-cd/ana4-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'cpt-cd' then phCpt-cd = phBuffer:buffer-field(vi).
            when 'ana1-cd' then phAna1-cd = phBuffer:buffer-field(vi).
            when 'ana2-cd' then phAna2-cd = phBuffer:buffer-field(vi).
            when 'ana3-cd' then phAna3-cd = phBuffer:buffer-field(vi).
            when 'ana4-cd' then phAna4-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPgenodp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePgenodp.
    run updatePgenodp.
    run createPgenodp.
end procedure.

procedure setPgenodp:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPgenodp.
    ghttPgenodp = phttPgenodp.
    run crudPgenodp.
    delete object phttPgenodp.
end procedure.

procedure readPgenodp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table pgenodp Fichier de generation des O.D  de Paie
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcCpt-cd  as character  no-undo.
    define input parameter pcAna1-cd as character  no-undo.
    define input parameter pcAna2-cd as character  no-undo.
    define input parameter pcAna3-cd as character  no-undo.
    define input parameter pcAna4-cd as character  no-undo.
    define input parameter table-handle phttPgenodp.
    define variable vhttBuffer as handle no-undo.
    define buffer pgenodp for pgenodp.

    vhttBuffer = phttPgenodp:default-buffer-handle.
    for first pgenodp no-lock
        where pgenodp.soc-cd = piSoc-cd
          and pgenodp.etab-cd = piEtab-cd
          and pgenodp.cpt-cd = pcCpt-cd
          and pgenodp.ana1-cd = pcAna1-cd
          and pgenodp.ana2-cd = pcAna2-cd
          and pgenodp.ana3-cd = pcAna3-cd
          and pgenodp.ana4-cd = pcAna4-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pgenodp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPgenodp no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPgenodp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table pgenodp Fichier de generation des O.D  de Paie
    Notes  : service externe. Critère pcAna3-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcCpt-cd  as character  no-undo.
    define input parameter pcAna1-cd as character  no-undo.
    define input parameter pcAna2-cd as character  no-undo.
    define input parameter pcAna3-cd as character  no-undo.
    define input parameter table-handle phttPgenodp.
    define variable vhttBuffer as handle  no-undo.
    define buffer pgenodp for pgenodp.

    vhttBuffer = phttPgenodp:default-buffer-handle.
    if pcAna3-cd = ?
    then for each pgenodp no-lock
        where pgenodp.soc-cd = piSoc-cd
          and pgenodp.etab-cd = piEtab-cd
          and pgenodp.cpt-cd = pcCpt-cd
          and pgenodp.ana1-cd = pcAna1-cd
          and pgenodp.ana2-cd = pcAna2-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pgenodp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each pgenodp no-lock
        where pgenodp.soc-cd = piSoc-cd
          and pgenodp.etab-cd = piEtab-cd
          and pgenodp.cpt-cd = pcCpt-cd
          and pgenodp.ana1-cd = pcAna1-cd
          and pgenodp.ana2-cd = pcAna2-cd
          and pgenodp.ana3-cd = pcAna3-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pgenodp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPgenodp no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePgenodp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define variable vhAna1-cd    as handle  no-undo.
    define variable vhAna2-cd    as handle  no-undo.
    define variable vhAna3-cd    as handle  no-undo.
    define variable vhAna4-cd    as handle  no-undo.
    define buffer pgenodp for pgenodp.

    create query vhttquery.
    vhttBuffer = ghttPgenodp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPgenodp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhCpt-cd, output vhAna1-cd, output vhAna2-cd, output vhAna3-cd, output vhAna4-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pgenodp exclusive-lock
                where rowid(pgenodp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pgenodp:handle, 'soc-cd/etab-cd/cpt-cd/ana1-cd/ana2-cd/ana3-cd/ana4-cd: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCpt-cd:buffer-value(), vhAna1-cd:buffer-value(), vhAna2-cd:buffer-value(), vhAna3-cd:buffer-value(), vhAna4-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer pgenodp:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPgenodp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer pgenodp for pgenodp.

    create query vhttquery.
    vhttBuffer = ghttPgenodp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPgenodp:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create pgenodp.
            if not outils:copyValidField(buffer pgenodp:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePgenodp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define variable vhAna1-cd    as handle  no-undo.
    define variable vhAna2-cd    as handle  no-undo.
    define variable vhAna3-cd    as handle  no-undo.
    define variable vhAna4-cd    as handle  no-undo.
    define buffer pgenodp for pgenodp.

    create query vhttquery.
    vhttBuffer = ghttPgenodp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPgenodp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhCpt-cd, output vhAna1-cd, output vhAna2-cd, output vhAna3-cd, output vhAna4-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pgenodp exclusive-lock
                where rowid(Pgenodp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pgenodp:handle, 'soc-cd/etab-cd/cpt-cd/ana1-cd/ana2-cd/ana3-cd/ana4-cd: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCpt-cd:buffer-value(), vhAna1-cd:buffer-value(), vhAna2-cd:buffer-value(), vhAna3-cd:buffer-value(), vhAna4-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete pgenodp no-error.
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

