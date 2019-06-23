/*------------------------------------------------------------------------
File        : creport_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table creport
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/creport.i}
{application/include/error.i}
define variable ghttcreport as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phRub-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/rub-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'rub-cd' then phRub-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCreport private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCreport.
    run updateCreport.
    run createCreport.
end procedure.

procedure setCreport:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCreport.
    ghttCreport = phttCreport.
    run crudCreport.
    delete object phttCreport.
end procedure.

procedure readCreport:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table creport Fichier des codes reportings
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piRub-cd  as integer    no-undo.
    define input parameter table-handle phttCreport.
    define variable vhttBuffer as handle no-undo.
    define buffer creport for creport.

    vhttBuffer = phttCreport:default-buffer-handle.
    for first creport no-lock
        where creport.soc-cd = piSoc-cd
          and creport.etab-cd = piEtab-cd
          and creport.rub-cd = piRub-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer creport:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCreport no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCreport:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table creport Fichier des codes reportings
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter table-handle phttCreport.
    define variable vhttBuffer as handle  no-undo.
    define buffer creport for creport.

    vhttBuffer = phttCreport:default-buffer-handle.
    if piEtab-cd = ?
    then for each creport no-lock
        where creport.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer creport:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each creport no-lock
        where creport.soc-cd = piSoc-cd
          and creport.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer creport:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCreport no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCreport private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhRub-cd    as handle  no-undo.
    define buffer creport for creport.

    create query vhttquery.
    vhttBuffer = ghttCreport:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCreport:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhRub-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first creport exclusive-lock
                where rowid(creport) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer creport:handle, 'soc-cd/etab-cd/rub-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhRub-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer creport:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCreport private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer creport for creport.

    create query vhttquery.
    vhttBuffer = ghttCreport:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCreport:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create creport.
            if not outils:copyValidField(buffer creport:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCreport private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhRub-cd    as handle  no-undo.
    define buffer creport for creport.

    create query vhttquery.
    vhttBuffer = ghttCreport:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCreport:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhRub-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first creport exclusive-lock
                where rowid(Creport) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer creport:handle, 'soc-cd/etab-cd/rub-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhRub-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete creport no-error.
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

