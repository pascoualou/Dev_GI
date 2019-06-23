/*------------------------------------------------------------------------
File        : itypfac_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table itypfac
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/itypfac.i}
{application/include/error.i}
define variable ghttitypfac as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTypfac-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur typfac-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'typfac-cd' then phTypfac-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudItypfac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteItypfac.
    run updateItypfac.
    run createItypfac.
end procedure.

procedure setItypfac:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttItypfac.
    ghttItypfac = phttItypfac.
    run crudItypfac.
    delete object phttItypfac.
end procedure.

procedure readItypfac:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table itypfac Fichier des libelles de facturation
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piTypfac-cd as integer    no-undo.
    define input parameter table-handle phttItypfac.
    define variable vhttBuffer as handle no-undo.
    define buffer itypfac for itypfac.

    vhttBuffer = phttItypfac:default-buffer-handle.
    for first itypfac no-lock
        where itypfac.typfac-cd = piTypfac-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itypfac:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttItypfac no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getItypfac:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table itypfac Fichier des libelles de facturation
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttItypfac.
    define variable vhttBuffer as handle  no-undo.
    define buffer itypfac for itypfac.

    vhttBuffer = phttItypfac:default-buffer-handle.
    for each itypfac no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itypfac:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttItypfac no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateItypfac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTypfac-cd    as handle  no-undo.
    define buffer itypfac for itypfac.

    create query vhttquery.
    vhttBuffer = ghttItypfac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttItypfac:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTypfac-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first itypfac exclusive-lock
                where rowid(itypfac) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer itypfac:handle, 'typfac-cd: ', substitute('&1', vhTypfac-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer itypfac:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createItypfac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer itypfac for itypfac.

    create query vhttquery.
    vhttBuffer = ghttItypfac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttItypfac:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create itypfac.
            if not outils:copyValidField(buffer itypfac:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteItypfac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTypfac-cd    as handle  no-undo.
    define buffer itypfac for itypfac.

    create query vhttquery.
    vhttBuffer = ghttItypfac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttItypfac:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTypfac-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first itypfac exclusive-lock
                where rowid(Itypfac) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer itypfac:handle, 'typfac-cd: ', substitute('&1', vhTypfac-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete itypfac no-error.
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

