/*------------------------------------------------------------------------
File        : GL_BAREME_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table GL_BAREME
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/GL_BAREME.i}
{application/include/error.i}
define variable ghttGL_BAREME as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNobareme as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nobareme, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nobareme' then phNobareme = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudGl_bareme private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteGl_bareme.
    run updateGl_bareme.
    run createGl_bareme.
end procedure.

procedure setGl_bareme:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_bareme.
    ghttGl_bareme = phttGl_bareme.
    run crudGl_bareme.
    delete object phttGl_bareme.
end procedure.

procedure readGl_bareme:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table GL_BAREME Liste des barèmes honoraires ALUR.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNobareme as integer    no-undo.
    define input parameter table-handle phttGl_bareme.
    define variable vhttBuffer as handle no-undo.
    define buffer GL_BAREME for GL_BAREME.

    vhttBuffer = phttGl_bareme:default-buffer-handle.
    for first GL_BAREME no-lock
        where GL_BAREME.nobareme = piNobareme:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_BAREME:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_bareme no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getGl_bareme:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table GL_BAREME Liste des barèmes honoraires ALUR.
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_bareme.
    define variable vhttBuffer as handle  no-undo.
    define buffer GL_BAREME for GL_BAREME.

    vhttBuffer = phttGl_bareme:default-buffer-handle.
    for each GL_BAREME no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_BAREME:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_bareme no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateGl_bareme private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNobareme    as handle  no-undo.
    define buffer GL_BAREME for GL_BAREME.

    create query vhttquery.
    vhttBuffer = ghttGl_bareme:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttGl_bareme:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNobareme).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_BAREME exclusive-lock
                where rowid(GL_BAREME) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_BAREME:handle, 'nobareme: ', substitute('&1', vhNobareme:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer GL_BAREME:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createGl_bareme private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer GL_BAREME for GL_BAREME.

    create query vhttquery.
    vhttBuffer = ghttGl_bareme:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttGl_bareme:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create GL_BAREME.
            if not outils:copyValidField(buffer GL_BAREME:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteGl_bareme private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNobareme    as handle  no-undo.
    define buffer GL_BAREME for GL_BAREME.

    create query vhttquery.
    vhttBuffer = ghttGl_bareme:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttGl_bareme:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNobareme).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_BAREME exclusive-lock
                where rowid(Gl_bareme) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_BAREME:handle, 'nobareme: ', substitute('&1', vhNobareme:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete GL_BAREME no-error.
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

