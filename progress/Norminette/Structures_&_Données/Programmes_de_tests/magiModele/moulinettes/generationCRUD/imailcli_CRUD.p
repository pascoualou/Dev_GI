/*------------------------------------------------------------------------
File        : imailcli_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table imailcli
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/imailcli.i}
{application/include/error.i}
define variable ghttimailcli as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phCli-cle as handle, output phLibadr-cd as handle, output phAdr-cd as handle, output phMail-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/cli-cle/libadr-cd/adr-cd/mail-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'cli-cle' then phCli-cle = phBuffer:buffer-field(vi).
            when 'libadr-cd' then phLibadr-cd = phBuffer:buffer-field(vi).
            when 'adr-cd' then phAdr-cd = phBuffer:buffer-field(vi).
            when 'mail-cle' then phMail-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudImailcli private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteImailcli.
    run updateImailcli.
    run createImailcli.
end procedure.

procedure setImailcli:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttImailcli.
    ghttImailcli = phttImailcli.
    run crudImailcli.
    delete object phttImailcli.
end procedure.

procedure readImailcli:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table imailcli Liste des mailings.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter pcCli-cle   as character  no-undo.
    define input parameter piLibadr-cd as integer    no-undo.
    define input parameter piAdr-cd    as integer    no-undo.
    define input parameter pcMail-cle  as character  no-undo.
    define input parameter table-handle phttImailcli.
    define variable vhttBuffer as handle no-undo.
    define buffer imailcli for imailcli.

    vhttBuffer = phttImailcli:default-buffer-handle.
    for first imailcli no-lock
        where imailcli.soc-cd = piSoc-cd
          and imailcli.cli-cle = pcCli-cle
          and imailcli.libadr-cd = piLibadr-cd
          and imailcli.adr-cd = piAdr-cd
          and imailcli.mail-cle = pcMail-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer imailcli:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttImailcli no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getImailcli:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table imailcli Liste des mailings.
    Notes  : service externe. Critère piAdr-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter pcCli-cle   as character  no-undo.
    define input parameter piLibadr-cd as integer    no-undo.
    define input parameter piAdr-cd    as integer    no-undo.
    define input parameter table-handle phttImailcli.
    define variable vhttBuffer as handle  no-undo.
    define buffer imailcli for imailcli.

    vhttBuffer = phttImailcli:default-buffer-handle.
    if piAdr-cd = ?
    then for each imailcli no-lock
        where imailcli.soc-cd = piSoc-cd
          and imailcli.cli-cle = pcCli-cle
          and imailcli.libadr-cd = piLibadr-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer imailcli:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each imailcli no-lock
        where imailcli.soc-cd = piSoc-cd
          and imailcli.cli-cle = pcCli-cle
          and imailcli.libadr-cd = piLibadr-cd
          and imailcli.adr-cd = piAdr-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer imailcli:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttImailcli no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateImailcli private:
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
    define variable vhMail-cle    as handle  no-undo.
    define buffer imailcli for imailcli.

    create query vhttquery.
    vhttBuffer = ghttImailcli:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttImailcli:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhCli-cle, output vhLibadr-cd, output vhAdr-cd, output vhMail-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first imailcli exclusive-lock
                where rowid(imailcli) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer imailcli:handle, 'soc-cd/cli-cle/libadr-cd/adr-cd/mail-cle: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhCli-cle:buffer-value(), vhLibadr-cd:buffer-value(), vhAdr-cd:buffer-value(), vhMail-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer imailcli:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createImailcli private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer imailcli for imailcli.

    create query vhttquery.
    vhttBuffer = ghttImailcli:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttImailcli:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create imailcli.
            if not outils:copyValidField(buffer imailcli:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteImailcli private:
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
    define variable vhMail-cle    as handle  no-undo.
    define buffer imailcli for imailcli.

    create query vhttquery.
    vhttBuffer = ghttImailcli:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttImailcli:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhCli-cle, output vhLibadr-cd, output vhAdr-cd, output vhMail-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first imailcli exclusive-lock
                where rowid(Imailcli) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer imailcli:handle, 'soc-cd/cli-cle/libadr-cd/adr-cd/mail-cle: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhCli-cle:buffer-value(), vhLibadr-cd:buffer-value(), vhAdr-cd:buffer-value(), vhMail-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete imailcli no-error.
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

