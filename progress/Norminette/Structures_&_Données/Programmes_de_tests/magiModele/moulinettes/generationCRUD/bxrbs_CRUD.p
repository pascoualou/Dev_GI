/*------------------------------------------------------------------------
File        : bxrbs_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table bxrbs
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/bxrbs.i}
{application/include/error.i}
define variable ghttbxrbs as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNtbai as handle, output phCdfam as handle, output phNorub as handle, output phNoord as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur ntbai/cdfam/norub/noord, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'ntbai' then phNtbai = phBuffer:buffer-field(vi).
            when 'cdfam' then phCdfam = phBuffer:buffer-field(vi).
            when 'norub' then phNorub = phBuffer:buffer-field(vi).
            when 'noord' then phNoord = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudBxrbs private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteBxrbs.
    run updateBxrbs.
    run createBxrbs.
end procedure.

procedure setBxrbs:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttBxrbs.
    ghttBxrbs = phttBxrbs.
    run crudBxrbs.
    delete object phttBxrbs.
end procedure.

procedure readBxrbs:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table bxrbs 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcNtbai as character  no-undo.
    define input parameter piCdfam as integer    no-undo.
    define input parameter piNorub as integer    no-undo.
    define input parameter piNoord as integer    no-undo.
    define input parameter table-handle phttBxrbs.
    define variable vhttBuffer as handle no-undo.
    define buffer bxrbs for bxrbs.

    vhttBuffer = phttBxrbs:default-buffer-handle.
    for first bxrbs no-lock
        where bxrbs.ntbai = pcNtbai
          and bxrbs.cdfam = piCdfam
          and bxrbs.norub = piNorub
          and bxrbs.noord = piNoord:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer bxrbs:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttBxrbs no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getBxrbs:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table bxrbs 
    Notes  : service externe. Critère piNorub = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcNtbai as character  no-undo.
    define input parameter piCdfam as integer    no-undo.
    define input parameter piNorub as integer    no-undo.
    define input parameter table-handle phttBxrbs.
    define variable vhttBuffer as handle  no-undo.
    define buffer bxrbs for bxrbs.

    vhttBuffer = phttBxrbs:default-buffer-handle.
    if piNorub = ?
    then for each bxrbs no-lock
        where bxrbs.ntbai = pcNtbai
          and bxrbs.cdfam = piCdfam:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer bxrbs:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each bxrbs no-lock
        where bxrbs.ntbai = pcNtbai
          and bxrbs.cdfam = piCdfam
          and bxrbs.norub = piNorub:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer bxrbs:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttBxrbs no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateBxrbs private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNtbai    as handle  no-undo.
    define variable vhCdfam    as handle  no-undo.
    define variable vhNorub    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer bxrbs for bxrbs.

    create query vhttquery.
    vhttBuffer = ghttBxrbs:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttBxrbs:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNtbai, output vhCdfam, output vhNorub, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first bxrbs exclusive-lock
                where rowid(bxrbs) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer bxrbs:handle, 'ntbai/cdfam/norub/noord: ', substitute('&1/&2/&3/&4', vhNtbai:buffer-value(), vhCdfam:buffer-value(), vhNorub:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer bxrbs:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createBxrbs private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer bxrbs for bxrbs.

    create query vhttquery.
    vhttBuffer = ghttBxrbs:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttBxrbs:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create bxrbs.
            if not outils:copyValidField(buffer bxrbs:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteBxrbs private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNtbai    as handle  no-undo.
    define variable vhCdfam    as handle  no-undo.
    define variable vhNorub    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer bxrbs for bxrbs.

    create query vhttquery.
    vhttBuffer = ghttBxrbs:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttBxrbs:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNtbai, output vhCdfam, output vhNorub, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first bxrbs exclusive-lock
                where rowid(Bxrbs) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer bxrbs:handle, 'ntbai/cdfam/norub/noord: ', substitute('&1/&2/&3/&4', vhNtbai:buffer-value(), vhCdfam:buffer-value(), vhNorub:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete bxrbs no-error.
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

