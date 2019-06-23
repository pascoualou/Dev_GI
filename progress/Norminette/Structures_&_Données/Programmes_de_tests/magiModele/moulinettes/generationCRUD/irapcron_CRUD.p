/*------------------------------------------------------------------------
File        : irapcron_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table irapcron
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/irapcron.i}
{application/include/error.i}
define variable ghttirapcron as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phJour-cron as handle, output phType-cron as handle, output phCode-cron as handle, output phNolan as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/jour-cron/type-cron/code-cron/nolan, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'jour-cron' then phJour-cron = phBuffer:buffer-field(vi).
            when 'type-cron' then phType-cron = phBuffer:buffer-field(vi).
            when 'code-cron' then phCode-cron = phBuffer:buffer-field(vi).
            when 'nolan' then phNolan = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIrapcron private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIrapcron.
    run updateIrapcron.
    run createIrapcron.
end procedure.

procedure setIrapcron:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIrapcron.
    ghttIrapcron = phttIrapcron.
    run crudIrapcron.
    delete object phttIrapcron.
end procedure.

procedure readIrapcron:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table irapcron Contient rapports sur icron
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pdaJour-cron as date       no-undo.
    define input parameter piType-cron as integer    no-undo.
    define input parameter piCode-cron as integer    no-undo.
    define input parameter piNolan     as integer    no-undo.
    define input parameter table-handle phttIrapcron.
    define variable vhttBuffer as handle no-undo.
    define buffer irapcron for irapcron.

    vhttBuffer = phttIrapcron:default-buffer-handle.
    for first irapcron no-lock
        where irapcron.soc-cd = piSoc-cd
          and irapcron.etab-cd = piEtab-cd
          and irapcron.jour-cron = pdaJour-cron
          and irapcron.type-cron = piType-cron
          and irapcron.code-cron = piCode-cron
          and irapcron.nolan = piNolan:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer irapcron:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIrapcron no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIrapcron:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table irapcron Contient rapports sur icron
    Notes  : service externe. Critère piCode-cron = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pdaJour-cron as date       no-undo.
    define input parameter piType-cron as integer    no-undo.
    define input parameter piCode-cron as integer    no-undo.
    define input parameter table-handle phttIrapcron.
    define variable vhttBuffer as handle  no-undo.
    define buffer irapcron for irapcron.

    vhttBuffer = phttIrapcron:default-buffer-handle.
    if piCode-cron = ?
    then for each irapcron no-lock
        where irapcron.soc-cd = piSoc-cd
          and irapcron.etab-cd = piEtab-cd
          and irapcron.jour-cron = pdaJour-cron
          and irapcron.type-cron = piType-cron:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer irapcron:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each irapcron no-lock
        where irapcron.soc-cd = piSoc-cd
          and irapcron.etab-cd = piEtab-cd
          and irapcron.jour-cron = pdaJour-cron
          and irapcron.type-cron = piType-cron
          and irapcron.code-cron = piCode-cron:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer irapcron:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIrapcron no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIrapcron private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhJour-cron    as handle  no-undo.
    define variable vhType-cron    as handle  no-undo.
    define variable vhCode-cron    as handle  no-undo.
    define variable vhNolan    as handle  no-undo.
    define buffer irapcron for irapcron.

    create query vhttquery.
    vhttBuffer = ghttIrapcron:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIrapcron:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJour-cron, output vhType-cron, output vhCode-cron, output vhNolan).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first irapcron exclusive-lock
                where rowid(irapcron) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer irapcron:handle, 'soc-cd/etab-cd/jour-cron/type-cron/code-cron/nolan: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJour-cron:buffer-value(), vhType-cron:buffer-value(), vhCode-cron:buffer-value(), vhNolan:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer irapcron:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIrapcron private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer irapcron for irapcron.

    create query vhttquery.
    vhttBuffer = ghttIrapcron:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIrapcron:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create irapcron.
            if not outils:copyValidField(buffer irapcron:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIrapcron private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhJour-cron    as handle  no-undo.
    define variable vhType-cron    as handle  no-undo.
    define variable vhCode-cron    as handle  no-undo.
    define variable vhNolan    as handle  no-undo.
    define buffer irapcron for irapcron.

    create query vhttquery.
    vhttBuffer = ghttIrapcron:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIrapcron:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJour-cron, output vhType-cron, output vhCode-cron, output vhNolan).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first irapcron exclusive-lock
                where rowid(Irapcron) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer irapcron:handle, 'soc-cd/etab-cd/jour-cron/type-cron/code-cron/nolan: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJour-cron:buffer-value(), vhType-cron:buffer-value(), vhCode-cron:buffer-value(), vhNolan:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete irapcron no-error.
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

