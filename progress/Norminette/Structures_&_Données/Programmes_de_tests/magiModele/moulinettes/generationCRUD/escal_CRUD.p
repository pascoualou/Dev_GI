/*------------------------------------------------------------------------
File        : escal_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table escal
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/escal.i}
{application/include/error.i}
define variable ghttescal as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNobat as handle, output phCdesc as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nobat/cdesc, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nobat' then phNobat = phBuffer:buffer-field(vi).
            when 'cdesc' then phCdesc = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudEscal private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteEscal.
    run updateEscal.
    run createEscal.
end procedure.

procedure setEscal:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEscal.
    ghttEscal = phttEscal.
    run crudEscal.
    delete object phttEscal.
end procedure.

procedure readEscal:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table escal 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNobat as integer    no-undo.
    define input parameter pcCdesc as character  no-undo.
    define input parameter table-handle phttEscal.
    define variable vhttBuffer as handle no-undo.
    define buffer escal for escal.

    vhttBuffer = phttEscal:default-buffer-handle.
    for first escal no-lock
        where escal.nobat = piNobat
          and escal.cdesc = pcCdesc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer escal:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEscal no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getEscal:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table escal 
    Notes  : service externe. Critère piNobat = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNobat as integer    no-undo.
    define input parameter table-handle phttEscal.
    define variable vhttBuffer as handle  no-undo.
    define buffer escal for escal.

    vhttBuffer = phttEscal:default-buffer-handle.
    if piNobat = ?
    then for each escal no-lock
        where escal.nobat = piNobat:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer escal:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each escal no-lock
        where escal.nobat = piNobat:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer escal:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEscal no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateEscal private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNobat    as handle  no-undo.
    define variable vhCdesc    as handle  no-undo.
    define buffer escal for escal.

    create query vhttquery.
    vhttBuffer = ghttEscal:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttEscal:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNobat, output vhCdesc).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first escal exclusive-lock
                where rowid(escal) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer escal:handle, 'nobat/cdesc: ', substitute('&1/&2', vhNobat:buffer-value(), vhCdesc:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer escal:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createEscal private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer escal for escal.

    create query vhttquery.
    vhttBuffer = ghttEscal:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttEscal:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create escal.
            if not outils:copyValidField(buffer escal:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteEscal private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNobat    as handle  no-undo.
    define variable vhCdesc    as handle  no-undo.
    define buffer escal for escal.

    create query vhttquery.
    vhttBuffer = ghttEscal:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttEscal:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNobat, output vhCdesc).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first escal exclusive-lock
                where rowid(Escal) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer escal:handle, 'nobat/cdesc: ', substitute('&1/&2', vhNobat:buffer-value(), vhCdesc:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete escal no-error.
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

