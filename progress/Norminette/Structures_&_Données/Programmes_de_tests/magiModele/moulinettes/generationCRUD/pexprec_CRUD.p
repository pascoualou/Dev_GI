/*------------------------------------------------------------------------
File        : pexprec_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table pexprec
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/pexprec.i}
{application/include/error.i}
define variable ghttpexprec as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phEtat-cd as handle, output phPrd-cd as handle, output phCpt-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/etat-cd/prd-cd/cpt-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'etat-cd' then phEtat-cd = phBuffer:buffer-field(vi).
            when 'prd-cd' then phPrd-cd = phBuffer:buffer-field(vi).
            when 'cpt-cd' then phCpt-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPexprec private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePexprec.
    run updatePexprec.
    run createPexprec.
end procedure.

procedure setPexprec:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPexprec.
    ghttPexprec = phttPexprec.
    run crudPexprec.
    delete object phttPexprec.
end procedure.

procedure readPexprec:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table pexprec Fichier Exercice Precedent
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcEtat-cd as character  no-undo.
    define input parameter piPrd-cd  as integer    no-undo.
    define input parameter pcCpt-cd  as character  no-undo.
    define input parameter table-handle phttPexprec.
    define variable vhttBuffer as handle no-undo.
    define buffer pexprec for pexprec.

    vhttBuffer = phttPexprec:default-buffer-handle.
    for first pexprec no-lock
        where pexprec.soc-cd = piSoc-cd
          and pexprec.etab-cd = piEtab-cd
          and pexprec.etat-cd = pcEtat-cd
          and pexprec.prd-cd = piPrd-cd
          and pexprec.cpt-cd = pcCpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pexprec:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPexprec no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPexprec:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table pexprec Fichier Exercice Precedent
    Notes  : service externe. Critère piPrd-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcEtat-cd as character  no-undo.
    define input parameter piPrd-cd  as integer    no-undo.
    define input parameter table-handle phttPexprec.
    define variable vhttBuffer as handle  no-undo.
    define buffer pexprec for pexprec.

    vhttBuffer = phttPexprec:default-buffer-handle.
    if piPrd-cd = ?
    then for each pexprec no-lock
        where pexprec.soc-cd = piSoc-cd
          and pexprec.etab-cd = piEtab-cd
          and pexprec.etat-cd = pcEtat-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pexprec:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each pexprec no-lock
        where pexprec.soc-cd = piSoc-cd
          and pexprec.etab-cd = piEtab-cd
          and pexprec.etat-cd = pcEtat-cd
          and pexprec.prd-cd = piPrd-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pexprec:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPexprec no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePexprec private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhEtat-cd    as handle  no-undo.
    define variable vhPrd-cd    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer pexprec for pexprec.

    create query vhttquery.
    vhttBuffer = ghttPexprec:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPexprec:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhEtat-cd, output vhPrd-cd, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pexprec exclusive-lock
                where rowid(pexprec) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pexprec:handle, 'soc-cd/etab-cd/etat-cd/prd-cd/cpt-cd: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhEtat-cd:buffer-value(), vhPrd-cd:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer pexprec:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPexprec private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer pexprec for pexprec.

    create query vhttquery.
    vhttBuffer = ghttPexprec:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPexprec:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create pexprec.
            if not outils:copyValidField(buffer pexprec:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePexprec private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhEtat-cd    as handle  no-undo.
    define variable vhPrd-cd    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer pexprec for pexprec.

    create query vhttquery.
    vhttBuffer = ghttPexprec:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPexprec:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhEtat-cd, output vhPrd-cd, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pexprec exclusive-lock
                where rowid(Pexprec) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pexprec:handle, 'soc-cd/etab-cd/etat-cd/prd-cd/cpt-cd: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhEtat-cd:buffer-value(), vhPrd-cd:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete pexprec no-error.
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

