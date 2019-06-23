/*------------------------------------------------------------------------
File        : indiv_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table indiv
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/indiv.i}
{application/include/error.i}
define variable ghttindiv as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoind as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noind, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noind' then phNoind = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIndiv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIndiv.
    run updateIndiv.
    run createIndiv.
end procedure.

procedure setIndiv:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIndiv.
    ghttIndiv = phttIndiv.
    run crudIndiv.
    delete object phttIndiv.
end procedure.

procedure readIndiv:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table indiv 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoind as integer    no-undo.
    define input parameter table-handle phttIndiv.
    define variable vhttBuffer as handle no-undo.
    define buffer indiv for indiv.

    vhttBuffer = phttIndiv:default-buffer-handle.
    for first indiv no-lock
        where indiv.noind = piNoind:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer indiv:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIndiv no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIndiv:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table indiv 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIndiv.
    define variable vhttBuffer as handle  no-undo.
    define buffer indiv for indiv.

    vhttBuffer = phttIndiv:default-buffer-handle.
    for each indiv no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer indiv:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIndiv no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIndiv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoind    as handle  no-undo.
    define buffer indiv for indiv.

    create query vhttquery.
    vhttBuffer = ghttIndiv:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIndiv:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoind).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first indiv exclusive-lock
                where rowid(indiv) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer indiv:handle, 'noind: ', substitute('&1', vhNoind:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer indiv:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIndiv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer indiv for indiv.

    create query vhttquery.
    vhttBuffer = ghttIndiv:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIndiv:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create indiv.
            if not outils:copyValidField(buffer indiv:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIndiv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoind    as handle  no-undo.
    define buffer indiv for indiv.

    create query vhttquery.
    vhttBuffer = ghttIndiv:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIndiv:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoind).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first indiv exclusive-lock
                where rowid(Indiv) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer indiv:handle, 'noind: ', substitute('&1', vhNoind:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete indiv no-error.
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

