/*------------------------------------------------------------------------
File        : iliv_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iliv
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iliv.i}
{application/include/error.i}
define variable ghttiliv as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phLivr-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/livr-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'livr-cd' then phLivr-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIliv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIliv.
    run updateIliv.
    run createIliv.
end procedure.

procedure setIliv:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIliv.
    ghttIliv = phttIliv.
    run crudIliv.
    delete object phttIliv.
end procedure.

procedure readIliv:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iliv Fichier des modes de livraison
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piLivr-cd as integer    no-undo.
    define input parameter table-handle phttIliv.
    define variable vhttBuffer as handle no-undo.
    define buffer iliv for iliv.

    vhttBuffer = phttIliv:default-buffer-handle.
    for first iliv no-lock
        where iliv.soc-cd = piSoc-cd
          and iliv.livr-cd = piLivr-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iliv:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIliv no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIliv:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iliv Fichier des modes de livraison
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter table-handle phttIliv.
    define variable vhttBuffer as handle  no-undo.
    define buffer iliv for iliv.

    vhttBuffer = phttIliv:default-buffer-handle.
    if piSoc-cd = ?
    then for each iliv no-lock
        where iliv.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iliv:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iliv no-lock
        where iliv.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iliv:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIliv no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIliv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhLivr-cd    as handle  no-undo.
    define buffer iliv for iliv.

    create query vhttquery.
    vhttBuffer = ghttIliv:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIliv:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhLivr-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iliv exclusive-lock
                where rowid(iliv) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iliv:handle, 'soc-cd/livr-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhLivr-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iliv:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIliv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iliv for iliv.

    create query vhttquery.
    vhttBuffer = ghttIliv:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIliv:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iliv.
            if not outils:copyValidField(buffer iliv:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIliv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhLivr-cd    as handle  no-undo.
    define buffer iliv for iliv.

    create query vhttquery.
    vhttBuffer = ghttIliv:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIliv:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhLivr-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iliv exclusive-lock
                where rowid(Iliv) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iliv:handle, 'soc-cd/livr-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhLivr-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iliv no-error.
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

