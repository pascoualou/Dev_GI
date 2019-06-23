/*------------------------------------------------------------------------
File        : pecrlnoc_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table pecrlnoc
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/pecrlnoc.i}
{application/include/error.i}
define variable ghttpecrlnoc as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phPrd-cd as handle, output phCpt-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/prd-cd/cpt-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'prd-cd' then phPrd-cd = phBuffer:buffer-field(vi).
            when 'cpt-cd' then phCpt-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPecrlnoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePecrlnoc.
    run updatePecrlnoc.
    run createPecrlnoc.
end procedure.

procedure setPecrlnoc:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPecrlnoc.
    ghttPecrlnoc = phttPecrlnoc.
    run crudPecrlnoc.
    delete object phttPecrlnoc.
end procedure.

procedure readPecrlnoc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table pecrlnoc Fichier Ecriture O.D. de CLOTURE
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piPrd-cd  as integer    no-undo.
    define input parameter pcCpt-cd  as character  no-undo.
    define input parameter table-handle phttPecrlnoc.
    define variable vhttBuffer as handle no-undo.
    define buffer pecrlnoc for pecrlnoc.

    vhttBuffer = phttPecrlnoc:default-buffer-handle.
    for first pecrlnoc no-lock
        where pecrlnoc.soc-cd = piSoc-cd
          and pecrlnoc.etab-cd = piEtab-cd
          and pecrlnoc.prd-cd = piPrd-cd
          and pecrlnoc.cpt-cd = pcCpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pecrlnoc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPecrlnoc no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPecrlnoc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table pecrlnoc Fichier Ecriture O.D. de CLOTURE
    Notes  : service externe. Critère piPrd-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piPrd-cd  as integer    no-undo.
    define input parameter table-handle phttPecrlnoc.
    define variable vhttBuffer as handle  no-undo.
    define buffer pecrlnoc for pecrlnoc.

    vhttBuffer = phttPecrlnoc:default-buffer-handle.
    if piPrd-cd = ?
    then for each pecrlnoc no-lock
        where pecrlnoc.soc-cd = piSoc-cd
          and pecrlnoc.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pecrlnoc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each pecrlnoc no-lock
        where pecrlnoc.soc-cd = piSoc-cd
          and pecrlnoc.etab-cd = piEtab-cd
          and pecrlnoc.prd-cd = piPrd-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pecrlnoc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPecrlnoc no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePecrlnoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhPrd-cd    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer pecrlnoc for pecrlnoc.

    create query vhttquery.
    vhttBuffer = ghttPecrlnoc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPecrlnoc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhPrd-cd, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pecrlnoc exclusive-lock
                where rowid(pecrlnoc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pecrlnoc:handle, 'soc-cd/etab-cd/prd-cd/cpt-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhPrd-cd:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer pecrlnoc:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPecrlnoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer pecrlnoc for pecrlnoc.

    create query vhttquery.
    vhttBuffer = ghttPecrlnoc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPecrlnoc:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create pecrlnoc.
            if not outils:copyValidField(buffer pecrlnoc:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePecrlnoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhPrd-cd    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer pecrlnoc for pecrlnoc.

    create query vhttquery.
    vhttBuffer = ghttPecrlnoc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPecrlnoc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhPrd-cd, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pecrlnoc exclusive-lock
                where rowid(Pecrlnoc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pecrlnoc:handle, 'soc-cd/etab-cd/prd-cd/cpt-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhPrd-cd:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete pecrlnoc no-error.
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

