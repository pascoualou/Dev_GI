/*------------------------------------------------------------------------
File        : cpaiepar_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cpaiepar
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cpaiepar.i}
{application/include/error.i}
define variable ghttcpaiepar as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCpaiepar private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCpaiepar.
    run updateCpaiepar.
    run createCpaiepar.
end procedure.

procedure setCpaiepar:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCpaiepar.
    ghttCpaiepar = phttCpaiepar.
    run crudCpaiepar.
    delete object phttCpaiepar.
end procedure.

procedure readCpaiepar:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cpaiepar Fichier Parametre Preparation des Paiements Fournisseurs
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter table-handle phttCpaiepar.
    define variable vhttBuffer as handle no-undo.
    define buffer cpaiepar for cpaiepar.

    vhttBuffer = phttCpaiepar:default-buffer-handle.
    for first cpaiepar no-lock
        where cpaiepar.soc-cd = piSoc-cd
          and cpaiepar.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cpaiepar:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCpaiepar no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCpaiepar:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cpaiepar Fichier Parametre Preparation des Paiements Fournisseurs
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter table-handle phttCpaiepar.
    define variable vhttBuffer as handle  no-undo.
    define buffer cpaiepar for cpaiepar.

    vhttBuffer = phttCpaiepar:default-buffer-handle.
    if piSoc-cd = ?
    then for each cpaiepar no-lock
        where cpaiepar.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cpaiepar:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cpaiepar no-lock
        where cpaiepar.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cpaiepar:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCpaiepar no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCpaiepar private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define buffer cpaiepar for cpaiepar.

    create query vhttquery.
    vhttBuffer = ghttCpaiepar:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCpaiepar:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cpaiepar exclusive-lock
                where rowid(cpaiepar) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cpaiepar:handle, 'soc-cd/etab-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cpaiepar:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCpaiepar private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cpaiepar for cpaiepar.

    create query vhttquery.
    vhttBuffer = ghttCpaiepar:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCpaiepar:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cpaiepar.
            if not outils:copyValidField(buffer cpaiepar:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCpaiepar private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define buffer cpaiepar for cpaiepar.

    create query vhttquery.
    vhttBuffer = ghttCpaiepar:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCpaiepar:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cpaiepar exclusive-lock
                where rowid(Cpaiepar) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cpaiepar:handle, 'soc-cd/etab-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cpaiepar no-error.
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

