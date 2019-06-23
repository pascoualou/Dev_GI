/*------------------------------------------------------------------------
File        : GL_HISTO_WORKFLOW_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table GL_HISTO_WORKFLOW
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/GL_HISTO_WORKFLOW.i}
{application/include/error.i}
define variable ghttGL_HISTO_WORKFLOW as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNohisto_workflow as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nohisto_workflow, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nohisto_workflow' then phNohisto_workflow = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudGl_histo_workflow private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteGl_histo_workflow.
    run updateGl_histo_workflow.
    run createGl_histo_workflow.
end procedure.

procedure setGl_histo_workflow:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_histo_workflow.
    ghttGl_histo_workflow = phttGl_histo_workflow.
    run crudGl_histo_workflow.
    delete object phttGl_histo_workflow.
end procedure.

procedure readGl_histo_workflow:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table GL_HISTO_WORKFLOW Historique changement d'étape du workflow
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNohisto_workflow as integer    no-undo.
    define input parameter table-handle phttGl_histo_workflow.
    define variable vhttBuffer as handle no-undo.
    define buffer GL_HISTO_WORKFLOW for GL_HISTO_WORKFLOW.

    vhttBuffer = phttGl_histo_workflow:default-buffer-handle.
    for first GL_HISTO_WORKFLOW no-lock
        where GL_HISTO_WORKFLOW.nohisto_workflow = piNohisto_workflow:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_HISTO_WORKFLOW:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_histo_workflow no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getGl_histo_workflow:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table GL_HISTO_WORKFLOW Historique changement d'étape du workflow
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_histo_workflow.
    define variable vhttBuffer as handle  no-undo.
    define buffer GL_HISTO_WORKFLOW for GL_HISTO_WORKFLOW.

    vhttBuffer = phttGl_histo_workflow:default-buffer-handle.
    for each GL_HISTO_WORKFLOW no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_HISTO_WORKFLOW:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_histo_workflow no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateGl_histo_workflow private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNohisto_workflow    as handle  no-undo.
    define buffer GL_HISTO_WORKFLOW for GL_HISTO_WORKFLOW.

    create query vhttquery.
    vhttBuffer = ghttGl_histo_workflow:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttGl_histo_workflow:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNohisto_workflow).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_HISTO_WORKFLOW exclusive-lock
                where rowid(GL_HISTO_WORKFLOW) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_HISTO_WORKFLOW:handle, 'nohisto_workflow: ', substitute('&1', vhNohisto_workflow:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer GL_HISTO_WORKFLOW:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createGl_histo_workflow private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer GL_HISTO_WORKFLOW for GL_HISTO_WORKFLOW.

    create query vhttquery.
    vhttBuffer = ghttGl_histo_workflow:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttGl_histo_workflow:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create GL_HISTO_WORKFLOW.
            if not outils:copyValidField(buffer GL_HISTO_WORKFLOW:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteGl_histo_workflow private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNohisto_workflow    as handle  no-undo.
    define buffer GL_HISTO_WORKFLOW for GL_HISTO_WORKFLOW.

    create query vhttquery.
    vhttBuffer = ghttGl_histo_workflow:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttGl_histo_workflow:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNohisto_workflow).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_HISTO_WORKFLOW exclusive-lock
                where rowid(Gl_histo_workflow) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_HISTO_WORKFLOW:handle, 'nohisto_workflow: ', substitute('&1', vhNohisto_workflow:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete GL_HISTO_WORKFLOW no-error.
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

