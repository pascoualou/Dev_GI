/*------------------------------------------------------------------------
File        : MandatSepa_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table MandatSepa
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/MandatSepa.i}
{application/include/error.i}
define variable ghttMandatSepa as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNomprelsepa as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noMPrelSEPA, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noMPrelSEPA' then phNomprelsepa = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudMandatsepa private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteMandatsepa.
    run updateMandatsepa.
    run createMandatsepa.
end procedure.

procedure setMandatsepa:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttMandatsepa.
    ghttMandatsepa = phttMandatsepa.
    run crudMandatsepa.
    delete object phttMandatsepa.
end procedure.

procedure readMandatsepa:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table MandatSepa Mandats de prélèvement SEPA
Fiche 0511/0023
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNomprelsepa as int64      no-undo.
    define input parameter table-handle phttMandatsepa.
    define variable vhttBuffer as handle no-undo.
    define buffer MandatSepa for MandatSepa.

    vhttBuffer = phttMandatsepa:default-buffer-handle.
    for first MandatSepa no-lock
        where MandatSepa.noMPrelSEPA = piNomprelsepa:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer MandatSepa:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMandatsepa no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getMandatsepa:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table MandatSepa Mandats de prélèvement SEPA
Fiche 0511/0023
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttMandatsepa.
    define variable vhttBuffer as handle  no-undo.
    define buffer MandatSepa for MandatSepa.

    vhttBuffer = phttMandatsepa:default-buffer-handle.
    for each MandatSepa no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer MandatSepa:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMandatsepa no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateMandatsepa private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomprelsepa    as handle  no-undo.
    define buffer MandatSepa for MandatSepa.

    create query vhttquery.
    vhttBuffer = ghttMandatsepa:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttMandatsepa:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomprelsepa).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first MandatSepa exclusive-lock
                where rowid(MandatSepa) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer MandatSepa:handle, 'noMPrelSEPA: ', substitute('&1', vhNomprelsepa:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer MandatSepa:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createMandatsepa private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer MandatSepa for MandatSepa.

    create query vhttquery.
    vhttBuffer = ghttMandatsepa:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttMandatsepa:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create MandatSepa.
            if not outils:copyValidField(buffer MandatSepa:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteMandatsepa private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomprelsepa    as handle  no-undo.
    define buffer MandatSepa for MandatSepa.

    create query vhttquery.
    vhttBuffer = ghttMandatsepa:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttMandatsepa:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomprelsepa).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first MandatSepa exclusive-lock
                where rowid(Mandatsepa) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer MandatSepa:handle, 'noMPrelSEPA: ', substitute('&1', vhNomprelsepa:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete MandatSepa no-error.
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

