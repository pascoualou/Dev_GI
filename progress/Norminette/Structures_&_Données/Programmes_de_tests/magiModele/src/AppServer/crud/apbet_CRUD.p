/*------------------------------------------------------------------------
File        : apbet_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table apbet
Author(s)   : generation automatique le 08/08/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttapbet as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNobud as handle, output phTpapp as handle, output phNoapp as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nobud/tpapp/noapp, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nobud' then phNobud = phBuffer:buffer-field(vi).
            when 'tpapp' then phTpapp = phBuffer:buffer-field(vi).
            when 'noapp' then phNoapp = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudApbet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteApbet.
    run updateApbet.
    run createApbet.
end procedure.

procedure setApbet:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttApbet.
    ghttApbet = phttApbet.
    run crudApbet.
    delete object phttApbet.
end procedure.

procedure readApbet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table apbet 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNobud as int64      no-undo.
    define input parameter pcTpapp as character  no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter table-handle phttApbet.
    define variable vhttBuffer as handle no-undo.
    define buffer apbet for apbet.

    vhttBuffer = phttApbet:default-buffer-handle.
    for first apbet no-lock
        where apbet.nobud = piNobud
          and apbet.tpapp = pcTpapp
          and apbet.noapp = piNoapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer apbet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttApbet no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getApbet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table apbet 
    Notes  : service externe. Critère pcTpapp = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNobud as int64      no-undo.
    define input parameter pcTpapp as character  no-undo.
    define input parameter table-handle phttApbet.
    define variable vhttBuffer as handle  no-undo.
    define buffer apbet for apbet.

    vhttBuffer = phttApbet:default-buffer-handle.
    if pcTpapp = ?
    then for each apbet no-lock
        where apbet.nobud = piNobud:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer apbet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each apbet no-lock
        where apbet.nobud = piNobud
          and apbet.tpapp = pcTpapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer apbet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttApbet no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateApbet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery   as handle  no-undo.
    define variable vhttBuffer  as handle  no-undo.
    define variable vhNobud as handle  no-undo.
    define variable vhTpapp as handle  no-undo.
    define variable vhNoapp as handle  no-undo.
    define buffer apbet for apbet.

    create query vhttquery.
    vhttBuffer = ghttApbet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttApbet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNobud, output vhTpapp, output vhNoapp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first apbet exclusive-lock
                where rowid(apbet) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer apbet:handle, 'nobud/tpapp/noapp: ', substitute('&1/&2/&3', vhNobud:buffer-value(), vhTpapp:buffer-value(), vhNoapp:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer apbet:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createApbet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer apbet for apbet.

    create query vhttquery.
    vhttBuffer = ghttApbet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttApbet:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create apbet.
            if not outils:copyValidField(buffer apbet:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteApbet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNobud as handle  no-undo.
    define variable vhTpapp as handle  no-undo.
    define variable vhNoapp as handle  no-undo.
    define buffer apbet for apbet.

    create query vhttquery.
    vhttBuffer = ghttApbet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttApbet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNobud, output vhTpapp, output vhNoapp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first apbet exclusive-lock
                where rowid(Apbet) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer apbet:handle, 'nobud/tpapp/noapp: ', substitute('&1/&2/&3', vhNobud:buffer-value(), vhTpapp:buffer-value(), vhNoapp:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete apbet no-error.
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

