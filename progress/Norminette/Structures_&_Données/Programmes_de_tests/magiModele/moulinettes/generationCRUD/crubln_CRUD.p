/*------------------------------------------------------------------------
File        : crubln_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table crubln
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/crubln.i}
{application/include/error.i}
define variable ghttcrubln as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phModele-cd as handle, output phRub-cd as handle, output phCpt-cd as handle, output phRubln-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/modele-cd/rub-cd/cpt-cd/rubln-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'modele-cd' then phModele-cd = phBuffer:buffer-field(vi).
            when 'rub-cd' then phRub-cd = phBuffer:buffer-field(vi).
            when 'cpt-cd' then phCpt-cd = phBuffer:buffer-field(vi).
            when 'rubln-cd' then phRubln-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCrubln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCrubln.
    run updateCrubln.
    run createCrubln.
end procedure.

procedure setCrubln:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCrubln.
    ghttCrubln = phttCrubln.
    run crudCrubln.
    delete object phttCrubln.
end procedure.

procedure readCrubln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table crubln comptes ou rubriques associes a une autre rubrique
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcModele-cd as character  no-undo.
    define input parameter piRub-cd    as integer    no-undo.
    define input parameter pcCpt-cd    as character  no-undo.
    define input parameter piRubln-cd  as integer    no-undo.
    define input parameter table-handle phttCrubln.
    define variable vhttBuffer as handle no-undo.
    define buffer crubln for crubln.

    vhttBuffer = phttCrubln:default-buffer-handle.
    for first crubln no-lock
        where crubln.soc-cd = piSoc-cd
          and crubln.etab-cd = piEtab-cd
          and crubln.modele-cd = pcModele-cd
          and crubln.rub-cd = piRub-cd
          and crubln.cpt-cd = pcCpt-cd
          and crubln.rubln-cd = piRubln-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crubln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCrubln no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCrubln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table crubln comptes ou rubriques associes a une autre rubrique
    Notes  : service externe. Critère pcCpt-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcModele-cd as character  no-undo.
    define input parameter piRub-cd    as integer    no-undo.
    define input parameter pcCpt-cd    as character  no-undo.
    define input parameter table-handle phttCrubln.
    define variable vhttBuffer as handle  no-undo.
    define buffer crubln for crubln.

    vhttBuffer = phttCrubln:default-buffer-handle.
    if pcCpt-cd = ?
    then for each crubln no-lock
        where crubln.soc-cd = piSoc-cd
          and crubln.etab-cd = piEtab-cd
          and crubln.modele-cd = pcModele-cd
          and crubln.rub-cd = piRub-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crubln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each crubln no-lock
        where crubln.soc-cd = piSoc-cd
          and crubln.etab-cd = piEtab-cd
          and crubln.modele-cd = pcModele-cd
          and crubln.rub-cd = piRub-cd
          and crubln.cpt-cd = pcCpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crubln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCrubln no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCrubln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhModele-cd    as handle  no-undo.
    define variable vhRub-cd    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define variable vhRubln-cd    as handle  no-undo.
    define buffer crubln for crubln.

    create query vhttquery.
    vhttBuffer = ghttCrubln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCrubln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhModele-cd, output vhRub-cd, output vhCpt-cd, output vhRubln-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first crubln exclusive-lock
                where rowid(crubln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer crubln:handle, 'soc-cd/etab-cd/modele-cd/rub-cd/cpt-cd/rubln-cd: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhModele-cd:buffer-value(), vhRub-cd:buffer-value(), vhCpt-cd:buffer-value(), vhRubln-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer crubln:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCrubln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer crubln for crubln.

    create query vhttquery.
    vhttBuffer = ghttCrubln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCrubln:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create crubln.
            if not outils:copyValidField(buffer crubln:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCrubln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhModele-cd    as handle  no-undo.
    define variable vhRub-cd    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define variable vhRubln-cd    as handle  no-undo.
    define buffer crubln for crubln.

    create query vhttquery.
    vhttBuffer = ghttCrubln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCrubln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhModele-cd, output vhRub-cd, output vhCpt-cd, output vhRubln-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first crubln exclusive-lock
                where rowid(Crubln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer crubln:handle, 'soc-cd/etab-cd/modele-cd/rub-cd/cpt-cd/rubln-cd: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhModele-cd:buffer-value(), vhRub-cd:buffer-value(), vhCpt-cd:buffer-value(), vhRubln-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete crubln no-error.
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

