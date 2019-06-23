/*------------------------------------------------------------------------
File        : mpcpt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table mpcpt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/mpcpt.i}
{application/include/error.i}
define variable ghttmpcpt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNtbai as handle, output phCdper as handle, output phCdter as handle, output phNorub as handle, output phNolib as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur ntbai/cdper/cdter/norub/nolib, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'ntbai' then phNtbai = phBuffer:buffer-field(vi).
            when 'cdper' then phCdper = phBuffer:buffer-field(vi).
            when 'cdter' then phCdter = phBuffer:buffer-field(vi).
            when 'norub' then phNorub = phBuffer:buffer-field(vi).
            when 'nolib' then phNolib = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudMpcpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteMpcpt.
    run updateMpcpt.
    run createMpcpt.
end procedure.

procedure setMpcpt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttMpcpt.
    ghttMpcpt = phttMpcpt.
    run crudMpcpt.
    delete object phttMpcpt.
end procedure.

procedure readMpcpt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table mpcpt 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcNtbai as character  no-undo.
    define input parameter pcCdper as character  no-undo.
    define input parameter pcCdter as character  no-undo.
    define input parameter piNorub as integer    no-undo.
    define input parameter piNolib as integer    no-undo.
    define input parameter table-handle phttMpcpt.
    define variable vhttBuffer as handle no-undo.
    define buffer mpcpt for mpcpt.

    vhttBuffer = phttMpcpt:default-buffer-handle.
    for first mpcpt no-lock
        where mpcpt.ntbai = pcNtbai
          and mpcpt.cdper = pcCdper
          and mpcpt.cdter = pcCdter
          and mpcpt.norub = piNorub
          and mpcpt.nolib = piNolib:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer mpcpt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMpcpt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getMpcpt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table mpcpt 
    Notes  : service externe. Critère piNorub = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcNtbai as character  no-undo.
    define input parameter pcCdper as character  no-undo.
    define input parameter pcCdter as character  no-undo.
    define input parameter piNorub as integer    no-undo.
    define input parameter table-handle phttMpcpt.
    define variable vhttBuffer as handle  no-undo.
    define buffer mpcpt for mpcpt.

    vhttBuffer = phttMpcpt:default-buffer-handle.
    if piNorub = ?
    then for each mpcpt no-lock
        where mpcpt.ntbai = pcNtbai
          and mpcpt.cdper = pcCdper
          and mpcpt.cdter = pcCdter:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer mpcpt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each mpcpt no-lock
        where mpcpt.ntbai = pcNtbai
          and mpcpt.cdper = pcCdper
          and mpcpt.cdter = pcCdter
          and mpcpt.norub = piNorub:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer mpcpt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMpcpt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateMpcpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNtbai    as handle  no-undo.
    define variable vhCdper    as handle  no-undo.
    define variable vhCdter    as handle  no-undo.
    define variable vhNorub    as handle  no-undo.
    define variable vhNolib    as handle  no-undo.
    define buffer mpcpt for mpcpt.

    create query vhttquery.
    vhttBuffer = ghttMpcpt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttMpcpt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNtbai, output vhCdper, output vhCdter, output vhNorub, output vhNolib).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first mpcpt exclusive-lock
                where rowid(mpcpt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer mpcpt:handle, 'ntbai/cdper/cdter/norub/nolib: ', substitute('&1/&2/&3/&4/&5', vhNtbai:buffer-value(), vhCdper:buffer-value(), vhCdter:buffer-value(), vhNorub:buffer-value(), vhNolib:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer mpcpt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createMpcpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer mpcpt for mpcpt.

    create query vhttquery.
    vhttBuffer = ghttMpcpt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttMpcpt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create mpcpt.
            if not outils:copyValidField(buffer mpcpt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteMpcpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNtbai    as handle  no-undo.
    define variable vhCdper    as handle  no-undo.
    define variable vhCdter    as handle  no-undo.
    define variable vhNorub    as handle  no-undo.
    define variable vhNolib    as handle  no-undo.
    define buffer mpcpt for mpcpt.

    create query vhttquery.
    vhttBuffer = ghttMpcpt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttMpcpt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNtbai, output vhCdper, output vhCdter, output vhNorub, output vhNolib).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first mpcpt exclusive-lock
                where rowid(Mpcpt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer mpcpt:handle, 'ntbai/cdper/cdter/norub/nolib: ', substitute('&1/&2/&3/&4/&5', vhNtbai:buffer-value(), vhCdper:buffer-value(), vhCdter:buffer-value(), vhNorub:buffer-value(), vhNolib:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete mpcpt no-error.
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

