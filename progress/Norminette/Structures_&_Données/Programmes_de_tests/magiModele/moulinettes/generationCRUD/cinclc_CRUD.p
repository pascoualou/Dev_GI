/*------------------------------------------------------------------------
File        : cinclc_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cinclc
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cinclc.i}
{application/include/error.i}
define variable ghttcinclc as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCalcul-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur calcul-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'calcul-cle' then phCalcul-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCinclc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCinclc.
    run updateCinclc.
    run createCinclc.
end procedure.

procedure setCinclc:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCinclc.
    ghttCinclc = phttCinclc.
    run crudCinclc.
    delete object phttCinclc.
end procedure.

procedure readCinclc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cinclc type de calcul des amortissements
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCalcul-cle as character  no-undo.
    define input parameter table-handle phttCinclc.
    define variable vhttBuffer as handle no-undo.
    define buffer cinclc for cinclc.

    vhttBuffer = phttCinclc:default-buffer-handle.
    for first cinclc no-lock
        where cinclc.calcul-cle = pcCalcul-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinclc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCinclc no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCinclc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cinclc type de calcul des amortissements
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCinclc.
    define variable vhttBuffer as handle  no-undo.
    define buffer cinclc for cinclc.

    vhttBuffer = phttCinclc:default-buffer-handle.
    for each cinclc no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinclc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCinclc no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCinclc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCalcul-cle    as handle  no-undo.
    define buffer cinclc for cinclc.

    create query vhttquery.
    vhttBuffer = ghttCinclc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCinclc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCalcul-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cinclc exclusive-lock
                where rowid(cinclc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cinclc:handle, 'calcul-cle: ', substitute('&1', vhCalcul-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cinclc:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCinclc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cinclc for cinclc.

    create query vhttquery.
    vhttBuffer = ghttCinclc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCinclc:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cinclc.
            if not outils:copyValidField(buffer cinclc:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCinclc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCalcul-cle    as handle  no-undo.
    define buffer cinclc for cinclc.

    create query vhttquery.
    vhttBuffer = ghttCinclc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCinclc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCalcul-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cinclc exclusive-lock
                where rowid(Cinclc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cinclc:handle, 'calcul-cle: ', substitute('&1', vhCalcul-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cinclc no-error.
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

