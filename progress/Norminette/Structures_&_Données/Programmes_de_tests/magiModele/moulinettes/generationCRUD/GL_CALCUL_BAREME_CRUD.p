/*------------------------------------------------------------------------
File        : GL_CALCUL_BAREME_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table GL_CALCUL_BAREME
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/GL_CALCUL_BAREME.i}
{application/include/error.i}
define variable ghttGL_CALCUL_BAREME as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNocalcul_bareme as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nocalcul_bareme, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nocalcul_bareme' then phNocalcul_bareme = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudGl_calcul_bareme private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteGl_calcul_bareme.
    run updateGl_calcul_bareme.
    run createGl_calcul_bareme.
end procedure.

procedure setGl_calcul_bareme:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_calcul_bareme.
    ghttGl_calcul_bareme = phttGl_calcul_bareme.
    run crudGl_calcul_bareme.
    delete object phttGl_calcul_bareme.
end procedure.

procedure readGl_calcul_bareme:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table GL_CALCUL_BAREME Liste des calculs des barèmes honoraires ALUR
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNocalcul_bareme as integer    no-undo.
    define input parameter table-handle phttGl_calcul_bareme.
    define variable vhttBuffer as handle no-undo.
    define buffer GL_CALCUL_BAREME for GL_CALCUL_BAREME.

    vhttBuffer = phttGl_calcul_bareme:default-buffer-handle.
    for first GL_CALCUL_BAREME no-lock
        where GL_CALCUL_BAREME.nocalcul_bareme = piNocalcul_bareme:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_CALCUL_BAREME:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_calcul_bareme no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getGl_calcul_bareme:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table GL_CALCUL_BAREME Liste des calculs des barèmes honoraires ALUR
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_calcul_bareme.
    define variable vhttBuffer as handle  no-undo.
    define buffer GL_CALCUL_BAREME for GL_CALCUL_BAREME.

    vhttBuffer = phttGl_calcul_bareme:default-buffer-handle.
    for each GL_CALCUL_BAREME no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_CALCUL_BAREME:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_calcul_bareme no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateGl_calcul_bareme private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNocalcul_bareme    as handle  no-undo.
    define buffer GL_CALCUL_BAREME for GL_CALCUL_BAREME.

    create query vhttquery.
    vhttBuffer = ghttGl_calcul_bareme:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttGl_calcul_bareme:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNocalcul_bareme).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_CALCUL_BAREME exclusive-lock
                where rowid(GL_CALCUL_BAREME) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_CALCUL_BAREME:handle, 'nocalcul_bareme: ', substitute('&1', vhNocalcul_bareme:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer GL_CALCUL_BAREME:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createGl_calcul_bareme private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer GL_CALCUL_BAREME for GL_CALCUL_BAREME.

    create query vhttquery.
    vhttBuffer = ghttGl_calcul_bareme:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttGl_calcul_bareme:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create GL_CALCUL_BAREME.
            if not outils:copyValidField(buffer GL_CALCUL_BAREME:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteGl_calcul_bareme private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNocalcul_bareme    as handle  no-undo.
    define buffer GL_CALCUL_BAREME for GL_CALCUL_BAREME.

    create query vhttquery.
    vhttBuffer = ghttGl_calcul_bareme:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttGl_calcul_bareme:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNocalcul_bareme).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_CALCUL_BAREME exclusive-lock
                where rowid(Gl_calcul_bareme) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_CALCUL_BAREME:handle, 'nocalcul_bareme: ', substitute('&1', vhNocalcul_bareme:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete GL_CALCUL_BAREME no-error.
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

