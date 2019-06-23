/*------------------------------------------------------------------------
File        : SuiMandatSEPA_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table SuiMandatSEPA
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/SuiMandatSEPA.i}
{application/include/error.i}
define variable ghttSuiMandatSEPA as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNomprelsepa as handle, output phNolig as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noMPrelSEPA/nolig, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noMPrelSEPA' then phNomprelsepa = phBuffer:buffer-field(vi).
            when 'nolig' then phNolig = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSuimandatsepa private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSuimandatsepa.
    run updateSuimandatsepa.
    run createSuimandatsepa.
end procedure.

procedure setSuimandatsepa:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSuimandatsepa.
    ghttSuimandatsepa = phttSuimandatsepa.
    run crudSuimandatsepa.
    delete object phttSuimandatsepa.
end procedure.

procedure readSuimandatsepa:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table SuiMandatSEPA Suivi des prélèvements et modifications des mandats de prélèvement SEPA
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNomprelsepa as int64      no-undo.
    define input parameter piNolig       as integer    no-undo.
    define input parameter table-handle phttSuimandatsepa.
    define variable vhttBuffer as handle no-undo.
    define buffer SuiMandatSEPA for SuiMandatSEPA.

    vhttBuffer = phttSuimandatsepa:default-buffer-handle.
    for first SuiMandatSEPA no-lock
        where SuiMandatSEPA.noMPrelSEPA = piNomprelsepa
          and SuiMandatSEPA.nolig = piNolig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer SuiMandatSEPA:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSuimandatsepa no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSuimandatsepa:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table SuiMandatSEPA Suivi des prélèvements et modifications des mandats de prélèvement SEPA
    Notes  : service externe. Critère piNomprelsepa = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNomprelsepa as int64      no-undo.
    define input parameter table-handle phttSuimandatsepa.
    define variable vhttBuffer as handle  no-undo.
    define buffer SuiMandatSEPA for SuiMandatSEPA.

    vhttBuffer = phttSuimandatsepa:default-buffer-handle.
    if piNomprelsepa = ?
    then for each SuiMandatSEPA no-lock
        where SuiMandatSEPA.noMPrelSEPA = piNomprelsepa:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer SuiMandatSEPA:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each SuiMandatSEPA no-lock
        where SuiMandatSEPA.noMPrelSEPA = piNomprelsepa:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer SuiMandatSEPA:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSuimandatsepa no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSuimandatsepa private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomprelsepa    as handle  no-undo.
    define variable vhNolig    as handle  no-undo.
    define buffer SuiMandatSEPA for SuiMandatSEPA.

    create query vhttquery.
    vhttBuffer = ghttSuimandatsepa:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSuimandatsepa:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomprelsepa, output vhNolig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first SuiMandatSEPA exclusive-lock
                where rowid(SuiMandatSEPA) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer SuiMandatSEPA:handle, 'noMPrelSEPA/nolig: ', substitute('&1/&2', vhNomprelsepa:buffer-value(), vhNolig:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer SuiMandatSEPA:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSuimandatsepa private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer SuiMandatSEPA for SuiMandatSEPA.

    create query vhttquery.
    vhttBuffer = ghttSuimandatsepa:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSuimandatsepa:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create SuiMandatSEPA.
            if not outils:copyValidField(buffer SuiMandatSEPA:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSuimandatsepa private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomprelsepa    as handle  no-undo.
    define variable vhNolig    as handle  no-undo.
    define buffer SuiMandatSEPA for SuiMandatSEPA.

    create query vhttquery.
    vhttBuffer = ghttSuimandatsepa:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSuimandatsepa:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomprelsepa, output vhNolig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first SuiMandatSEPA exclusive-lock
                where rowid(Suimandatsepa) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer SuiMandatSEPA:handle, 'noMPrelSEPA/nolig: ', substitute('&1/&2', vhNomprelsepa:buffer-value(), vhNolig:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete SuiMandatSEPA no-error.
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

