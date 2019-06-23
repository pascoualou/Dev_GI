/*------------------------------------------------------------------------
File        : GL_C_SITEWEB_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table GL_C_SITEWEB
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/GL_C_SITEWEB.i}
{application/include/error.i}
define variable ghttGL_C_SITEWEB as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNocorrespondance as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nocorrespondance, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nocorrespondance' then phNocorrespondance = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudGl_c_siteweb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteGl_c_siteweb.
    run updateGl_c_siteweb.
    run createGl_c_siteweb.
end procedure.

procedure setGl_c_siteweb:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_c_siteweb.
    ghttGl_c_siteweb = phttGl_c_siteweb.
    run crudGl_c_siteweb.
    delete object phttGl_c_siteweb.
end procedure.

procedure readGl_c_siteweb:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table GL_C_SITEWEB Table de correspondance données GI / site web annonce. Exemple : pour le type de lot "Chambre de bonne", Seloger attend "Appartement".
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNocorrespondance as integer    no-undo.
    define input parameter table-handle phttGl_c_siteweb.
    define variable vhttBuffer as handle no-undo.
    define buffer GL_C_SITEWEB for GL_C_SITEWEB.

    vhttBuffer = phttGl_c_siteweb:default-buffer-handle.
    for first GL_C_SITEWEB no-lock
        where GL_C_SITEWEB.nocorrespondance = piNocorrespondance:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_C_SITEWEB:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_c_siteweb no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getGl_c_siteweb:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table GL_C_SITEWEB Table de correspondance données GI / site web annonce. Exemple : pour le type de lot "Chambre de bonne", Seloger attend "Appartement".
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_c_siteweb.
    define variable vhttBuffer as handle  no-undo.
    define buffer GL_C_SITEWEB for GL_C_SITEWEB.

    vhttBuffer = phttGl_c_siteweb:default-buffer-handle.
    for each GL_C_SITEWEB no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_C_SITEWEB:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_c_siteweb no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateGl_c_siteweb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNocorrespondance    as handle  no-undo.
    define buffer GL_C_SITEWEB for GL_C_SITEWEB.

    create query vhttquery.
    vhttBuffer = ghttGl_c_siteweb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttGl_c_siteweb:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNocorrespondance).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_C_SITEWEB exclusive-lock
                where rowid(GL_C_SITEWEB) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_C_SITEWEB:handle, 'nocorrespondance: ', substitute('&1', vhNocorrespondance:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer GL_C_SITEWEB:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createGl_c_siteweb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer GL_C_SITEWEB for GL_C_SITEWEB.

    create query vhttquery.
    vhttBuffer = ghttGl_c_siteweb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttGl_c_siteweb:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create GL_C_SITEWEB.
            if not outils:copyValidField(buffer GL_C_SITEWEB:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteGl_c_siteweb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNocorrespondance    as handle  no-undo.
    define buffer GL_C_SITEWEB for GL_C_SITEWEB.

    create query vhttquery.
    vhttBuffer = ghttGl_c_siteweb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttGl_c_siteweb:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNocorrespondance).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_C_SITEWEB exclusive-lock
                where rowid(Gl_c_siteweb) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_C_SITEWEB:handle, 'nocorrespondance: ', substitute('&1', vhNocorrespondance:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete GL_C_SITEWEB no-error.
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

