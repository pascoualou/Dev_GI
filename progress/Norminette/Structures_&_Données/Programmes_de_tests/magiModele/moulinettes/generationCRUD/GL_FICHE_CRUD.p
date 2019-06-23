/*------------------------------------------------------------------------
File        : GL_FICHE_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table GL_FICHE
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/GL_FICHE.i}
{application/include/error.i}
define variable ghttGL_FICHE as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNofiche as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nofiche, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nofiche' then phNofiche = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudGl_fiche private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteGl_fiche.
    run updateGl_fiche.
    run createGl_fiche.
end procedure.

procedure setGl_fiche:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_fiche.
    ghttGl_fiche = phttGl_fiche.
    run crudGl_fiche.
    delete object phttGl_fiche.
end procedure.

procedure readGl_fiche:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table GL_FICHE Liste des fiches 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNofiche as integer    no-undo.
    define input parameter table-handle phttGl_fiche.
    define variable vhttBuffer as handle no-undo.
    define buffer GL_FICHE for GL_FICHE.

    vhttBuffer = phttGl_fiche:default-buffer-handle.
    for first GL_FICHE no-lock
        where GL_FICHE.nofiche = piNofiche:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_FICHE:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_fiche no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getGl_fiche:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table GL_FICHE Liste des fiches 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_fiche.
    define variable vhttBuffer as handle  no-undo.
    define buffer GL_FICHE for GL_FICHE.

    vhttBuffer = phttGl_fiche:default-buffer-handle.
    for each GL_FICHE no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_FICHE:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_fiche no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateGl_fiche private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNofiche    as handle  no-undo.
    define buffer GL_FICHE for GL_FICHE.

    create query vhttquery.
    vhttBuffer = ghttGl_fiche:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttGl_fiche:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNofiche).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_FICHE exclusive-lock
                where rowid(GL_FICHE) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_FICHE:handle, 'nofiche: ', substitute('&1', vhNofiche:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer GL_FICHE:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createGl_fiche private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer GL_FICHE for GL_FICHE.

    create query vhttquery.
    vhttBuffer = ghttGl_fiche:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttGl_fiche:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create GL_FICHE.
            if not outils:copyValidField(buffer GL_FICHE:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteGl_fiche private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNofiche    as handle  no-undo.
    define buffer GL_FICHE for GL_FICHE.

    create query vhttquery.
    vhttBuffer = ghttGl_fiche:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttGl_fiche:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNofiche).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_FICHE exclusive-lock
                where rowid(Gl_fiche) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_FICHE:handle, 'nofiche: ', substitute('&1', vhNofiche:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete GL_FICHE no-error.
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

