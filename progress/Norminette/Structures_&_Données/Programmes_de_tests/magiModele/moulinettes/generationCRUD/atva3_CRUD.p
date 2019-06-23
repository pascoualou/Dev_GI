/*------------------------------------------------------------------------
File        : atva3_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table atva3
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/atva3.i}
{application/include/error.i}
define variable ghttatva3 as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNomdt as handle, output phNolig as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nomdt/nolig, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
            when 'nolig' then phNolig = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAtva3 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAtva3.
    run updateAtva3.
    run createAtva3.
end procedure.

procedure setAtva3:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAtva3.
    ghttAtva3 = phttAtva3.
    run crudAtva3.
    delete object phttAtva3.
end procedure.

procedure readAtva3:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table atva3 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNolig as integer    no-undo.
    define input parameter table-handle phttAtva3.
    define variable vhttBuffer as handle no-undo.
    define buffer atva3 for atva3.

    vhttBuffer = phttAtva3:default-buffer-handle.
    for first atva3 no-lock
        where atva3.nomdt = piNomdt
          and atva3.nolig = piNolig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer atva3:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAtva3 no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAtva3:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table atva3 
    Notes  : service externe. Critère piNomdt = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNomdt as integer    no-undo.
    define input parameter table-handle phttAtva3.
    define variable vhttBuffer as handle  no-undo.
    define buffer atva3 for atva3.

    vhttBuffer = phttAtva3:default-buffer-handle.
    if piNomdt = ?
    then for each atva3 no-lock
        where atva3.nomdt = piNomdt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer atva3:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each atva3 no-lock
        where atva3.nomdt = piNomdt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer atva3:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAtva3 no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAtva3 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNolig    as handle  no-undo.
    define buffer atva3 for atva3.

    create query vhttquery.
    vhttBuffer = ghttAtva3:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAtva3:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt, output vhNolig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first atva3 exclusive-lock
                where rowid(atva3) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer atva3:handle, 'nomdt/nolig: ', substitute('&1/&2', vhNomdt:buffer-value(), vhNolig:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer atva3:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAtva3 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer atva3 for atva3.

    create query vhttquery.
    vhttBuffer = ghttAtva3:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAtva3:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create atva3.
            if not outils:copyValidField(buffer atva3:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAtva3 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNolig    as handle  no-undo.
    define buffer atva3 for atva3.

    create query vhttquery.
    vhttBuffer = ghttAtva3:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAtva3:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt, output vhNolig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first atva3 exclusive-lock
                where rowid(Atva3) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer atva3:handle, 'nomdt/nolig: ', substitute('&1/&2', vhNomdt:buffer-value(), vhNolig:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete atva3 no-error.
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

