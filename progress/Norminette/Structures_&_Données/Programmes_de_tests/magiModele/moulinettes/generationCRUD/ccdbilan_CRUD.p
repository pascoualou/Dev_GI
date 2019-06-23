/*------------------------------------------------------------------------
File        : ccdbilan_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ccdbilan
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ccdbilan.i}
{application/include/error.i}
define variable ghttccdbilan as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phEtat-cd as handle, output phRub-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/etat-cd/rub-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'etat-cd' then phEtat-cd = phBuffer:buffer-field(vi).
            when 'rub-cd' then phRub-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCcdbilan private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCcdbilan.
    run updateCcdbilan.
    run createCcdbilan.
end procedure.

procedure setCcdbilan:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCcdbilan.
    ghttCcdbilan = phttCcdbilan.
    run crudCcdbilan.
    delete object phttCcdbilan.
end procedure.

procedure readCcdbilan:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ccdbilan Fichiers Codes Bilans.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcEtat-cd as character  no-undo.
    define input parameter piRub-cd  as integer    no-undo.
    define input parameter table-handle phttCcdbilan.
    define variable vhttBuffer as handle no-undo.
    define buffer ccdbilan for ccdbilan.

    vhttBuffer = phttCcdbilan:default-buffer-handle.
    for first ccdbilan no-lock
        where ccdbilan.soc-cd = piSoc-cd
          and ccdbilan.etab-cd = piEtab-cd
          and ccdbilan.etat-cd = pcEtat-cd
          and ccdbilan.rub-cd = piRub-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ccdbilan:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCcdbilan no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCcdbilan:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ccdbilan Fichiers Codes Bilans.
    Notes  : service externe. Critère pcEtat-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcEtat-cd as character  no-undo.
    define input parameter table-handle phttCcdbilan.
    define variable vhttBuffer as handle  no-undo.
    define buffer ccdbilan for ccdbilan.

    vhttBuffer = phttCcdbilan:default-buffer-handle.
    if pcEtat-cd = ?
    then for each ccdbilan no-lock
        where ccdbilan.soc-cd = piSoc-cd
          and ccdbilan.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ccdbilan:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ccdbilan no-lock
        where ccdbilan.soc-cd = piSoc-cd
          and ccdbilan.etab-cd = piEtab-cd
          and ccdbilan.etat-cd = pcEtat-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ccdbilan:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCcdbilan no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCcdbilan private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhEtat-cd    as handle  no-undo.
    define variable vhRub-cd    as handle  no-undo.
    define buffer ccdbilan for ccdbilan.

    create query vhttquery.
    vhttBuffer = ghttCcdbilan:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCcdbilan:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhEtat-cd, output vhRub-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ccdbilan exclusive-lock
                where rowid(ccdbilan) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ccdbilan:handle, 'soc-cd/etab-cd/etat-cd/rub-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhEtat-cd:buffer-value(), vhRub-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ccdbilan:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCcdbilan private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ccdbilan for ccdbilan.

    create query vhttquery.
    vhttBuffer = ghttCcdbilan:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCcdbilan:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ccdbilan.
            if not outils:copyValidField(buffer ccdbilan:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCcdbilan private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhEtat-cd    as handle  no-undo.
    define variable vhRub-cd    as handle  no-undo.
    define buffer ccdbilan for ccdbilan.

    create query vhttquery.
    vhttBuffer = ghttCcdbilan:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCcdbilan:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhEtat-cd, output vhRub-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ccdbilan exclusive-lock
                where rowid(Ccdbilan) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ccdbilan:handle, 'soc-cd/etab-cd/etat-cd/rub-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhEtat-cd:buffer-value(), vhRub-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ccdbilan no-error.
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

