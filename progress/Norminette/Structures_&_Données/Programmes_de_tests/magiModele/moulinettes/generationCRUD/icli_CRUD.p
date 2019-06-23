/*------------------------------------------------------------------------
File        : icli_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table icli
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/icli.i}
{application/include/error.i}
define variable ghtticli as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phCli-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/cli-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'cli-cle' then phCli-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIcli private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIcli.
    run updateIcli.
    run createIcli.
end procedure.

procedure setIcli:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIcli.
    ghttIcli = phttIcli.
    run crudIcli.
    delete object phttIcli.
end procedure.

procedure readIcli:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table icli Informations relatives aux clients pour le module interface.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter pcCli-cle as character  no-undo.
    define input parameter table-handle phttIcli.
    define variable vhttBuffer as handle no-undo.
    define buffer icli for icli.

    vhttBuffer = phttIcli:default-buffer-handle.
    for first icli no-lock
        where icli.soc-cd = piSoc-cd
          and icli.cli-cle = pcCli-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer icli:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIcli no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIcli:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table icli Informations relatives aux clients pour le module interface.
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter table-handle phttIcli.
    define variable vhttBuffer as handle  no-undo.
    define buffer icli for icli.

    vhttBuffer = phttIcli:default-buffer-handle.
    if piSoc-cd = ?
    then for each icli no-lock
        where icli.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer icli:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each icli no-lock
        where icli.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer icli:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIcli no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIcli private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhCli-cle    as handle  no-undo.
    define buffer icli for icli.

    create query vhttquery.
    vhttBuffer = ghttIcli:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIcli:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhCli-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first icli exclusive-lock
                where rowid(icli) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer icli:handle, 'soc-cd/cli-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhCli-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer icli:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIcli private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer icli for icli.

    create query vhttquery.
    vhttBuffer = ghttIcli:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIcli:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create icli.
            if not outils:copyValidField(buffer icli:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIcli private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhCli-cle    as handle  no-undo.
    define buffer icli for icli.

    create query vhttquery.
    vhttBuffer = ghttIcli:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIcli:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhCli-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first icli exclusive-lock
                where rowid(Icli) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer icli:handle, 'soc-cd/cli-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhCli-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete icli no-error.
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

