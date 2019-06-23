/*------------------------------------------------------------------------
File        : iprd_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iprd
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iprd.i}
{application/include/error.i}
define variable ghttiprd as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phPrd-cd as handle, output phPrd-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/prd-cd/prd-num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'prd-cd' then phPrd-cd = phBuffer:buffer-field(vi).
            when 'prd-num' then phPrd-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIprd private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIprd.
    run updateIprd.
    run createIprd.
end procedure.

procedure setIprd:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIprd.
    ghttIprd = phttIprd.
    run crudIprd.
    delete object phttIprd.
end procedure.

procedure readIprd:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iprd Liste des periodes pour un etablissement d'une societe.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piPrd-cd  as integer    no-undo.
    define input parameter piPrd-num as integer    no-undo.
    define input parameter table-handle phttIprd.
    define variable vhttBuffer as handle no-undo.
    define buffer iprd for iprd.

    vhttBuffer = phttIprd:default-buffer-handle.
    for first iprd no-lock
        where iprd.soc-cd = piSoc-cd
          and iprd.etab-cd = piEtab-cd
          and iprd.prd-cd = piPrd-cd
          and iprd.prd-num = piPrd-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iprd:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIprd no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIprd:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iprd Liste des periodes pour un etablissement d'une societe.
    Notes  : service externe. Critère piPrd-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piPrd-cd  as integer    no-undo.
    define input parameter table-handle phttIprd.
    define variable vhttBuffer as handle  no-undo.
    define buffer iprd for iprd.

    vhttBuffer = phttIprd:default-buffer-handle.
    if piPrd-cd = ?
    then for each iprd no-lock
        where iprd.soc-cd = piSoc-cd
          and iprd.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iprd:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iprd no-lock
        where iprd.soc-cd = piSoc-cd
          and iprd.etab-cd = piEtab-cd
          and iprd.prd-cd = piPrd-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iprd:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIprd no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIprd private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhPrd-cd    as handle  no-undo.
    define variable vhPrd-num    as handle  no-undo.
    define buffer iprd for iprd.

    create query vhttquery.
    vhttBuffer = ghttIprd:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIprd:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhPrd-cd, output vhPrd-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iprd exclusive-lock
                where rowid(iprd) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iprd:handle, 'soc-cd/etab-cd/prd-cd/prd-num: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iprd:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIprd private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iprd for iprd.

    create query vhttquery.
    vhttBuffer = ghttIprd:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIprd:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iprd.
            if not outils:copyValidField(buffer iprd:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIprd private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhPrd-cd    as handle  no-undo.
    define variable vhPrd-num    as handle  no-undo.
    define buffer iprd for iprd.

    create query vhttquery.
    vhttBuffer = ghttIprd:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIprd:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhPrd-cd, output vhPrd-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iprd exclusive-lock
                where rowid(Iprd) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iprd:handle, 'soc-cd/etab-cd/prd-cd/prd-num: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iprd no-error.
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

procedure deleteIprdSurEtabCd:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSociete   as integer no-undo.
    define input parameter piCodeEtabl as integer no-undo.
    
    define buffer iprd for iprd.

message "deleteIprdSurEtabCd " piSociete "// " piCodeEtabl. 

blocTrans:
    do transaction:
        for each iprd exclusive-lock
           where iprd.soc-cd  = piSociete
             and iprd.etab-cd = piCodeEtabl:
            delete iprd no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.

