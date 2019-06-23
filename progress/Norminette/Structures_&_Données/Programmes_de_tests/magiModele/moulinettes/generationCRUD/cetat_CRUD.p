/*------------------------------------------------------------------------
File        : cetat_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cetat
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cetat.i}
{application/include/error.i}
define variable ghttcetat as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phEtat-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/etat-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'etat-cd' then phEtat-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCetat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCetat.
    run updateCetat.
    run createCetat.
end procedure.

procedure setCetat:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCetat.
    ghttCetat = phttCetat.
    run crudCetat.
    delete object phttCetat.
end procedure.

procedure readCetat:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cetat Fichier des etats
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcEtat-cd as character  no-undo.
    define input parameter table-handle phttCetat.
    define variable vhttBuffer as handle no-undo.
    define buffer cetat for cetat.

    vhttBuffer = phttCetat:default-buffer-handle.
    for first cetat no-lock
        where cetat.soc-cd = piSoc-cd
          and cetat.etab-cd = piEtab-cd
          and cetat.etat-cd = pcEtat-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cetat:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCetat no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCetat:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cetat Fichier des etats
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter table-handle phttCetat.
    define variable vhttBuffer as handle  no-undo.
    define buffer cetat for cetat.

    vhttBuffer = phttCetat:default-buffer-handle.
    if piEtab-cd = ?
    then for each cetat no-lock
        where cetat.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cetat:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cetat no-lock
        where cetat.soc-cd = piSoc-cd
          and cetat.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cetat:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCetat no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCetat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhEtat-cd    as handle  no-undo.
    define buffer cetat for cetat.

    create query vhttquery.
    vhttBuffer = ghttCetat:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCetat:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhEtat-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cetat exclusive-lock
                where rowid(cetat) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cetat:handle, 'soc-cd/etab-cd/etat-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhEtat-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cetat:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCetat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cetat for cetat.

    create query vhttquery.
    vhttBuffer = ghttCetat:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCetat:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cetat.
            if not outils:copyValidField(buffer cetat:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCetat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhEtat-cd    as handle  no-undo.
    define buffer cetat for cetat.

    create query vhttquery.
    vhttBuffer = ghttCetat:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCetat:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhEtat-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cetat exclusive-lock
                where rowid(Cetat) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cetat:handle, 'soc-cd/etab-cd/etat-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhEtat-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cetat no-error.
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

