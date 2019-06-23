/*------------------------------------------------------------------------
File        : RqExtEnt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table RqExtEnt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/RqExtEnt.i}
{application/include/error.i}
define variable ghttRqExtEnt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdreq as handle, output phCdext as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cdreq/cdext, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cdreq' then phCdreq = phBuffer:buffer-field(vi).
            when 'cdext' then phCdext = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudRqextent private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteRqextent.
    run updateRqextent.
    run createRqextent.
end procedure.

procedure setRqextent:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRqextent.
    ghttRqextent = phttRqextent.
    run crudRqextent.
    delete object phttRqextent.
end procedure.

procedure readRqextent:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table RqExtEnt Entete des options d'extraction de la requete
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdreq as character  no-undo.
    define input parameter pcCdext as character  no-undo.
    define input parameter table-handle phttRqextent.
    define variable vhttBuffer as handle no-undo.
    define buffer RqExtEnt for RqExtEnt.

    vhttBuffer = phttRqextent:default-buffer-handle.
    for first RqExtEnt no-lock
        where RqExtEnt.cdreq = pcCdreq
          and RqExtEnt.cdext = pcCdext:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer RqExtEnt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRqextent no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getRqextent:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table RqExtEnt Entete des options d'extraction de la requete
    Notes  : service externe. Critère pcCdreq = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCdreq as character  no-undo.
    define input parameter table-handle phttRqextent.
    define variable vhttBuffer as handle  no-undo.
    define buffer RqExtEnt for RqExtEnt.

    vhttBuffer = phttRqextent:default-buffer-handle.
    if pcCdreq = ?
    then for each RqExtEnt no-lock
        where RqExtEnt.cdreq = pcCdreq:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer RqExtEnt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each RqExtEnt no-lock
        where RqExtEnt.cdreq = pcCdreq:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer RqExtEnt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRqextent no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateRqextent private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdreq    as handle  no-undo.
    define variable vhCdext    as handle  no-undo.
    define buffer RqExtEnt for RqExtEnt.

    create query vhttquery.
    vhttBuffer = ghttRqextent:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttRqextent:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdreq, output vhCdext).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first RqExtEnt exclusive-lock
                where rowid(RqExtEnt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer RqExtEnt:handle, 'cdreq/cdext: ', substitute('&1/&2', vhCdreq:buffer-value(), vhCdext:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer RqExtEnt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createRqextent private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer RqExtEnt for RqExtEnt.

    create query vhttquery.
    vhttBuffer = ghttRqextent:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttRqextent:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create RqExtEnt.
            if not outils:copyValidField(buffer RqExtEnt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteRqextent private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdreq    as handle  no-undo.
    define variable vhCdext    as handle  no-undo.
    define buffer RqExtEnt for RqExtEnt.

    create query vhttquery.
    vhttBuffer = ghttRqextent:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttRqextent:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdreq, output vhCdext).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first RqExtEnt exclusive-lock
                where rowid(Rqextent) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer RqExtEnt:handle, 'cdreq/cdext: ', substitute('&1/&2', vhCdreq:buffer-value(), vhCdext:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete RqExtEnt no-error.
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

