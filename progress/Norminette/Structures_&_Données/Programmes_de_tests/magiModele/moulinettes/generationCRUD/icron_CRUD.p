/*------------------------------------------------------------------------
File        : icron_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table icron
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/icron.i}
{application/include/error.i}
define variable ghtticron as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phType-cron as handle, output phPeriod as handle, output phCode-cron as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/type-cron/period/code-cron, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'type-cron' then phType-cron = phBuffer:buffer-field(vi).
            when 'period' then phPeriod = phBuffer:buffer-field(vi).
            when 'code-cron' then phCode-cron = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIcron private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIcron.
    run updateIcron.
    run createIcron.
end procedure.

procedure setIcron:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIcron.
    ghttIcron = phttIcron.
    run crudIcron.
    delete object phttIcron.
end procedure.

procedure readIcron:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table icron 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter piType-cron as integer    no-undo.
    define input parameter pcPeriod    as character  no-undo.
    define input parameter piCode-cron as integer    no-undo.
    define input parameter table-handle phttIcron.
    define variable vhttBuffer as handle no-undo.
    define buffer icron for icron.

    vhttBuffer = phttIcron:default-buffer-handle.
    for first icron no-lock
        where icron.soc-cd = piSoc-cd
          and icron.etab-cd = piEtab-cd
          and icron.type-cron = piType-cron
          and icron.period = pcPeriod
          and icron.code-cron = piCode-cron:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer icron:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIcron no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIcron:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table icron 
    Notes  : service externe. Critère pcPeriod = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter piType-cron as integer    no-undo.
    define input parameter pcPeriod    as character  no-undo.
    define input parameter table-handle phttIcron.
    define variable vhttBuffer as handle  no-undo.
    define buffer icron for icron.

    vhttBuffer = phttIcron:default-buffer-handle.
    if pcPeriod = ?
    then for each icron no-lock
        where icron.soc-cd = piSoc-cd
          and icron.etab-cd = piEtab-cd
          and icron.type-cron = piType-cron:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer icron:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each icron no-lock
        where icron.soc-cd = piSoc-cd
          and icron.etab-cd = piEtab-cd
          and icron.type-cron = piType-cron
          and icron.period = pcPeriod:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer icron:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIcron no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIcron private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhType-cron    as handle  no-undo.
    define variable vhPeriod    as handle  no-undo.
    define variable vhCode-cron    as handle  no-undo.
    define buffer icron for icron.

    create query vhttquery.
    vhttBuffer = ghttIcron:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIcron:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhType-cron, output vhPeriod, output vhCode-cron).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first icron exclusive-lock
                where rowid(icron) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer icron:handle, 'soc-cd/etab-cd/type-cron/period/code-cron: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhType-cron:buffer-value(), vhPeriod:buffer-value(), vhCode-cron:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer icron:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIcron private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer icron for icron.

    create query vhttquery.
    vhttBuffer = ghttIcron:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIcron:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create icron.
            if not outils:copyValidField(buffer icron:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIcron private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhType-cron    as handle  no-undo.
    define variable vhPeriod    as handle  no-undo.
    define variable vhCode-cron    as handle  no-undo.
    define buffer icron for icron.

    create query vhttquery.
    vhttBuffer = ghttIcron:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIcron:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhType-cron, output vhPeriod, output vhCode-cron).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first icron exclusive-lock
                where rowid(Icron) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer icron:handle, 'soc-cd/etab-cd/type-cron/period/code-cron: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhType-cron:buffer-value(), vhPeriod:buffer-value(), vhCode-cron:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete icron no-error.
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

