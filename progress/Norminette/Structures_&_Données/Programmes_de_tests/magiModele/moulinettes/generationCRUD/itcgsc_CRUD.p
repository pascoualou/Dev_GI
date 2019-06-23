/*------------------------------------------------------------------------
File        : itcgsc_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table itcgsc
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/itcgsc.i}
{application/include/error.i}
define variable ghttitcgsc as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phGsc-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur gsc-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'gsc-cd' then phGsc-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudItcgsc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteItcgsc.
    run updateItcgsc.
    run createItcgsc.
end procedure.

procedure setItcgsc:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttItcgsc.
    ghttItcgsc = phttItcgsc.
    run crudItcgsc.
    delete object phttItcgsc.
end procedure.

procedure readItcgsc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table itcgsc Transfert compta - lien gestion comm., niveaux analytiques
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piGsc-cd as integer    no-undo.
    define input parameter table-handle phttItcgsc.
    define variable vhttBuffer as handle no-undo.
    define buffer itcgsc for itcgsc.

    vhttBuffer = phttItcgsc:default-buffer-handle.
    for first itcgsc no-lock
        where itcgsc.gsc-cd = piGsc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itcgsc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttItcgsc no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getItcgsc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table itcgsc Transfert compta - lien gestion comm., niveaux analytiques
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttItcgsc.
    define variable vhttBuffer as handle  no-undo.
    define buffer itcgsc for itcgsc.

    vhttBuffer = phttItcgsc:default-buffer-handle.
    for each itcgsc no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itcgsc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttItcgsc no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateItcgsc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhGsc-cd    as handle  no-undo.
    define buffer itcgsc for itcgsc.

    create query vhttquery.
    vhttBuffer = ghttItcgsc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttItcgsc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhGsc-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first itcgsc exclusive-lock
                where rowid(itcgsc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer itcgsc:handle, 'gsc-cd: ', substitute('&1', vhGsc-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer itcgsc:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createItcgsc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer itcgsc for itcgsc.

    create query vhttquery.
    vhttBuffer = ghttItcgsc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttItcgsc:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create itcgsc.
            if not outils:copyValidField(buffer itcgsc:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteItcgsc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhGsc-cd    as handle  no-undo.
    define buffer itcgsc for itcgsc.

    create query vhttquery.
    vhttBuffer = ghttItcgsc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttItcgsc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhGsc-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first itcgsc exclusive-lock
                where rowid(Itcgsc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer itcgsc:handle, 'gsc-cd: ', substitute('&1', vhGsc-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete itcgsc no-error.
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

