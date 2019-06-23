/*------------------------------------------------------------------------
File        : iribcli_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iribcli
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iribcli.i}
{application/include/error.i}
define variable ghttiribcli as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phCli-cle as handle, output phOrdre-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/cli-cle/ordre-num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'cli-cle' then phCli-cle = phBuffer:buffer-field(vi).
            when 'ordre-num' then phOrdre-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIribcli private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIribcli.
    run updateIribcli.
    run createIribcli.
end procedure.

procedure setIribcli:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIribcli.
    ghttIribcli = phttIribcli.
    run crudIribcli.
    delete object phttIribcli.
end procedure.

procedure readIribcli:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iribcli Liste des RIB pour les clients.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter pcCli-cle   as character  no-undo.
    define input parameter piOrdre-num as integer    no-undo.
    define input parameter table-handle phttIribcli.
    define variable vhttBuffer as handle no-undo.
    define buffer iribcli for iribcli.

    vhttBuffer = phttIribcli:default-buffer-handle.
    for first iribcli no-lock
        where iribcli.soc-cd = piSoc-cd
          and iribcli.cli-cle = pcCli-cle
          and iribcli.ordre-num = piOrdre-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iribcli:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIribcli no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIribcli:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iribcli Liste des RIB pour les clients.
    Notes  : service externe. Critère pcCli-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter pcCli-cle   as character  no-undo.
    define input parameter table-handle phttIribcli.
    define variable vhttBuffer as handle  no-undo.
    define buffer iribcli for iribcli.

    vhttBuffer = phttIribcli:default-buffer-handle.
    if pcCli-cle = ?
    then for each iribcli no-lock
        where iribcli.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iribcli:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iribcli no-lock
        where iribcli.soc-cd = piSoc-cd
          and iribcli.cli-cle = pcCli-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iribcli:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIribcli no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIribcli private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhCli-cle    as handle  no-undo.
    define variable vhOrdre-num    as handle  no-undo.
    define buffer iribcli for iribcli.

    create query vhttquery.
    vhttBuffer = ghttIribcli:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIribcli:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhCli-cle, output vhOrdre-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iribcli exclusive-lock
                where rowid(iribcli) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iribcli:handle, 'soc-cd/cli-cle/ordre-num: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhCli-cle:buffer-value(), vhOrdre-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iribcli:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIribcli private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iribcli for iribcli.

    create query vhttquery.
    vhttBuffer = ghttIribcli:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIribcli:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iribcli.
            if not outils:copyValidField(buffer iribcli:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIribcli private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhCli-cle    as handle  no-undo.
    define variable vhOrdre-num    as handle  no-undo.
    define buffer iribcli for iribcli.

    create query vhttquery.
    vhttBuffer = ghttIribcli:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIribcli:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhCli-cle, output vhOrdre-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iribcli exclusive-lock
                where rowid(Iribcli) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iribcli:handle, 'soc-cd/cli-cle/ordre-num: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhCli-cle:buffer-value(), vhOrdre-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iribcli no-error.
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

