/*------------------------------------------------------------------------
File        : ifptprgt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifptprgt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifptprgt.i}
{application/include/error.i}
define variable ghttifptprgt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTypergt-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur typergt-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'typergt-cd' then phTypergt-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfptprgt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfptprgt.
    run updateIfptprgt.
    run createIfptprgt.
end procedure.

procedure setIfptprgt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfptprgt.
    ghttIfptprgt = phttIfptprgt.
    run crudIfptprgt.
    delete object phttIfptprgt.
end procedure.

procedure readIfptprgt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifptprgt Table des types de regroupement
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piTypergt-cd as integer    no-undo.
    define input parameter table-handle phttIfptprgt.
    define variable vhttBuffer as handle no-undo.
    define buffer ifptprgt for ifptprgt.

    vhttBuffer = phttIfptprgt:default-buffer-handle.
    for first ifptprgt no-lock
        where ifptprgt.typergt-cd = piTypergt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifptprgt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfptprgt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfptprgt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifptprgt Table des types de regroupement
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfptprgt.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifptprgt for ifptprgt.

    vhttBuffer = phttIfptprgt:default-buffer-handle.
    for each ifptprgt no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifptprgt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfptprgt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfptprgt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTypergt-cd    as handle  no-undo.
    define buffer ifptprgt for ifptprgt.

    create query vhttquery.
    vhttBuffer = ghttIfptprgt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfptprgt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTypergt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifptprgt exclusive-lock
                where rowid(ifptprgt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifptprgt:handle, 'typergt-cd: ', substitute('&1', vhTypergt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifptprgt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfptprgt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifptprgt for ifptprgt.

    create query vhttquery.
    vhttBuffer = ghttIfptprgt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfptprgt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifptprgt.
            if not outils:copyValidField(buffer ifptprgt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfptprgt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTypergt-cd    as handle  no-undo.
    define buffer ifptprgt for ifptprgt.

    create query vhttquery.
    vhttBuffer = ghttIfptprgt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfptprgt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTypergt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifptprgt exclusive-lock
                where rowid(Ifptprgt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifptprgt:handle, 'typergt-cd: ', substitute('&1', vhTypergt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifptprgt no-error.
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

