/*------------------------------------------------------------------------
File        : atva2_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table atva2
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/atva2.i}
{application/include/error.i}
define variable ghttatva2 as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNomdt as handle, output phNolig as handle, output phNorub as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nomdt/nolig/norub, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
            when 'nolig' then phNolig = phBuffer:buffer-field(vi).
            when 'norub' then phNorub = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAtva2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAtva2.
    run updateAtva2.
    run createAtva2.
end procedure.

procedure setAtva2:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAtva2.
    ghttAtva2 = phttAtva2.
    run crudAtva2.
    delete object phttAtva2.
end procedure.

procedure readAtva2:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table atva2 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNolig as integer    no-undo.
    define input parameter piNorub as integer    no-undo.
    define input parameter table-handle phttAtva2.
    define variable vhttBuffer as handle no-undo.
    define buffer atva2 for atva2.

    vhttBuffer = phttAtva2:default-buffer-handle.
    for first atva2 no-lock
        where atva2.nomdt = piNomdt
          and atva2.nolig = piNolig
          and atva2.norub = piNorub:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer atva2:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAtva2 no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAtva2:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table atva2 
    Notes  : service externe. Critère piNolig = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNolig as integer    no-undo.
    define input parameter table-handle phttAtva2.
    define variable vhttBuffer as handle  no-undo.
    define buffer atva2 for atva2.

    vhttBuffer = phttAtva2:default-buffer-handle.
    if piNolig = ?
    then for each atva2 no-lock
        where atva2.nomdt = piNomdt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer atva2:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each atva2 no-lock
        where atva2.nomdt = piNomdt
          and atva2.nolig = piNolig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer atva2:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAtva2 no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAtva2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNolig    as handle  no-undo.
    define variable vhNorub    as handle  no-undo.
    define buffer atva2 for atva2.

    create query vhttquery.
    vhttBuffer = ghttAtva2:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAtva2:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt, output vhNolig, output vhNorub).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first atva2 exclusive-lock
                where rowid(atva2) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer atva2:handle, 'nomdt/nolig/norub: ', substitute('&1/&2/&3', vhNomdt:buffer-value(), vhNolig:buffer-value(), vhNorub:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer atva2:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAtva2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer atva2 for atva2.

    create query vhttquery.
    vhttBuffer = ghttAtva2:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAtva2:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create atva2.
            if not outils:copyValidField(buffer atva2:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAtva2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNolig    as handle  no-undo.
    define variable vhNorub    as handle  no-undo.
    define buffer atva2 for atva2.

    create query vhttquery.
    vhttBuffer = ghttAtva2:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAtva2:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt, output vhNolig, output vhNorub).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first atva2 exclusive-lock
                where rowid(Atva2) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer atva2:handle, 'nomdt/nolig/norub: ', substitute('&1/&2/&3', vhNomdt:buffer-value(), vhNolig:buffer-value(), vhNorub:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete atva2 no-error.
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

