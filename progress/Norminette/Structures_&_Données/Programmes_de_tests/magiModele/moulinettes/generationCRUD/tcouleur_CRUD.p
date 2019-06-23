/*------------------------------------------------------------------------
File        : tcouleur_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table tcouleur
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/tcouleur.i}
{application/include/error.i}
define variable ghtttcouleur as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdlng as handle, output phCode_couleur as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cdlng/code_couleur, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cdlng' then phCdlng = phBuffer:buffer-field(vi).
            when 'code_couleur' then phCode_couleur = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTcouleur private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTcouleur.
    run updateTcouleur.
    run createTcouleur.
end procedure.

procedure setTcouleur:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTcouleur.
    ghttTcouleur = phttTcouleur.
    run crudTcouleur.
    delete object phttTcouleur.
end procedure.

procedure readTcouleur:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table tcouleur 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piCdlng        as integer    no-undo.
    define input parameter pcCode_couleur as character  no-undo.
    define input parameter table-handle phttTcouleur.
    define variable vhttBuffer as handle no-undo.
    define buffer tcouleur for tcouleur.

    vhttBuffer = phttTcouleur:default-buffer-handle.
    for first tcouleur no-lock
        where tcouleur.cdlng = piCdlng
          and tcouleur.code_couleur = pcCode_couleur:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tcouleur:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTcouleur no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTcouleur:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table tcouleur 
    Notes  : service externe. Critère piCdlng = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piCdlng        as integer    no-undo.
    define input parameter table-handle phttTcouleur.
    define variable vhttBuffer as handle  no-undo.
    define buffer tcouleur for tcouleur.

    vhttBuffer = phttTcouleur:default-buffer-handle.
    if piCdlng = ?
    then for each tcouleur no-lock
        where tcouleur.cdlng = piCdlng:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tcouleur:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each tcouleur no-lock
        where tcouleur.cdlng = piCdlng:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tcouleur:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTcouleur no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTcouleur private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdlng    as handle  no-undo.
    define variable vhCode_couleur    as handle  no-undo.
    define buffer tcouleur for tcouleur.

    create query vhttquery.
    vhttBuffer = ghttTcouleur:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTcouleur:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdlng, output vhCode_couleur).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tcouleur exclusive-lock
                where rowid(tcouleur) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tcouleur:handle, 'cdlng/code_couleur: ', substitute('&1/&2', vhCdlng:buffer-value(), vhCode_couleur:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer tcouleur:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTcouleur private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer tcouleur for tcouleur.

    create query vhttquery.
    vhttBuffer = ghttTcouleur:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTcouleur:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create tcouleur.
            if not outils:copyValidField(buffer tcouleur:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTcouleur private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdlng    as handle  no-undo.
    define variable vhCode_couleur    as handle  no-undo.
    define buffer tcouleur for tcouleur.

    create query vhttquery.
    vhttBuffer = ghttTcouleur:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTcouleur:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdlng, output vhCode_couleur).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tcouleur exclusive-lock
                where rowid(Tcouleur) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tcouleur:handle, 'cdlng/code_couleur: ', substitute('&1/&2', vhCdlng:buffer-value(), vhCode_couleur:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete tcouleur no-error.
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

