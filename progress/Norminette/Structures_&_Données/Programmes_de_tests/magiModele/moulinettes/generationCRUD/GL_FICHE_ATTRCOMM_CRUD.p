/*------------------------------------------------------------------------
File        : GL_FICHE_ATTRCOMM_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table GL_FICHE_ATTRCOMM
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/GL_FICHE_ATTRCOMM.i}
{application/include/error.i}
define variable ghttGL_FICHE_ATTRCOMM as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNofiche as handle, output phNoattrcom as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nofiche/noattrcom, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nofiche' then phNofiche = phBuffer:buffer-field(vi).
            when 'noattrcom' then phNoattrcom = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudGl_fiche_attrcomm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteGl_fiche_attrcomm.
    run updateGl_fiche_attrcomm.
    run createGl_fiche_attrcomm.
end procedure.

procedure setGl_fiche_attrcomm:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_fiche_attrcomm.
    ghttGl_fiche_attrcomm = phttGl_fiche_attrcomm.
    run crudGl_fiche_attrcomm.
    delete object phttGl_fiche_attrcomm.
end procedure.

procedure readGl_fiche_attrcomm:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table GL_FICHE_ATTRCOMM Liaison Fiche / Attributs commerciaux
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNofiche   as integer    no-undo.
    define input parameter piNoattrcom as integer    no-undo.
    define input parameter table-handle phttGl_fiche_attrcomm.
    define variable vhttBuffer as handle no-undo.
    define buffer GL_FICHE_ATTRCOMM for GL_FICHE_ATTRCOMM.

    vhttBuffer = phttGl_fiche_attrcomm:default-buffer-handle.
    for first GL_FICHE_ATTRCOMM no-lock
        where GL_FICHE_ATTRCOMM.nofiche = piNofiche
          and GL_FICHE_ATTRCOMM.noattrcom = piNoattrcom:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_FICHE_ATTRCOMM:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_fiche_attrcomm no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getGl_fiche_attrcomm:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table GL_FICHE_ATTRCOMM Liaison Fiche / Attributs commerciaux
    Notes  : service externe. Critère piNofiche = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNofiche   as integer    no-undo.
    define input parameter table-handle phttGl_fiche_attrcomm.
    define variable vhttBuffer as handle  no-undo.
    define buffer GL_FICHE_ATTRCOMM for GL_FICHE_ATTRCOMM.

    vhttBuffer = phttGl_fiche_attrcomm:default-buffer-handle.
    if piNofiche = ?
    then for each GL_FICHE_ATTRCOMM no-lock
        where GL_FICHE_ATTRCOMM.nofiche = piNofiche:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_FICHE_ATTRCOMM:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each GL_FICHE_ATTRCOMM no-lock
        where GL_FICHE_ATTRCOMM.nofiche = piNofiche:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_FICHE_ATTRCOMM:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_fiche_attrcomm no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateGl_fiche_attrcomm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNofiche    as handle  no-undo.
    define variable vhNoattrcom    as handle  no-undo.
    define buffer GL_FICHE_ATTRCOMM for GL_FICHE_ATTRCOMM.

    create query vhttquery.
    vhttBuffer = ghttGl_fiche_attrcomm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttGl_fiche_attrcomm:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNofiche, output vhNoattrcom).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_FICHE_ATTRCOMM exclusive-lock
                where rowid(GL_FICHE_ATTRCOMM) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_FICHE_ATTRCOMM:handle, 'nofiche/noattrcom: ', substitute('&1/&2', vhNofiche:buffer-value(), vhNoattrcom:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer GL_FICHE_ATTRCOMM:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createGl_fiche_attrcomm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer GL_FICHE_ATTRCOMM for GL_FICHE_ATTRCOMM.

    create query vhttquery.
    vhttBuffer = ghttGl_fiche_attrcomm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttGl_fiche_attrcomm:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create GL_FICHE_ATTRCOMM.
            if not outils:copyValidField(buffer GL_FICHE_ATTRCOMM:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteGl_fiche_attrcomm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNofiche    as handle  no-undo.
    define variable vhNoattrcom    as handle  no-undo.
    define buffer GL_FICHE_ATTRCOMM for GL_FICHE_ATTRCOMM.

    create query vhttquery.
    vhttBuffer = ghttGl_fiche_attrcomm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttGl_fiche_attrcomm:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNofiche, output vhNoattrcom).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_FICHE_ATTRCOMM exclusive-lock
                where rowid(Gl_fiche_attrcomm) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_FICHE_ATTRCOMM:handle, 'nofiche/noattrcom: ', substitute('&1/&2', vhNofiche:buffer-value(), vhNoattrcom:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete GL_FICHE_ATTRCOMM no-error.
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

