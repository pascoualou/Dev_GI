/*------------------------------------------------------------------------
File        : entip_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table entip
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/entip.i}
{application/include/error.i}
define variable ghttentip as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNocon as handle, output phNoimm as handle, output phDtimp as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nocon/noimm/dtimp, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'noimm' then phNoimm = phBuffer:buffer-field(vi).
            when 'dtimp' then phDtimp = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudEntip private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteEntip.
    run updateEntip.
    run createEntip.
end procedure.

procedure setEntip:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEntip.
    ghttEntip = phttEntip.
    run crudEntip.
    delete object phttEntip.
end procedure.

procedure readEntip:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table entip 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNocon as int64      no-undo.
    define input parameter piNoimm as integer    no-undo.
    define input parameter pdaDtimp as date       no-undo.
    define input parameter table-handle phttEntip.
    define variable vhttBuffer as handle no-undo.
    define buffer entip for entip.

    vhttBuffer = phttEntip:default-buffer-handle.
    for first entip no-lock
        where entip.nocon = piNocon
          and entip.noimm = piNoimm
          and entip.dtimp = pdaDtimp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer entip:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEntip no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getEntip:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table entip 
    Notes  : service externe. Critère piNoimm = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNocon as int64      no-undo.
    define input parameter piNoimm as integer    no-undo.
    define input parameter table-handle phttEntip.
    define variable vhttBuffer as handle  no-undo.
    define buffer entip for entip.

    vhttBuffer = phttEntip:default-buffer-handle.
    if piNoimm = ?
    then for each entip no-lock
        where entip.nocon = piNocon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer entip:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each entip no-lock
        where entip.nocon = piNocon
          and entip.noimm = piNoimm:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer entip:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEntip no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateEntip private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhDtimp    as handle  no-undo.
    define buffer entip for entip.

    create query vhttquery.
    vhttBuffer = ghttEntip:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttEntip:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNocon, output vhNoimm, output vhDtimp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first entip exclusive-lock
                where rowid(entip) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer entip:handle, 'nocon/noimm/dtimp: ', substitute('&1/&2/&3', vhNocon:buffer-value(), vhNoimm:buffer-value(), vhDtimp:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer entip:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createEntip private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer entip for entip.

    create query vhttquery.
    vhttBuffer = ghttEntip:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttEntip:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create entip.
            if not outils:copyValidField(buffer entip:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteEntip private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhDtimp    as handle  no-undo.
    define buffer entip for entip.

    create query vhttquery.
    vhttBuffer = ghttEntip:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttEntip:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNocon, output vhNoimm, output vhDtimp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first entip exclusive-lock
                where rowid(Entip) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer entip:handle, 'nocon/noimm/dtimp: ', substitute('&1/&2/&3', vhNocon:buffer-value(), vhNoimm:buffer-value(), vhDtimp:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete entip no-error.
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

