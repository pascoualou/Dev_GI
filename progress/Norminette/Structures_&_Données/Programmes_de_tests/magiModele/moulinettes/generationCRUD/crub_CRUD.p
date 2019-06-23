/*------------------------------------------------------------------------
File        : crub_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table crub
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/crub.i}
{application/include/error.i}
define variable ghttcrub as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phModele-cd as handle, output phRub-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/modele-cd/rub-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'modele-cd' then phModele-cd = phBuffer:buffer-field(vi).
            when 'rub-cd' then phRub-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCrub private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCrub.
    run updateCrub.
    run createCrub.
end procedure.

procedure setCrub:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCrub.
    ghttCrub = phttCrub.
    run crudCrub.
    delete object phttCrub.
end procedure.

procedure readCrub:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table crub Fichier des rubriques budgetaires
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcModele-cd as character  no-undo.
    define input parameter piRub-cd    as integer    no-undo.
    define input parameter table-handle phttCrub.
    define variable vhttBuffer as handle no-undo.
    define buffer crub for crub.

    vhttBuffer = phttCrub:default-buffer-handle.
    for first crub no-lock
        where crub.soc-cd = piSoc-cd
          and crub.etab-cd = piEtab-cd
          and crub.modele-cd = pcModele-cd
          and crub.rub-cd = piRub-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crub:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCrub no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCrub:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table crub Fichier des rubriques budgetaires
    Notes  : service externe. Critère pcModele-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcModele-cd as character  no-undo.
    define input parameter table-handle phttCrub.
    define variable vhttBuffer as handle  no-undo.
    define buffer crub for crub.

    vhttBuffer = phttCrub:default-buffer-handle.
    if pcModele-cd = ?
    then for each crub no-lock
        where crub.soc-cd = piSoc-cd
          and crub.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crub:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each crub no-lock
        where crub.soc-cd = piSoc-cd
          and crub.etab-cd = piEtab-cd
          and crub.modele-cd = pcModele-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crub:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCrub no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCrub private:
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
    define buffer crub for crub.

    create query vhttquery.
    vhttBuffer = ghttCrub:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCrub:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhModele-cd, output vhRub-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first crub exclusive-lock
                where rowid(crub) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer crub:handle, 'soc-cd/etab-cd/modele-cd/rub-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhModele-cd:buffer-value(), vhRub-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer crub:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCrub private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer crub for crub.

    create query vhttquery.
    vhttBuffer = ghttCrub:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCrub:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create crub.
            if not outils:copyValidField(buffer crub:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCrub private:
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
    define buffer crub for crub.

    create query vhttquery.
    vhttBuffer = ghttCrub:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCrub:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhModele-cd, output vhRub-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first crub exclusive-lock
                where rowid(Crub) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer crub:handle, 'soc-cd/etab-cd/modele-cd/rub-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhModele-cd:buffer-value(), vhRub-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete crub no-error.
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

