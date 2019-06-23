/*------------------------------------------------------------------------
File        : istatcli_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table istatcli
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/istatcli.i}
{application/include/error.i}
define variable ghttistatcli as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phCli-cle as handle, output phPrd-cd as handle, output phPrd-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/cli-cle/prd-cd/prd-num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'cli-cle' then phCli-cle = phBuffer:buffer-field(vi).
            when 'prd-cd' then phPrd-cd = phBuffer:buffer-field(vi).
            when 'prd-num' then phPrd-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIstatcli private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIstatcli.
    run updateIstatcli.
    run createIstatcli.
end procedure.

procedure setIstatcli:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIstatcli.
    ghttIstatcli = phttIstatcli.
    run crudIstatcli.
    delete object phttIstatcli.
end procedure.

procedure readIstatcli:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table istatcli Statistique concernant les clients.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcCli-cle as character  no-undo.
    define input parameter piPrd-cd  as integer    no-undo.
    define input parameter piPrd-num as integer    no-undo.
    define input parameter table-handle phttIstatcli.
    define variable vhttBuffer as handle no-undo.
    define buffer istatcli for istatcli.

    vhttBuffer = phttIstatcli:default-buffer-handle.
    for first istatcli no-lock
        where istatcli.soc-cd = piSoc-cd
          and istatcli.etab-cd = piEtab-cd
          and istatcli.cli-cle = pcCli-cle
          and istatcli.prd-cd = piPrd-cd
          and istatcli.prd-num = piPrd-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer istatcli:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIstatcli no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIstatcli:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table istatcli Statistique concernant les clients.
    Notes  : service externe. Critère piPrd-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcCli-cle as character  no-undo.
    define input parameter piPrd-cd  as integer    no-undo.
    define input parameter table-handle phttIstatcli.
    define variable vhttBuffer as handle  no-undo.
    define buffer istatcli for istatcli.

    vhttBuffer = phttIstatcli:default-buffer-handle.
    if piPrd-cd = ?
    then for each istatcli no-lock
        where istatcli.soc-cd = piSoc-cd
          and istatcli.etab-cd = piEtab-cd
          and istatcli.cli-cle = pcCli-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer istatcli:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each istatcli no-lock
        where istatcli.soc-cd = piSoc-cd
          and istatcli.etab-cd = piEtab-cd
          and istatcli.cli-cle = pcCli-cle
          and istatcli.prd-cd = piPrd-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer istatcli:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIstatcli no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIstatcli private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhCli-cle    as handle  no-undo.
    define variable vhPrd-cd    as handle  no-undo.
    define variable vhPrd-num    as handle  no-undo.
    define buffer istatcli for istatcli.

    create query vhttquery.
    vhttBuffer = ghttIstatcli:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIstatcli:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhCli-cle, output vhPrd-cd, output vhPrd-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first istatcli exclusive-lock
                where rowid(istatcli) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer istatcli:handle, 'soc-cd/etab-cd/cli-cle/prd-cd/prd-num: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCli-cle:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer istatcli:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIstatcli private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer istatcli for istatcli.

    create query vhttquery.
    vhttBuffer = ghttIstatcli:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIstatcli:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create istatcli.
            if not outils:copyValidField(buffer istatcli:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIstatcli private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhCli-cle    as handle  no-undo.
    define variable vhPrd-cd    as handle  no-undo.
    define variable vhPrd-num    as handle  no-undo.
    define buffer istatcli for istatcli.

    create query vhttquery.
    vhttBuffer = ghttIstatcli:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIstatcli:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhCli-cle, output vhPrd-cd, output vhPrd-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first istatcli exclusive-lock
                where rowid(Istatcli) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer istatcli:handle, 'soc-cd/etab-cd/cli-cle/prd-cd/prd-num: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCli-cle:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete istatcli no-error.
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

