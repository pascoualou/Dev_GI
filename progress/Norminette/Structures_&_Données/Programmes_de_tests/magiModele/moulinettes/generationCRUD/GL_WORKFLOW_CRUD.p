/*------------------------------------------------------------------------
File        : GL_WORKFLOW_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table GL_WORKFLOW
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/GL_WORKFLOW.i}
{application/include/error.i}
define variable ghttGL_WORKFLOW as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoworkflow1 as handle, output phNoworkflow2 as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noworkflow1/noworkflow2, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noworkflow1' then phNoworkflow1 = phBuffer:buffer-field(vi).
            when 'noworkflow2' then phNoworkflow2 = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudGl_workflow private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteGl_workflow.
    run updateGl_workflow.
    run createGl_workflow.
end procedure.

procedure setGl_workflow:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_workflow.
    ghttGl_workflow = phttGl_workflow.
    run crudGl_workflow.
    delete object phttGl_workflow.
end procedure.

procedure readGl_workflow:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table GL_WORKFLOW Liaison entre les différentes étapes du workflow
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoworkflow1 as integer    no-undo.
    define input parameter piNoworkflow2 as integer    no-undo.
    define input parameter table-handle phttGl_workflow.
    define variable vhttBuffer as handle no-undo.
    define buffer GL_WORKFLOW for GL_WORKFLOW.

    vhttBuffer = phttGl_workflow:default-buffer-handle.
    for first GL_WORKFLOW no-lock
        where GL_WORKFLOW.noworkflow1 = piNoworkflow1
          and GL_WORKFLOW.noworkflow2 = piNoworkflow2:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_WORKFLOW:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_workflow no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getGl_workflow:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table GL_WORKFLOW Liaison entre les différentes étapes du workflow
    Notes  : service externe. Critère piNoworkflow1 = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoworkflow1 as integer    no-undo.
    define input parameter table-handle phttGl_workflow.
    define variable vhttBuffer as handle  no-undo.
    define buffer GL_WORKFLOW for GL_WORKFLOW.

    vhttBuffer = phttGl_workflow:default-buffer-handle.
    if piNoworkflow1 = ?
    then for each GL_WORKFLOW no-lock
        where GL_WORKFLOW.noworkflow1 = piNoworkflow1:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_WORKFLOW:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each GL_WORKFLOW no-lock
        where GL_WORKFLOW.noworkflow1 = piNoworkflow1:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_WORKFLOW:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_workflow no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateGl_workflow private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoworkflow1    as handle  no-undo.
    define variable vhNoworkflow2    as handle  no-undo.
    define buffer GL_WORKFLOW for GL_WORKFLOW.

    create query vhttquery.
    vhttBuffer = ghttGl_workflow:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttGl_workflow:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoworkflow1, output vhNoworkflow2).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_WORKFLOW exclusive-lock
                where rowid(GL_WORKFLOW) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_WORKFLOW:handle, 'noworkflow1/noworkflow2: ', substitute('&1/&2', vhNoworkflow1:buffer-value(), vhNoworkflow2:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer GL_WORKFLOW:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createGl_workflow private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer GL_WORKFLOW for GL_WORKFLOW.

    create query vhttquery.
    vhttBuffer = ghttGl_workflow:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttGl_workflow:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create GL_WORKFLOW.
            if not outils:copyValidField(buffer GL_WORKFLOW:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteGl_workflow private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoworkflow1    as handle  no-undo.
    define variable vhNoworkflow2    as handle  no-undo.
    define buffer GL_WORKFLOW for GL_WORKFLOW.

    create query vhttquery.
    vhttBuffer = ghttGl_workflow:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttGl_workflow:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoworkflow1, output vhNoworkflow2).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_WORKFLOW exclusive-lock
                where rowid(Gl_workflow) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_WORKFLOW:handle, 'noworkflow1/noworkflow2: ', substitute('&1/&2', vhNoworkflow1:buffer-value(), vhNoworkflow2:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete GL_WORKFLOW no-error.
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

