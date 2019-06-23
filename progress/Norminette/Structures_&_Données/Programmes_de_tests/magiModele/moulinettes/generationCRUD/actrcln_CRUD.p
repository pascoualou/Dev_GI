/*------------------------------------------------------------------------
File        : actrcln_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table actrcln
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/actrcln.i}
{application/include/error.i}
define variable ghttactrcln as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCptdeb as handle, output phSscptdeb as handle, output phProfil-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cptdeb/sscptdeb/profil-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cptdeb' then phCptdeb = phBuffer:buffer-field(vi).
            when 'sscptdeb' then phSscptdeb = phBuffer:buffer-field(vi).
            when 'profil-cd' then phProfil-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudActrcln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteActrcln.
    run updateActrcln.
    run createActrcln.
end procedure.

procedure setActrcln:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttActrcln.
    ghttActrcln = phttActrcln.
    run crudActrcln.
    delete object phttActrcln.
end procedure.

procedure readActrcln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table actrcln 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCptdeb    as character  no-undo.
    define input parameter pcSscptdeb  as character  no-undo.
    define input parameter piProfil-cd as integer    no-undo.
    define input parameter table-handle phttActrcln.
    define variable vhttBuffer as handle no-undo.
    define buffer actrcln for actrcln.

    vhttBuffer = phttActrcln:default-buffer-handle.
    for first actrcln no-lock
        where actrcln.cptdeb = pcCptdeb
          and actrcln.sscptdeb = pcSscptdeb
          and actrcln.profil-cd = piProfil-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer actrcln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttActrcln no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getActrcln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table actrcln 
    Notes  : service externe. Critère pcSscptdeb = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCptdeb    as character  no-undo.
    define input parameter pcSscptdeb  as character  no-undo.
    define input parameter table-handle phttActrcln.
    define variable vhttBuffer as handle  no-undo.
    define buffer actrcln for actrcln.

    vhttBuffer = phttActrcln:default-buffer-handle.
    if pcSscptdeb = ?
    then for each actrcln no-lock
        where actrcln.cptdeb = pcCptdeb:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer actrcln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each actrcln no-lock
        where actrcln.cptdeb = pcCptdeb
          and actrcln.sscptdeb = pcSscptdeb:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer actrcln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttActrcln no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateActrcln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCptdeb    as handle  no-undo.
    define variable vhSscptdeb    as handle  no-undo.
    define variable vhProfil-cd    as handle  no-undo.
    define buffer actrcln for actrcln.

    create query vhttquery.
    vhttBuffer = ghttActrcln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttActrcln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCptdeb, output vhSscptdeb, output vhProfil-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first actrcln exclusive-lock
                where rowid(actrcln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer actrcln:handle, 'cptdeb/sscptdeb/profil-cd: ', substitute('&1/&2/&3', vhCptdeb:buffer-value(), vhSscptdeb:buffer-value(), vhProfil-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer actrcln:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createActrcln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer actrcln for actrcln.

    create query vhttquery.
    vhttBuffer = ghttActrcln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttActrcln:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create actrcln.
            if not outils:copyValidField(buffer actrcln:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteActrcln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCptdeb    as handle  no-undo.
    define variable vhSscptdeb    as handle  no-undo.
    define variable vhProfil-cd    as handle  no-undo.
    define buffer actrcln for actrcln.

    create query vhttquery.
    vhttBuffer = ghttActrcln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttActrcln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCptdeb, output vhSscptdeb, output vhProfil-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first actrcln exclusive-lock
                where rowid(Actrcln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer actrcln:handle, 'cptdeb/sscptdeb/profil-cd: ', substitute('&1/&2/&3', vhCptdeb:buffer-value(), vhSscptdeb:buffer-value(), vhProfil-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete actrcln no-error.
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

