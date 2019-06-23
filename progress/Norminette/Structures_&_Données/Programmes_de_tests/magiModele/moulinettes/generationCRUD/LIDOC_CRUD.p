/*------------------------------------------------------------------------
File        : LIDOC_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table LIDOC
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/LIDOC.i}
{application/include/error.i}
define variable ghttLIDOC as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpidt as handle, output phNoidt as handle, output phNossd as handle, output phNodoc as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpidt/noidt/nossd/nodoc, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpidt' then phTpidt = phBuffer:buffer-field(vi).
            when 'noidt' then phNoidt = phBuffer:buffer-field(vi).
            when 'nossd' then phNossd = phBuffer:buffer-field(vi).
            when 'nodoc' then phNodoc = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudLidoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteLidoc.
    run updateLidoc.
    run createLidoc.
end procedure.

procedure setLidoc:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttLidoc.
    ghttLidoc = phttLidoc.
    run crudLidoc.
    delete object phttLidoc.
end procedure.

procedure readLidoc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table LIDOC Lien document & sous-dossier
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpidt as character  no-undo.
    define input parameter piNoidt as int64      no-undo.
    define input parameter piNossd as integer    no-undo.
    define input parameter piNodoc as int64      no-undo.
    define input parameter table-handle phttLidoc.
    define variable vhttBuffer as handle no-undo.
    define buffer LIDOC for LIDOC.

    vhttBuffer = phttLidoc:default-buffer-handle.
    for first LIDOC no-lock
        where LIDOC.tpidt = pcTpidt
          and LIDOC.noidt = piNoidt
          and LIDOC.nossd = piNossd
          and LIDOC.nodoc = piNodoc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer LIDOC:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLidoc no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getLidoc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table LIDOC Lien document & sous-dossier
    Notes  : service externe. Critère piNossd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpidt as character  no-undo.
    define input parameter piNoidt as int64      no-undo.
    define input parameter piNossd as integer    no-undo.
    define input parameter table-handle phttLidoc.
    define variable vhttBuffer as handle  no-undo.
    define buffer LIDOC for LIDOC.

    vhttBuffer = phttLidoc:default-buffer-handle.
    if piNossd = ?
    then for each LIDOC no-lock
        where LIDOC.tpidt = pcTpidt
          and LIDOC.noidt = piNoidt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer LIDOC:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each LIDOC no-lock
        where LIDOC.tpidt = pcTpidt
          and LIDOC.noidt = piNoidt
          and LIDOC.nossd = piNossd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer LIDOC:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLidoc no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateLidoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define variable vhNossd    as handle  no-undo.
    define variable vhNodoc    as handle  no-undo.
    define buffer LIDOC for LIDOC.

    create query vhttquery.
    vhttBuffer = ghttLidoc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttLidoc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpidt, output vhNoidt, output vhNossd, output vhNodoc).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first LIDOC exclusive-lock
                where rowid(LIDOC) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer LIDOC:handle, 'tpidt/noidt/nossd/nodoc: ', substitute('&1/&2/&3/&4', vhTpidt:buffer-value(), vhNoidt:buffer-value(), vhNossd:buffer-value(), vhNodoc:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer LIDOC:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createLidoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer LIDOC for LIDOC.

    create query vhttquery.
    vhttBuffer = ghttLidoc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttLidoc:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create LIDOC.
            if not outils:copyValidField(buffer LIDOC:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteLidoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define variable vhNossd    as handle  no-undo.
    define variable vhNodoc    as handle  no-undo.
    define buffer LIDOC for LIDOC.

    create query vhttquery.
    vhttBuffer = ghttLidoc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttLidoc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpidt, output vhNoidt, output vhNossd, output vhNodoc).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first LIDOC exclusive-lock
                where rowid(Lidoc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer LIDOC:handle, 'tpidt/noidt/nossd/nodoc: ', substitute('&1/&2/&3/&4', vhTpidt:buffer-value(), vhNoidt:buffer-value(), vhNossd:buffer-value(), vhNodoc:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete LIDOC no-error.
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

