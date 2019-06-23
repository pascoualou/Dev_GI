/*------------------------------------------------------------------------
File        : litie_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table litie
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/litie.i}
{application/include/error.i}
define variable ghttlitie as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNotie as handle, output phNoind as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur notie/noind, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'notie' then phNotie = phBuffer:buffer-field(vi).
            when 'noind' then phNoind = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudLitie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteLitie.
    run updateLitie.
    run createLitie.
end procedure.

procedure setLitie:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttLitie.
    ghttLitie = phttLitie.
    run crudLitie.
    delete object phttLitie.
end procedure.

procedure readLitie:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table litie 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNotie as int64      no-undo.
    define input parameter piNoind as int64      no-undo.
    define input parameter table-handle phttLitie.
    define variable vhttBuffer as handle no-undo.
    define buffer litie for litie.

    vhttBuffer = phttLitie:default-buffer-handle.
    for first litie no-lock
        where litie.notie = piNotie
          and litie.noind = piNoind:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer litie:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLitie no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getLitie:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table litie 
    Notes  : service externe. Critère piNotie = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNotie as int64      no-undo.
    define input parameter table-handle phttLitie.
    define variable vhttBuffer as handle  no-undo.
    define buffer litie for litie.

    vhttBuffer = phttLitie:default-buffer-handle.
    if piNotie = ?
    then for each litie no-lock
        where litie.notie = piNotie:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer litie:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each litie no-lock
        where litie.notie = piNotie:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer litie:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLitie no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateLitie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNotie    as handle  no-undo.
    define variable vhNoind    as handle  no-undo.
    define buffer litie for litie.

    create query vhttquery.
    vhttBuffer = ghttLitie:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttLitie:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNotie, output vhNoind).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first litie exclusive-lock
                where rowid(litie) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer litie:handle, 'notie/noind: ', substitute('&1/&2', vhNotie:buffer-value(), vhNoind:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer litie:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createLitie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer litie for litie.

    create query vhttquery.
    vhttBuffer = ghttLitie:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttLitie:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create litie.
            if not outils:copyValidField(buffer litie:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteLitie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNotie    as handle  no-undo.
    define variable vhNoind    as handle  no-undo.
    define buffer litie for litie.

    create query vhttquery.
    vhttBuffer = ghttLitie:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttLitie:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNotie, output vhNoind).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first litie exclusive-lock
                where rowid(Litie) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer litie:handle, 'notie/noind: ', substitute('&1/&2', vhNotie:buffer-value(), vhNoind:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete litie no-error.
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

