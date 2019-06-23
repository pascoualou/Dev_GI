/*------------------------------------------------------------------------
File        : iadrcli_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iadrcli
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iadrcli.i}
{application/include/error.i}
define variable ghttiadrcli as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phCli-cle as handle, output phLibadr-cd as handle, output phAdr-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/cli-cle/libadr-cd/adr-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'cli-cle' then phCli-cle = phBuffer:buffer-field(vi).
            when 'libadr-cd' then phLibadr-cd = phBuffer:buffer-field(vi).
            when 'adr-cd' then phAdr-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIadrcli private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIadrcli.
    run updateIadrcli.
    run createIadrcli.
end procedure.

procedure setIadrcli:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIadrcli.
    ghttIadrcli = phttIadrcli.
    run crudIadrcli.
    delete object phttIadrcli.
end procedure.

procedure readIadrcli:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iadrcli Liste des adresses pour les clients.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter pcCli-cle   as character  no-undo.
    define input parameter piLibadr-cd as integer    no-undo.
    define input parameter piAdr-cd    as integer    no-undo.
    define input parameter table-handle phttIadrcli.
    define variable vhttBuffer as handle no-undo.
    define buffer iadrcli for iadrcli.

    vhttBuffer = phttIadrcli:default-buffer-handle.
    for first iadrcli no-lock
        where iadrcli.soc-cd = piSoc-cd
          and iadrcli.cli-cle = pcCli-cle
          and iadrcli.libadr-cd = piLibadr-cd
          and iadrcli.adr-cd = piAdr-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iadrcli:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIadrcli no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIadrcli:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iadrcli Liste des adresses pour les clients.
    Notes  : service externe. Critère piLibadr-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter pcCli-cle   as character  no-undo.
    define input parameter piLibadr-cd as integer    no-undo.
    define input parameter table-handle phttIadrcli.
    define variable vhttBuffer as handle  no-undo.
    define buffer iadrcli for iadrcli.

    vhttBuffer = phttIadrcli:default-buffer-handle.
    if piLibadr-cd = ?
    then for each iadrcli no-lock
        where iadrcli.soc-cd = piSoc-cd
          and iadrcli.cli-cle = pcCli-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iadrcli:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iadrcli no-lock
        where iadrcli.soc-cd = piSoc-cd
          and iadrcli.cli-cle = pcCli-cle
          and iadrcli.libadr-cd = piLibadr-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iadrcli:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIadrcli no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIadrcli private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhCli-cle    as handle  no-undo.
    define variable vhLibadr-cd    as handle  no-undo.
    define variable vhAdr-cd    as handle  no-undo.
    define buffer iadrcli for iadrcli.

    create query vhttquery.
    vhttBuffer = ghttIadrcli:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIadrcli:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhCli-cle, output vhLibadr-cd, output vhAdr-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iadrcli exclusive-lock
                where rowid(iadrcli) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iadrcli:handle, 'soc-cd/cli-cle/libadr-cd/adr-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhCli-cle:buffer-value(), vhLibadr-cd:buffer-value(), vhAdr-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iadrcli:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIadrcli private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iadrcli for iadrcli.

    create query vhttquery.
    vhttBuffer = ghttIadrcli:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIadrcli:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iadrcli.
            if not outils:copyValidField(buffer iadrcli:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIadrcli private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhCli-cle    as handle  no-undo.
    define variable vhLibadr-cd    as handle  no-undo.
    define variable vhAdr-cd    as handle  no-undo.
    define buffer iadrcli for iadrcli.

    create query vhttquery.
    vhttBuffer = ghttIadrcli:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIadrcli:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhCli-cle, output vhLibadr-cd, output vhAdr-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iadrcli exclusive-lock
                where rowid(Iadrcli) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iadrcli:handle, 'soc-cd/cli-cle/libadr-cd/adr-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhCli-cle:buffer-value(), vhLibadr-cd:buffer-value(), vhAdr-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iadrcli no-error.
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

