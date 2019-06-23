/*------------------------------------------------------------------------
File        : usagelot_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table usagelot
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/usagelot.i}
{application/include/error.i}
define variable ghttusagelot as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNtlot as handle, output phCdusa as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur ntlot/cdusa, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'ntlot' then phNtlot = phBuffer:buffer-field(vi).
            when 'cdusa' then phCdusa = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudUsagelot private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteUsagelot.
    run updateUsagelot.
    run createUsagelot.
end procedure.

procedure setUsagelot:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttUsagelot.
    ghttUsagelot = phttUsagelot.
    run crudUsagelot.
    delete object phttUsagelot.
end procedure.

procedure readUsagelot:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table usagelot Usage des lots
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcNtlot as character  no-undo.
    define input parameter pcCdusa as character  no-undo.
    define input parameter table-handle phttUsagelot.
    define variable vhttBuffer as handle no-undo.
    define buffer usagelot for usagelot.

    vhttBuffer = phttUsagelot:default-buffer-handle.
    for first usagelot no-lock
        where usagelot.ntlot = pcNtlot
          and usagelot.cdusa = pcCdusa:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer usagelot:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttUsagelot no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getUsagelot:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table usagelot Usage des lots
    Notes  : service externe. Critère pcNtlot = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcNtlot as character  no-undo.
    define input parameter table-handle phttUsagelot.
    define variable vhttBuffer as handle  no-undo.
    define buffer usagelot for usagelot.

    vhttBuffer = phttUsagelot:default-buffer-handle.
    if pcNtlot = ?
    then for each usagelot no-lock
        where usagelot.ntlot = pcNtlot:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer usagelot:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each usagelot no-lock
        where usagelot.ntlot = pcNtlot:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer usagelot:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttUsagelot no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateUsagelot private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNtlot    as handle  no-undo.
    define variable vhCdusa    as handle  no-undo.
    define buffer usagelot for usagelot.

    create query vhttquery.
    vhttBuffer = ghttUsagelot:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttUsagelot:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNtlot, output vhCdusa).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first usagelot exclusive-lock
                where rowid(usagelot) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer usagelot:handle, 'ntlot/cdusa: ', substitute('&1/&2', vhNtlot:buffer-value(), vhCdusa:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer usagelot:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createUsagelot private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer usagelot for usagelot.

    create query vhttquery.
    vhttBuffer = ghttUsagelot:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttUsagelot:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create usagelot.
            if not outils:copyValidField(buffer usagelot:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteUsagelot private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNtlot    as handle  no-undo.
    define variable vhCdusa    as handle  no-undo.
    define buffer usagelot for usagelot.

    create query vhttquery.
    vhttBuffer = ghttUsagelot:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttUsagelot:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNtlot, output vhCdusa).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first usagelot exclusive-lock
                where rowid(Usagelot) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer usagelot:handle, 'ntlot/cdusa: ', substitute('&1/&2', vhNtlot:buffer-value(), vhCdusa:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete usagelot no-error.
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

