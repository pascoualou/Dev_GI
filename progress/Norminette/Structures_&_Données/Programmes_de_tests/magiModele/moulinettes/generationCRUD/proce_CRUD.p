/*------------------------------------------------------------------------
File        : proce_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table proce
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/proce.i}
{application/include/error.i}
define variable ghttproce as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNorol as handle, output phLbpro as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur norol/lbpro, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'norol' then phNorol = phBuffer:buffer-field(vi).
            when 'lbpro' then phLbpro = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudProce private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteProce.
    run updateProce.
    run createProce.
end procedure.

procedure setProce:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttProce.
    ghttProce = phttProce.
    run crudProce.
    delete object phttProce.
end procedure.

procedure readProce:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table proce 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNorol as integer    no-undo.
    define input parameter pcLbpro as character  no-undo.
    define input parameter table-handle phttProce.
    define variable vhttBuffer as handle no-undo.
    define buffer proce for proce.

    vhttBuffer = phttProce:default-buffer-handle.
    for first proce no-lock
        where proce.norol = piNorol
          and proce.lbpro = pcLbpro:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer proce:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttProce no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getProce:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table proce 
    Notes  : service externe. Critère piNorol = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNorol as integer    no-undo.
    define input parameter table-handle phttProce.
    define variable vhttBuffer as handle  no-undo.
    define buffer proce for proce.

    vhttBuffer = phttProce:default-buffer-handle.
    if piNorol = ?
    then for each proce no-lock
        where proce.norol = piNorol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer proce:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each proce no-lock
        where proce.norol = piNorol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer proce:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttProce no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateProce private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhLbpro    as handle  no-undo.
    define buffer proce for proce.

    create query vhttquery.
    vhttBuffer = ghttProce:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttProce:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNorol, output vhLbpro).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first proce exclusive-lock
                where rowid(proce) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer proce:handle, 'norol/lbpro: ', substitute('&1/&2', vhNorol:buffer-value(), vhLbpro:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer proce:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createProce private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer proce for proce.

    create query vhttquery.
    vhttBuffer = ghttProce:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttProce:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create proce.
            if not outils:copyValidField(buffer proce:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteProce private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhLbpro    as handle  no-undo.
    define buffer proce for proce.

    create query vhttquery.
    vhttBuffer = ghttProce:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttProce:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNorol, output vhLbpro).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first proce exclusive-lock
                where rowid(Proce) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer proce:handle, 'norol/lbpro: ', substitute('&1/&2', vhNorol:buffer-value(), vhLbpro:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete proce no-error.
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

