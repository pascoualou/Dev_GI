/*------------------------------------------------------------------------
File        : actrc_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table actrc
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/actrc.i}
{application/include/error.i}
define variable ghttactrc as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCptdeb as handle, output phSscptdeb as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cptdeb/sscptdeb, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cptdeb' then phCptdeb = phBuffer:buffer-field(vi).
            when 'sscptdeb' then phSscptdeb = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudActrc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteActrc.
    run updateActrc.
    run createActrc.
end procedure.

procedure setActrc:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttActrc.
    ghttActrc = phttActrc.
    run crudActrc.
    delete object phttActrc.
end procedure.

procedure readActrc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table actrc 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCptdeb   as character  no-undo.
    define input parameter pcSscptdeb as character  no-undo.
    define input parameter table-handle phttActrc.
    define variable vhttBuffer as handle no-undo.
    define buffer actrc for actrc.

    vhttBuffer = phttActrc:default-buffer-handle.
    for first actrc no-lock
        where actrc.cptdeb = pcCptdeb
          and actrc.sscptdeb = pcSscptdeb:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer actrc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttActrc no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getActrc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table actrc 
    Notes  : service externe. Critère pcCptdeb = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCptdeb   as character  no-undo.
    define input parameter table-handle phttActrc.
    define variable vhttBuffer as handle  no-undo.
    define buffer actrc for actrc.

    vhttBuffer = phttActrc:default-buffer-handle.
    if pcCptdeb = ?
    then for each actrc no-lock
        where actrc.cptdeb = pcCptdeb:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer actrc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each actrc no-lock
        where actrc.cptdeb = pcCptdeb:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer actrc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttActrc no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateActrc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCptdeb    as handle  no-undo.
    define variable vhSscptdeb    as handle  no-undo.
    define buffer actrc for actrc.

    create query vhttquery.
    vhttBuffer = ghttActrc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttActrc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCptdeb, output vhSscptdeb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first actrc exclusive-lock
                where rowid(actrc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer actrc:handle, 'cptdeb/sscptdeb: ', substitute('&1/&2', vhCptdeb:buffer-value(), vhSscptdeb:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer actrc:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createActrc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer actrc for actrc.

    create query vhttquery.
    vhttBuffer = ghttActrc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttActrc:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create actrc.
            if not outils:copyValidField(buffer actrc:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteActrc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCptdeb    as handle  no-undo.
    define variable vhSscptdeb    as handle  no-undo.
    define buffer actrc for actrc.

    create query vhttquery.
    vhttBuffer = ghttActrc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttActrc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCptdeb, output vhSscptdeb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first actrc exclusive-lock
                where rowid(Actrc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer actrc:handle, 'cptdeb/sscptdeb: ', substitute('&1/&2', vhCptdeb:buffer-value(), vhSscptdeb:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete actrc no-error.
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

