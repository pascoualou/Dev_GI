/*------------------------------------------------------------------------
File        : Ifptpana_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table Ifptpana
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/Ifptpana.i}
{application/include/error.i}
define variable ghttIfptpana as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur , 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
       end case.
    end.
end function.

procedure crudIfptpana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfptpana.
    run updateIfptpana.
    run createIfptpana.
end procedure.

procedure setIfptpana:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfptpana.
    ghttIfptpana = phttIfptpana.
    run crudIfptpana.
    delete object phttIfptpana.
end procedure.

procedure readIfptpana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table Ifptpana Table des types de correspondances analytiques
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfptpana.
    define variable vhttBuffer as handle no-undo.
    define buffer Ifptpana for Ifptpana.

    vhttBuffer = phttIfptpana:default-buffer-handle.
    for first Ifptpana no-lock
        where :
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer Ifptpana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfptpana no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfptpana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table Ifptpana Table des types de correspondances analytiques
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfptpana.
    define variable vhttBuffer as handle  no-undo.
    define buffer Ifptpana for Ifptpana.

    vhttBuffer = phttIfptpana:default-buffer-handle.
    for each Ifptpana no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer Ifptpana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfptpana no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfptpana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer Ifptpana for Ifptpana.

    create query vhttquery.
    vhttBuffer = ghttIfptpana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfptpana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first Ifptpana exclusive-lock
                where rowid(Ifptpana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer Ifptpana:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer Ifptpana:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfptpana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer Ifptpana for Ifptpana.

    create query vhttquery.
    vhttBuffer = ghttIfptpana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfptpana:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create Ifptpana.
            if not outils:copyValidField(buffer Ifptpana:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfptpana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer Ifptpana for Ifptpana.

    create query vhttquery.
    vhttBuffer = ghttIfptpana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfptpana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first Ifptpana exclusive-lock
                where rowid(Ifptpana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer Ifptpana:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete Ifptpana no-error.
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

