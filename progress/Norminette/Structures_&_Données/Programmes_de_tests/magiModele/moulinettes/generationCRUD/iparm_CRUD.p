/*------------------------------------------------------------------------
File        : iparm_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iparm
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iparm.i}
{application/include/error.i}
define variable ghttiparm as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTppar as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phCdpar as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tppar/soc-cd/etab-cd/cdpar, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tppar' then phTppar = phBuffer:buffer-field(vi).
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'cdpar' then phCdpar = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIparm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIparm.
    run updateIparm.
    run createIparm.
end procedure.

procedure setIparm:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIparm.
    ghttIparm = phttIparm.
    run crudIparm.
    delete object phttIparm.
end procedure.

procedure readIparm:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iparm 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTppar   as character  no-undo.
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcCdpar   as character  no-undo.
    define input parameter table-handle phttIparm.
    define variable vhttBuffer as handle no-undo.
    define buffer iparm for iparm.

    vhttBuffer = phttIparm:default-buffer-handle.
    for first iparm no-lock
        where iparm.tppar = pcTppar
          and iparm.soc-cd = piSoc-cd
          and iparm.etab-cd = piEtab-cd
          and iparm.cdpar = pcCdpar:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iparm:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIparm no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIparm:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iparm 
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTppar   as character  no-undo.
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter table-handle phttIparm.
    define variable vhttBuffer as handle  no-undo.
    define buffer iparm for iparm.

    vhttBuffer = phttIparm:default-buffer-handle.
    if piEtab-cd = ?
    then for each iparm no-lock
        where iparm.tppar = pcTppar
          and iparm.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iparm:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iparm no-lock
        where iparm.tppar = pcTppar
          and iparm.soc-cd = piSoc-cd
          and iparm.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iparm:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIparm no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIparm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTppar    as handle  no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhCdpar    as handle  no-undo.
    define buffer iparm for iparm.

    create query vhttquery.
    vhttBuffer = ghttIparm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIparm:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTppar, output vhSoc-cd, output vhEtab-cd, output vhCdpar).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iparm exclusive-lock
                where rowid(iparm) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iparm:handle, 'tppar/soc-cd/etab-cd/cdpar: ', substitute('&1/&2/&3/&4', vhTppar:buffer-value(), vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCdpar:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iparm:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIparm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iparm for iparm.

    create query vhttquery.
    vhttBuffer = ghttIparm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIparm:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iparm.
            if not outils:copyValidField(buffer iparm:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIparm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTppar    as handle  no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhCdpar    as handle  no-undo.
    define buffer iparm for iparm.

    create query vhttquery.
    vhttBuffer = ghttIparm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIparm:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTppar, output vhSoc-cd, output vhEtab-cd, output vhCdpar).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iparm exclusive-lock
                where rowid(Iparm) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iparm:handle, 'tppar/soc-cd/etab-cd/cdpar: ', substitute('&1/&2/&3/&4', vhTppar:buffer-value(), vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCdpar:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iparm no-error.
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

