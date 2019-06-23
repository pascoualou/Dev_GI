/*------------------------------------------------------------------------
File        : GL_SITEWEB_TBFIC_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table GL_SITEWEB_TBFIC
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/GL_SITEWEB_TBFIC.i}
{application/include/error.i}
define variable ghttGL_SITEWEB_TBFIC as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNositeweb as handle, output phNoidt as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nositeweb/noidt, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nositeweb' then phNositeweb = phBuffer:buffer-field(vi).
            when 'noidt' then phNoidt = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudGl_siteweb_tbfic private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteGl_siteweb_tbfic.
    run updateGl_siteweb_tbfic.
    run createGl_siteweb_tbfic.
end procedure.

procedure setGl_siteweb_tbfic:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_siteweb_tbfic.
    ghttGl_siteweb_tbfic = phttGl_siteweb_tbfic.
    run crudGl_siteweb_tbfic.
    delete object phttGl_siteweb_tbfic.
end procedure.

procedure readGl_siteweb_tbfic:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table GL_SITEWEB_TBFIC Liaison Site web / Fichier (champ "ne pas publier photo sur www")
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNositeweb as integer    no-undo.
    define input parameter piNoidt     as integer    no-undo.
    define input parameter table-handle phttGl_siteweb_tbfic.
    define variable vhttBuffer as handle no-undo.
    define buffer GL_SITEWEB_TBFIC for GL_SITEWEB_TBFIC.

    vhttBuffer = phttGl_siteweb_tbfic:default-buffer-handle.
    for first GL_SITEWEB_TBFIC no-lock
        where GL_SITEWEB_TBFIC.nositeweb = piNositeweb
          and GL_SITEWEB_TBFIC.noidt = piNoidt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_SITEWEB_TBFIC:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_siteweb_tbfic no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getGl_siteweb_tbfic:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table GL_SITEWEB_TBFIC Liaison Site web / Fichier (champ "ne pas publier photo sur www")
    Notes  : service externe. Critère piNositeweb = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNositeweb as integer    no-undo.
    define input parameter table-handle phttGl_siteweb_tbfic.
    define variable vhttBuffer as handle  no-undo.
    define buffer GL_SITEWEB_TBFIC for GL_SITEWEB_TBFIC.

    vhttBuffer = phttGl_siteweb_tbfic:default-buffer-handle.
    if piNositeweb = ?
    then for each GL_SITEWEB_TBFIC no-lock
        where GL_SITEWEB_TBFIC.nositeweb = piNositeweb:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_SITEWEB_TBFIC:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each GL_SITEWEB_TBFIC no-lock
        where GL_SITEWEB_TBFIC.nositeweb = piNositeweb:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_SITEWEB_TBFIC:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_siteweb_tbfic no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateGl_siteweb_tbfic private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNositeweb    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define buffer GL_SITEWEB_TBFIC for GL_SITEWEB_TBFIC.

    create query vhttquery.
    vhttBuffer = ghttGl_siteweb_tbfic:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttGl_siteweb_tbfic:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNositeweb, output vhNoidt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_SITEWEB_TBFIC exclusive-lock
                where rowid(GL_SITEWEB_TBFIC) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_SITEWEB_TBFIC:handle, 'nositeweb/noidt: ', substitute('&1/&2', vhNositeweb:buffer-value(), vhNoidt:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer GL_SITEWEB_TBFIC:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createGl_siteweb_tbfic private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer GL_SITEWEB_TBFIC for GL_SITEWEB_TBFIC.

    create query vhttquery.
    vhttBuffer = ghttGl_siteweb_tbfic:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttGl_siteweb_tbfic:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create GL_SITEWEB_TBFIC.
            if not outils:copyValidField(buffer GL_SITEWEB_TBFIC:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteGl_siteweb_tbfic private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNositeweb    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define buffer GL_SITEWEB_TBFIC for GL_SITEWEB_TBFIC.

    create query vhttquery.
    vhttBuffer = ghttGl_siteweb_tbfic:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttGl_siteweb_tbfic:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNositeweb, output vhNoidt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_SITEWEB_TBFIC exclusive-lock
                where rowid(Gl_siteweb_tbfic) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_SITEWEB_TBFIC:handle, 'nositeweb/noidt: ', substitute('&1/&2', vhNositeweb:buffer-value(), vhNoidt:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete GL_SITEWEB_TBFIC no-error.
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

