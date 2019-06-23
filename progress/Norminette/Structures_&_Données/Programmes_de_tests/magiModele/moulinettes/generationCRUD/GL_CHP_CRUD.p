/*------------------------------------------------------------------------
File        : GL_CHP_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table GL_CHP
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/GL_CHP.i}
{application/include/error.i}
define variable ghttGL_CHP as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNochp as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nochp, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nochp' then phNochp = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudGl_chp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteGl_chp.
    run updateGl_chp.
    run createGl_chp.
end procedure.

procedure setGl_chp:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_chp.
    ghttGl_chp = phttGl_chp.
    run crudGl_chp.
    delete object phttGl_chp.
end procedure.

procedure readGl_chp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table GL_CHP Liste des champs du module. Type : 1=>Moteur de recherche, 2=>Fiche (en prévision)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNochp as integer    no-undo.
    define input parameter table-handle phttGl_chp.
    define variable vhttBuffer as handle no-undo.
    define buffer GL_CHP for GL_CHP.

    vhttBuffer = phttGl_chp:default-buffer-handle.
    for first GL_CHP no-lock
        where GL_CHP.nochp = piNochp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_CHP:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_chp no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getGl_chp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table GL_CHP Liste des champs du module. Type : 1=>Moteur de recherche, 2=>Fiche (en prévision)
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_chp.
    define variable vhttBuffer as handle  no-undo.
    define buffer GL_CHP for GL_CHP.

    vhttBuffer = phttGl_chp:default-buffer-handle.
    for each GL_CHP no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_CHP:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_chp no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateGl_chp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNochp    as handle  no-undo.
    define buffer GL_CHP for GL_CHP.

    create query vhttquery.
    vhttBuffer = ghttGl_chp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttGl_chp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNochp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_CHP exclusive-lock
                where rowid(GL_CHP) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_CHP:handle, 'nochp: ', substitute('&1', vhNochp:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer GL_CHP:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createGl_chp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer GL_CHP for GL_CHP.

    create query vhttquery.
    vhttBuffer = ghttGl_chp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttGl_chp:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create GL_CHP.
            if not outils:copyValidField(buffer GL_CHP:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteGl_chp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNochp    as handle  no-undo.
    define buffer GL_CHP for GL_CHP.

    create query vhttquery.
    vhttBuffer = ghttGl_chp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttGl_chp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNochp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_CHP exclusive-lock
                where rowid(Gl_chp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_CHP:handle, 'nochp: ', substitute('&1', vhNochp:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete GL_CHP no-error.
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

