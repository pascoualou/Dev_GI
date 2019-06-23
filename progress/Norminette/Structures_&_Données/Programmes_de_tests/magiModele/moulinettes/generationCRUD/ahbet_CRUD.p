/*------------------------------------------------------------------------
File        : ahbet_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ahbet
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ahbet.i}
{application/include/error.i}
define variable ghttahbet as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoimm as handle, output phNoapp as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noimm/noapp, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noimm' then phNoimm = phBuffer:buffer-field(vi).
            when 'noapp' then phNoapp = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAhbet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAhbet.
    run updateAhbet.
    run createAhbet.
end procedure.

procedure setAhbet:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAhbet.
    ghttAhbet = phttAhbet.
    run crudAhbet.
    delete object phttAhbet.
end procedure.

procedure readAhbet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ahbet Appels Hors-Budget : Entête
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoimm as integer    no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter table-handle phttAhbet.
    define variable vhttBuffer as handle no-undo.
    define buffer ahbet for ahbet.

    vhttBuffer = phttAhbet:default-buffer-handle.
    for first ahbet no-lock
        where ahbet.noimm = piNoimm
          and ahbet.noapp = piNoapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ahbet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAhbet no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAhbet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ahbet Appels Hors-Budget : Entête
    Notes  : service externe. Critère piNoimm = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoimm as integer    no-undo.
    define input parameter table-handle phttAhbet.
    define variable vhttBuffer as handle  no-undo.
    define buffer ahbet for ahbet.

    vhttBuffer = phttAhbet:default-buffer-handle.
    if piNoimm = ?
    then for each ahbet no-lock
        where ahbet.noimm = piNoimm:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ahbet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ahbet no-lock
        where ahbet.noimm = piNoimm:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ahbet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAhbet no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAhbet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define buffer ahbet for ahbet.

    create query vhttquery.
    vhttBuffer = ghttAhbet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAhbet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoimm, output vhNoapp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ahbet exclusive-lock
                where rowid(ahbet) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ahbet:handle, 'noimm/noapp: ', substitute('&1/&2', vhNoimm:buffer-value(), vhNoapp:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ahbet:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAhbet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ahbet for ahbet.

    create query vhttquery.
    vhttBuffer = ghttAhbet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAhbet:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ahbet.
            if not outils:copyValidField(buffer ahbet:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAhbet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define buffer ahbet for ahbet.

    create query vhttquery.
    vhttBuffer = ghttAhbet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAhbet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoimm, output vhNoapp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ahbet exclusive-lock
                where rowid(Ahbet) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ahbet:handle, 'noimm/noapp: ', substitute('&1/&2', vhNoimm:buffer-value(), vhNoapp:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ahbet no-error.
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

