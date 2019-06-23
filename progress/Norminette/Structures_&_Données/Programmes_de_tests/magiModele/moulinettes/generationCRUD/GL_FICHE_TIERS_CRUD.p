/*------------------------------------------------------------------------
File        : GL_FICHE_TIERS_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table GL_FICHE_TIERS
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/GL_FICHE_TIERS.i}
{application/include/error.i}
define variable ghttGL_FICHE_TIERS as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNofiche as handle, output phNotiers as handle, output phNorol as handle, output phTprol as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nofiche/notiers/norol/tprol, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nofiche' then phNofiche = phBuffer:buffer-field(vi).
            when 'notiers' then phNotiers = phBuffer:buffer-field(vi).
            when 'norol' then phNorol = phBuffer:buffer-field(vi).
            when 'tprol' then phTprol = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudGl_fiche_tiers private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteGl_fiche_tiers.
    run updateGl_fiche_tiers.
    run createGl_fiche_tiers.
end procedure.

procedure setGl_fiche_tiers:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGl_fiche_tiers.
    ghttGl_fiche_tiers = phttGl_fiche_tiers.
    run crudGl_fiche_tiers.
    delete object phttGl_fiche_tiers.
end procedure.

procedure readGl_fiche_tiers:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table GL_FICHE_TIERS Liaison Fiche / Tiers
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNofiche as integer    no-undo.
    define input parameter pcNotiers as character  no-undo.
    define input parameter piNorol   as integer    no-undo.
    define input parameter pcTprol   as character  no-undo.
    define input parameter table-handle phttGl_fiche_tiers.
    define variable vhttBuffer as handle no-undo.
    define buffer GL_FICHE_TIERS for GL_FICHE_TIERS.

    vhttBuffer = phttGl_fiche_tiers:default-buffer-handle.
    for first GL_FICHE_TIERS no-lock
        where GL_FICHE_TIERS.nofiche = piNofiche
          and GL_FICHE_TIERS.notiers = pcNotiers
          and GL_FICHE_TIERS.norol = piNorol
          and GL_FICHE_TIERS.tprol = pcTprol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_FICHE_TIERS:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_fiche_tiers no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getGl_fiche_tiers:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table GL_FICHE_TIERS Liaison Fiche / Tiers
    Notes  : service externe. Critère piNorol = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNofiche as integer    no-undo.
    define input parameter pcNotiers as character  no-undo.
    define input parameter piNorol   as integer    no-undo.
    define input parameter table-handle phttGl_fiche_tiers.
    define variable vhttBuffer as handle  no-undo.
    define buffer GL_FICHE_TIERS for GL_FICHE_TIERS.

    vhttBuffer = phttGl_fiche_tiers:default-buffer-handle.
    if piNorol = ?
    then for each GL_FICHE_TIERS no-lock
        where GL_FICHE_TIERS.nofiche = piNofiche
          and GL_FICHE_TIERS.notiers = pcNotiers:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_FICHE_TIERS:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each GL_FICHE_TIERS no-lock
        where GL_FICHE_TIERS.nofiche = piNofiche
          and GL_FICHE_TIERS.notiers = pcNotiers
          and GL_FICHE_TIERS.norol = piNorol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GL_FICHE_TIERS:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGl_fiche_tiers no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateGl_fiche_tiers private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNofiche    as handle  no-undo.
    define variable vhNotiers    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhTprol    as handle  no-undo.
    define buffer GL_FICHE_TIERS for GL_FICHE_TIERS.

    create query vhttquery.
    vhttBuffer = ghttGl_fiche_tiers:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttGl_fiche_tiers:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNofiche, output vhNotiers, output vhNorol, output vhTprol).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_FICHE_TIERS exclusive-lock
                where rowid(GL_FICHE_TIERS) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_FICHE_TIERS:handle, 'nofiche/notiers/norol/tprol: ', substitute('&1/&2/&3/&4', vhNofiche:buffer-value(), vhNotiers:buffer-value(), vhNorol:buffer-value(), vhTprol:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer GL_FICHE_TIERS:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createGl_fiche_tiers private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer GL_FICHE_TIERS for GL_FICHE_TIERS.

    create query vhttquery.
    vhttBuffer = ghttGl_fiche_tiers:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttGl_fiche_tiers:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create GL_FICHE_TIERS.
            if not outils:copyValidField(buffer GL_FICHE_TIERS:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteGl_fiche_tiers private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNofiche    as handle  no-undo.
    define variable vhNotiers    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhTprol    as handle  no-undo.
    define buffer GL_FICHE_TIERS for GL_FICHE_TIERS.

    create query vhttquery.
    vhttBuffer = ghttGl_fiche_tiers:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttGl_fiche_tiers:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNofiche, output vhNotiers, output vhNorol, output vhTprol).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GL_FICHE_TIERS exclusive-lock
                where rowid(Gl_fiche_tiers) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GL_FICHE_TIERS:handle, 'nofiche/notiers/norol/tprol: ', substitute('&1/&2/&3/&4', vhNofiche:buffer-value(), vhNotiers:buffer-value(), vhNorol:buffer-value(), vhTprol:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete GL_FICHE_TIERS no-error.
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

