/*------------------------------------------------------------------------
File        : restrien_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table restrien
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/restrien.i}
{application/include/error.i}
define variable ghttrestrien as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phNoord as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcon/nocon/noord, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'noord' then phNoord = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudRestrien private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteRestrien.
    run updateRestrien.
    run createRestrien.
end procedure.

procedure setRestrien:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRestrien.
    ghttRestrien = phttRestrien.
    run crudRestrien.
    delete object phttRestrien.
end procedure.

procedure readRestrien:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table restrien 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as int64      no-undo.
    define input parameter piNoord as integer    no-undo.
    define input parameter table-handle phttRestrien.
    define variable vhttBuffer as handle no-undo.
    define buffer restrien for restrien.

    vhttBuffer = phttRestrien:default-buffer-handle.
    for first restrien no-lock
        where restrien.tpcon = pcTpcon
          and restrien.nocon = piNocon
          and restrien.noord = piNoord:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer restrien:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRestrien no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getRestrien:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table restrien 
    Notes  : service externe. Critère piNocon = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as int64      no-undo.
    define input parameter table-handle phttRestrien.
    define variable vhttBuffer as handle  no-undo.
    define buffer restrien for restrien.

    vhttBuffer = phttRestrien:default-buffer-handle.
    if piNocon = ?
    then for each restrien no-lock
        where restrien.tpcon = pcTpcon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer restrien:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each restrien no-lock
        where restrien.tpcon = pcTpcon
          and restrien.nocon = piNocon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer restrien:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRestrien no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateRestrien private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer restrien for restrien.

    create query vhttquery.
    vhttBuffer = ghttRestrien:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttRestrien:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first restrien exclusive-lock
                where rowid(restrien) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer restrien:handle, 'tpcon/nocon/noord: ', substitute('&1/&2/&3', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer restrien:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createRestrien private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer restrien for restrien.

    create query vhttquery.
    vhttBuffer = ghttRestrien:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttRestrien:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create restrien.
            if not outils:copyValidField(buffer restrien:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteRestrien private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer restrien for restrien.

    create query vhttquery.
    vhttBuffer = ghttRestrien:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttRestrien:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first restrien exclusive-lock
                where rowid(Restrien) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer restrien:handle, 'tpcon/nocon/noord: ', substitute('&1/&2/&3', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete restrien no-error.
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

