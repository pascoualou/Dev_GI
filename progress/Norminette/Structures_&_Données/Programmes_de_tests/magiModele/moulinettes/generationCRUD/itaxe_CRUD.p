/*------------------------------------------------------------------------
File        : itaxe_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table itaxe
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/itaxe.i}
{application/include/error.i}
define variable ghttitaxe as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phTaxe-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/taxe-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'taxe-cd' then phTaxe-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudItaxe private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteItaxe.
    run updateItaxe.
    run createItaxe.
end procedure.

procedure setItaxe:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttItaxe.
    ghttItaxe = phttItaxe.
    run crudItaxe.
    delete object phttItaxe.
end procedure.

procedure readItaxe:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table itaxe Liste des differents taux de taxes.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piTaxe-cd as integer    no-undo.
    define input parameter table-handle phttItaxe.
    define variable vhttBuffer as handle no-undo.
    define buffer itaxe for itaxe.

    vhttBuffer = phttItaxe:default-buffer-handle.
    for first itaxe no-lock
        where itaxe.soc-cd = piSoc-cd
          and itaxe.taxe-cd = piTaxe-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itaxe:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttItaxe no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getItaxe:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table itaxe Liste des differents taux de taxes.
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter table-handle phttItaxe.
    define variable vhttBuffer as handle  no-undo.
    define buffer itaxe for itaxe.

    vhttBuffer = phttItaxe:default-buffer-handle.
    if piSoc-cd = ?
    then for each itaxe no-lock
        where itaxe.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itaxe:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each itaxe no-lock
        where itaxe.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itaxe:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttItaxe no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateItaxe private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhTaxe-cd    as handle  no-undo.
    define buffer itaxe for itaxe.

    create query vhttquery.
    vhttBuffer = ghttItaxe:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttItaxe:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhTaxe-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first itaxe exclusive-lock
                where rowid(itaxe) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer itaxe:handle, 'soc-cd/taxe-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhTaxe-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer itaxe:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createItaxe private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer itaxe for itaxe.

    create query vhttquery.
    vhttBuffer = ghttItaxe:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttItaxe:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create itaxe.
            if not outils:copyValidField(buffer itaxe:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteItaxe private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhTaxe-cd    as handle  no-undo.
    define buffer itaxe for itaxe.

    create query vhttquery.
    vhttBuffer = ghttItaxe:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttItaxe:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhTaxe-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first itaxe exclusive-lock
                where rowid(Itaxe) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer itaxe:handle, 'soc-cd/taxe-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhTaxe-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete itaxe no-error.
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

