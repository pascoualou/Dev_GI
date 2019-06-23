/*------------------------------------------------------------------------
File        : icumbque_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table icumbque
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/icumbque.i}
{application/include/error.i}
define variable ghtticumbque as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phBque-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/bque-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'bque-cd' then phBque-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIcumbque private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIcumbque.
    run updateIcumbque.
    run createIcumbque.
end procedure.

procedure setIcumbque:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIcumbque.
    ghttIcumbque = phttIcumbque.
    run crudIcumbque.
    delete object phttIcumbque.
end procedure.

procedure readIcumbque:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table icumbque Cumuls par banque.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piBque-cd as integer    no-undo.
    define input parameter table-handle phttIcumbque.
    define variable vhttBuffer as handle no-undo.
    define buffer icumbque for icumbque.

    vhttBuffer = phttIcumbque:default-buffer-handle.
    for first icumbque no-lock
        where icumbque.soc-cd = piSoc-cd
          and icumbque.etab-cd = piEtab-cd
          and icumbque.bque-cd = piBque-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer icumbque:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIcumbque no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIcumbque:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table icumbque Cumuls par banque.
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter table-handle phttIcumbque.
    define variable vhttBuffer as handle  no-undo.
    define buffer icumbque for icumbque.

    vhttBuffer = phttIcumbque:default-buffer-handle.
    if piEtab-cd = ?
    then for each icumbque no-lock
        where icumbque.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer icumbque:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each icumbque no-lock
        where icumbque.soc-cd = piSoc-cd
          and icumbque.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer icumbque:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIcumbque no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIcumbque private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhBque-cd    as handle  no-undo.
    define buffer icumbque for icumbque.

    create query vhttquery.
    vhttBuffer = ghttIcumbque:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIcumbque:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhBque-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first icumbque exclusive-lock
                where rowid(icumbque) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer icumbque:handle, 'soc-cd/etab-cd/bque-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhBque-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer icumbque:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIcumbque private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer icumbque for icumbque.

    create query vhttquery.
    vhttBuffer = ghttIcumbque:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIcumbque:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create icumbque.
            if not outils:copyValidField(buffer icumbque:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIcumbque private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhBque-cd    as handle  no-undo.
    define buffer icumbque for icumbque.

    create query vhttquery.
    vhttBuffer = ghttIcumbque:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIcumbque:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhBque-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first icumbque exclusive-lock
                where rowid(Icumbque) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer icumbque:handle, 'soc-cd/etab-cd/bque-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhBque-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete icumbque no-error.
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

