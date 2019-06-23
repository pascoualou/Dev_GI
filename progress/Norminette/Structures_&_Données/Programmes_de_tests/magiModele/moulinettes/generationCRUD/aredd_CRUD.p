/*------------------------------------------------------------------------
File        : aredd_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table aredd
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/aredd.i}
{application/include/error.i}
define variable ghttaredd as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNored as handle, output phNomdt as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nored/nomdt, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nored' then phNored = phBuffer:buffer-field(vi).
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAredd private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAredd.
    run updateAredd.
    run createAredd.
end procedure.

procedure setAredd:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAredd.
    ghttAredd = phttAredd.
    run crudAredd.
    delete object phttAredd.
end procedure.

procedure readAredd:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table aredd déclarations antérieures
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNored as integer    no-undo.
    define input parameter piNomdt as integer    no-undo.
    define input parameter table-handle phttAredd.
    define variable vhttBuffer as handle no-undo.
    define buffer aredd for aredd.

    vhttBuffer = phttAredd:default-buffer-handle.
    for first aredd no-lock
        where aredd.nored = piNored
          and aredd.nomdt = piNomdt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aredd:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAredd no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAredd:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table aredd déclarations antérieures
    Notes  : service externe. Critère piNored = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNored as integer    no-undo.
    define input parameter table-handle phttAredd.
    define variable vhttBuffer as handle  no-undo.
    define buffer aredd for aredd.

    vhttBuffer = phttAredd:default-buffer-handle.
    if piNored = ?
    then for each aredd no-lock
        where aredd.nored = piNored:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aredd:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each aredd no-lock
        where aredd.nored = piNored:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aredd:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAredd no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAredd private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNored    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define buffer aredd for aredd.

    create query vhttquery.
    vhttBuffer = ghttAredd:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAredd:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNored, output vhNomdt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aredd exclusive-lock
                where rowid(aredd) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aredd:handle, 'nored/nomdt: ', substitute('&1/&2', vhNored:buffer-value(), vhNomdt:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer aredd:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAredd private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer aredd for aredd.

    create query vhttquery.
    vhttBuffer = ghttAredd:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAredd:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create aredd.
            if not outils:copyValidField(buffer aredd:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAredd private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNored    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define buffer aredd for aredd.

    create query vhttquery.
    vhttBuffer = ghttAredd:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAredd:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNored, output vhNomdt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aredd exclusive-lock
                where rowid(Aredd) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aredd:handle, 'nored/nomdt: ', substitute('&1/&2', vhNored:buffer-value(), vhNomdt:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete aredd no-error.
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

