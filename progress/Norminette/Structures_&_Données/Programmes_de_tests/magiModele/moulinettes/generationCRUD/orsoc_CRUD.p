/*------------------------------------------------------------------------
File        : orsoc_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table orsoc
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/orsoc.i}
{application/include/error.i}
define variable ghttorsoc as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTporg as handle, output phIdent as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur TpOrg/ident, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'TpOrg' then phTporg = phBuffer:buffer-field(vi).
            when 'ident' then phIdent = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudOrsoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteOrsoc.
    run updateOrsoc.
    run createOrsoc.
end procedure.

procedure setOrsoc:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttOrsoc.
    ghttOrsoc = phttOrsoc.
    run crudOrsoc.
    delete object phttOrsoc.
end procedure.

procedure readOrsoc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table orsoc Organismes Sociaux (URSSAF,...)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTporg as character  no-undo.
    define input parameter pcIdent as character  no-undo.
    define input parameter table-handle phttOrsoc.
    define variable vhttBuffer as handle no-undo.
    define buffer orsoc for orsoc.

    vhttBuffer = phttOrsoc:default-buffer-handle.
    for first orsoc no-lock
        where orsoc.TpOrg = pcTporg
          and orsoc.ident = pcIdent:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer orsoc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttOrsoc no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getOrsoc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table orsoc Organismes Sociaux (URSSAF,...)
    Notes  : service externe. Critère pcTporg = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTporg as character  no-undo.
    define input parameter table-handle phttOrsoc.
    define variable vhttBuffer as handle  no-undo.
    define buffer orsoc for orsoc.

    vhttBuffer = phttOrsoc:default-buffer-handle.
    if pcTporg = ?
    then for each orsoc no-lock
        where orsoc.TpOrg = pcTporg:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer orsoc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each orsoc no-lock
        where orsoc.TpOrg = pcTporg:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer orsoc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttOrsoc no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateOrsoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTporg    as handle  no-undo.
    define variable vhIdent    as handle  no-undo.
    define buffer orsoc for orsoc.

    create query vhttquery.
    vhttBuffer = ghttOrsoc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttOrsoc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTporg, output vhIdent).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first orsoc exclusive-lock
                where rowid(orsoc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer orsoc:handle, 'TpOrg/ident: ', substitute('&1/&2', vhTporg:buffer-value(), vhIdent:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer orsoc:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createOrsoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer orsoc for orsoc.

    create query vhttquery.
    vhttBuffer = ghttOrsoc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttOrsoc:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create orsoc.
            if not outils:copyValidField(buffer orsoc:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteOrsoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTporg    as handle  no-undo.
    define variable vhIdent    as handle  no-undo.
    define buffer orsoc for orsoc.

    create query vhttquery.
    vhttBuffer = ghttOrsoc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttOrsoc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTporg, output vhIdent).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first orsoc exclusive-lock
                where rowid(Orsoc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer orsoc:handle, 'TpOrg/ident: ', substitute('&1/&2', vhTporg:buffer-value(), vhIdent:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete orsoc no-error.
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

