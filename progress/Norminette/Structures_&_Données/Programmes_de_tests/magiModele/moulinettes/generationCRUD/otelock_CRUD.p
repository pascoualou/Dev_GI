/*------------------------------------------------------------------------
File        : otelock_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table otelock
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/otelock.i}
{application/include/error.i}
define variable ghttotelock as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phDacre as handle, output phHeurcre as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur dacre/heurcre, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'dacre' then phDacre = phBuffer:buffer-field(vi).
            when 'heurcre' then phHeurcre = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudOtelock private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteOtelock.
    run updateOtelock.
    run createOtelock.
end procedure.

procedure setOtelock:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttOtelock.
    ghttOtelock = phttOtelock.
    run crudOtelock.
    delete object phttOtelock.
end procedure.

procedure readOtelock:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table otelock Mise a jour batch
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pdaDacre   as date       no-undo.
    define input parameter piHeurcre as integer    no-undo.
    define input parameter table-handle phttOtelock.
    define variable vhttBuffer as handle no-undo.
    define buffer otelock for otelock.

    vhttBuffer = phttOtelock:default-buffer-handle.
    for first otelock no-lock
        where otelock.dacre = pdaDacre
          and otelock.heurcre = piHeurcre:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer otelock:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttOtelock no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getOtelock:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table otelock Mise a jour batch
    Notes  : service externe. Critère pdaDacre = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pdaDacre   as date       no-undo.
    define input parameter table-handle phttOtelock.
    define variable vhttBuffer as handle  no-undo.
    define buffer otelock for otelock.

    vhttBuffer = phttOtelock:default-buffer-handle.
    if pdaDacre = ?
    then for each otelock no-lock
        where otelock.dacre = pdaDacre:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer otelock:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each otelock no-lock
        where otelock.dacre = pdaDacre:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer otelock:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttOtelock no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateOtelock private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhDacre    as handle  no-undo.
    define variable vhHeurcre    as handle  no-undo.
    define buffer otelock for otelock.

    create query vhttquery.
    vhttBuffer = ghttOtelock:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttOtelock:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhDacre, output vhHeurcre).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first otelock exclusive-lock
                where rowid(otelock) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer otelock:handle, 'dacre/heurcre: ', substitute('&1/&2', vhDacre:buffer-value(), vhHeurcre:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer otelock:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createOtelock private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer otelock for otelock.

    create query vhttquery.
    vhttBuffer = ghttOtelock:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttOtelock:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create otelock.
            if not outils:copyValidField(buffer otelock:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteOtelock private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhDacre    as handle  no-undo.
    define variable vhHeurcre    as handle  no-undo.
    define buffer otelock for otelock.

    create query vhttquery.
    vhttBuffer = ghttOtelock:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttOtelock:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhDacre, output vhHeurcre).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first otelock exclusive-lock
                where rowid(Otelock) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer otelock:handle, 'dacre/heurcre: ', substitute('&1/&2', vhDacre:buffer-value(), vhHeurcre:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete otelock no-error.
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

