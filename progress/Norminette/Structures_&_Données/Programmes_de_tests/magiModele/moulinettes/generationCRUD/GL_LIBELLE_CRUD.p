/*------------------------------------------------------------------------
File        : GL_LIBELLE_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table GL_LIBELLE
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/GL_LIBELLE.i}
{application/include/error.i}
define variable ghttGL_LIBELLE as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNolibelle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nolibelle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nolibelle' then phNolibelle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudGl_libelle private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteGl_libelle.
    run updateGl_libelle.
    run createGl_libelle.
end procedure.

procedure setGl_libelle:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_libelle.
    ghttGl_libelle = phttGl_libelle.
    run crudGl_libelle.
    delete object phttGl_libelle.
end procedure.

procedure readGl_libelle:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table GL_LIBELLE Liste des libelles (listes déroulantes).
Tpidt :
-	1 : Attributs commerciaux
-	2 : Mode création
-	3 : Zone ALUR
-	4 : Workflow

    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNolibelle as integer    no-undo.
    define input parameter table-handle phttGl_libelle.
    define variable vhttBuffer as handle no-undo.
    define buffer GL_LIBELLE for GL_LIBELLE.

    vhttBuffer = phttGl_libelle:default-buffer-handle.
    for first GL_LIBELLE no-lock
        where GL_LIBELLE.nolibelle = piNolibelle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_LIBELLE:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_libelle no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getGl_libelle:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table GL_LIBELLE Liste des libelles (listes déroulantes).
Tpidt :
-	1 : Attributs commerciaux
-	2 : Mode création
-	3 : Zone ALUR
-	4 : Workflow

    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_libelle.
    define variable vhttBuffer as handle  no-undo.
    define buffer GL_LIBELLE for GL_LIBELLE.

    vhttBuffer = phttGl_libelle:default-buffer-handle.
    for each GL_LIBELLE no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_LIBELLE:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_libelle no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateGl_libelle private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNolibelle    as handle  no-undo.
    define buffer GL_LIBELLE for GL_LIBELLE.

    create query vhttquery.
    vhttBuffer = ghttGl_libelle:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttGl_libelle:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNolibelle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_LIBELLE exclusive-lock
                where rowid(GL_LIBELLE) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_LIBELLE:handle, 'nolibelle: ', substitute('&1', vhNolibelle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer GL_LIBELLE:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createGl_libelle private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer GL_LIBELLE for GL_LIBELLE.

    create query vhttquery.
    vhttBuffer = ghttGl_libelle:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttGl_libelle:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create GL_LIBELLE.
            if not outils:copyValidField(buffer GL_LIBELLE:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteGl_libelle private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNolibelle    as handle  no-undo.
    define buffer GL_LIBELLE for GL_LIBELLE.

    create query vhttquery.
    vhttBuffer = ghttGl_libelle:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttGl_libelle:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNolibelle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_LIBELLE exclusive-lock
                where rowid(Gl_libelle) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_LIBELLE:handle, 'nolibelle: ', substitute('&1', vhNolibelle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete GL_LIBELLE no-error.
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

