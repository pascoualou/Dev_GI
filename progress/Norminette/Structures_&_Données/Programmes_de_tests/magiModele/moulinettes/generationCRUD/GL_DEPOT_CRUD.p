/*------------------------------------------------------------------------
File        : GL_DEPOT_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table GL_DEPOT
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/GL_DEPOT.i}
{application/include/error.i}
define variable ghttGL_DEPOT as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNodepot as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nodepot, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nodepot' then phNodepot = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudGl_depot private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteGl_depot.
    run updateGl_depot.
    run createGl_depot.
end procedure.

procedure setGl_depot:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_depot.
    ghttGl_depot = phttGl_depot.
    run crudGl_depot.
    delete object phttGl_depot.
end procedure.

procedure readGl_depot:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table GL_DEPOT Eléments financiers de type "dépôt".
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNodepot as integer    no-undo.
    define input parameter table-handle phttGl_depot.
    define variable vhttBuffer as handle no-undo.
    define buffer GL_DEPOT for GL_DEPOT.

    vhttBuffer = phttGl_depot:default-buffer-handle.
    for first GL_DEPOT no-lock
        where GL_DEPOT.nodepot = piNodepot:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_DEPOT:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_depot no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getGl_depot:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table GL_DEPOT Eléments financiers de type "dépôt".
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_depot.
    define variable vhttBuffer as handle  no-undo.
    define buffer GL_DEPOT for GL_DEPOT.

    vhttBuffer = phttGl_depot:default-buffer-handle.
    for each GL_DEPOT no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_DEPOT:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_depot no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateGl_depot private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNodepot    as handle  no-undo.
    define buffer GL_DEPOT for GL_DEPOT.

    create query vhttquery.
    vhttBuffer = ghttGl_depot:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttGl_depot:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNodepot).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_DEPOT exclusive-lock
                where rowid(GL_DEPOT) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_DEPOT:handle, 'nodepot: ', substitute('&1', vhNodepot:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer GL_DEPOT:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createGl_depot private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer GL_DEPOT for GL_DEPOT.

    create query vhttquery.
    vhttBuffer = ghttGl_depot:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttGl_depot:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create GL_DEPOT.
            if not outils:copyValidField(buffer GL_DEPOT:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteGl_depot private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNodepot    as handle  no-undo.
    define buffer GL_DEPOT for GL_DEPOT.

    create query vhttquery.
    vhttBuffer = ghttGl_depot:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttGl_depot:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNodepot).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_DEPOT exclusive-lock
                where rowid(Gl_depot) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_DEPOT:handle, 'nodepot: ', substitute('&1', vhNodepot:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete GL_DEPOT no-error.
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

