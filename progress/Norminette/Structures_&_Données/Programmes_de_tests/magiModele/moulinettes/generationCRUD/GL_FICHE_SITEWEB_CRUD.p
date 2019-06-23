/*------------------------------------------------------------------------
File        : GL_FICHE_SITEWEB_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table GL_FICHE_SITEWEB
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/GL_FICHE_SITEWEB.i}
{application/include/error.i}
define variable ghttGL_FICHE_SITEWEB as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNofiche as handle, output phNositeweb as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nofiche/nositeweb, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nofiche' then phNofiche = phBuffer:buffer-field(vi).
            when 'nositeweb' then phNositeweb = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudGl_fiche_siteweb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteGl_fiche_siteweb.
    run updateGl_fiche_siteweb.
    run createGl_fiche_siteweb.
end procedure.

procedure setGl_fiche_siteweb:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_fiche_siteweb.
    ghttGl_fiche_siteweb = phttGl_fiche_siteweb.
    run crudGl_fiche_siteweb.
    delete object phttGl_fiche_siteweb.
end procedure.

procedure readGl_fiche_siteweb:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table GL_FICHE_SITEWEB Liaison Fiche / Publication WEB
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNofiche   as integer    no-undo.
    define input parameter piNositeweb as integer    no-undo.
    define input parameter table-handle phttGl_fiche_siteweb.
    define variable vhttBuffer as handle no-undo.
    define buffer GL_FICHE_SITEWEB for GL_FICHE_SITEWEB.

    vhttBuffer = phttGl_fiche_siteweb:default-buffer-handle.
    for first GL_FICHE_SITEWEB no-lock
        where GL_FICHE_SITEWEB.nofiche = piNofiche
          and GL_FICHE_SITEWEB.nositeweb = piNositeweb:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_FICHE_SITEWEB:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_fiche_siteweb no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getGl_fiche_siteweb:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table GL_FICHE_SITEWEB Liaison Fiche / Publication WEB
    Notes  : service externe. Critère piNofiche = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNofiche   as integer    no-undo.
    define input parameter table-handle phttGl_fiche_siteweb.
    define variable vhttBuffer as handle  no-undo.
    define buffer GL_FICHE_SITEWEB for GL_FICHE_SITEWEB.

    vhttBuffer = phttGl_fiche_siteweb:default-buffer-handle.
    if piNofiche = ?
    then for each GL_FICHE_SITEWEB no-lock
        where GL_FICHE_SITEWEB.nofiche = piNofiche:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_FICHE_SITEWEB:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each GL_FICHE_SITEWEB no-lock
        where GL_FICHE_SITEWEB.nofiche = piNofiche:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_FICHE_SITEWEB:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_fiche_siteweb no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateGl_fiche_siteweb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNofiche    as handle  no-undo.
    define variable vhNositeweb    as handle  no-undo.
    define buffer GL_FICHE_SITEWEB for GL_FICHE_SITEWEB.

    create query vhttquery.
    vhttBuffer = ghttGl_fiche_siteweb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttGl_fiche_siteweb:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNofiche, output vhNositeweb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_FICHE_SITEWEB exclusive-lock
                where rowid(GL_FICHE_SITEWEB) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_FICHE_SITEWEB:handle, 'nofiche/nositeweb: ', substitute('&1/&2', vhNofiche:buffer-value(), vhNositeweb:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer GL_FICHE_SITEWEB:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createGl_fiche_siteweb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer GL_FICHE_SITEWEB for GL_FICHE_SITEWEB.

    create query vhttquery.
    vhttBuffer = ghttGl_fiche_siteweb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttGl_fiche_siteweb:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create GL_FICHE_SITEWEB.
            if not outils:copyValidField(buffer GL_FICHE_SITEWEB:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteGl_fiche_siteweb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNofiche    as handle  no-undo.
    define variable vhNositeweb    as handle  no-undo.
    define buffer GL_FICHE_SITEWEB for GL_FICHE_SITEWEB.

    create query vhttquery.
    vhttBuffer = ghttGl_fiche_siteweb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttGl_fiche_siteweb:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNofiche, output vhNositeweb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_FICHE_SITEWEB exclusive-lock
                where rowid(Gl_fiche_siteweb) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_FICHE_SITEWEB:handle, 'nofiche/nositeweb: ', substitute('&1/&2', vhNofiche:buffer-value(), vhNositeweb:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete GL_FICHE_SITEWEB no-error.
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

