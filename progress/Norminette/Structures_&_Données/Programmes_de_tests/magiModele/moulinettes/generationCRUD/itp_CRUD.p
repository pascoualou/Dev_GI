/*------------------------------------------------------------------------
File        : itp_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table itp
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/itp.i}
{application/include/error.i}
define variable ghttitp as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phTp-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/tp-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'tp-cd' then phTp-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudItp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteItp.
    run updateItp.
    run createItp.
end procedure.

procedure setItp:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttItp.
    ghttItp = phttItp.
    run crudItp.
    delete object phttItp.
end procedure.

procedure readItp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table itp Liste des differents taux de taxes paraf.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd as integer    no-undo.
    define input parameter piTp-cd  as integer    no-undo.
    define input parameter table-handle phttItp.
    define variable vhttBuffer as handle no-undo.
    define buffer itp for itp.

    vhttBuffer = phttItp:default-buffer-handle.
    for first itp no-lock
        where itp.soc-cd = piSoc-cd
          and itp.tp-cd = piTp-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttItp no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getItp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table itp Liste des differents taux de taxes paraf.
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd as integer    no-undo.
    define input parameter table-handle phttItp.
    define variable vhttBuffer as handle  no-undo.
    define buffer itp for itp.

    vhttBuffer = phttItp:default-buffer-handle.
    if piSoc-cd = ?
    then for each itp no-lock
        where itp.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each itp no-lock
        where itp.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttItp no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateItp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhTp-cd    as handle  no-undo.
    define buffer itp for itp.

    create query vhttquery.
    vhttBuffer = ghttItp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttItp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhTp-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first itp exclusive-lock
                where rowid(itp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer itp:handle, 'soc-cd/tp-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhTp-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer itp:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createItp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer itp for itp.

    create query vhttquery.
    vhttBuffer = ghttItp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttItp:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create itp.
            if not outils:copyValidField(buffer itp:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteItp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhTp-cd    as handle  no-undo.
    define buffer itp for itp.

    create query vhttquery.
    vhttBuffer = ghttItp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttItp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhTp-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first itp exclusive-lock
                where rowid(Itp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer itp:handle, 'soc-cd/tp-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhTp-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete itp no-error.
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

