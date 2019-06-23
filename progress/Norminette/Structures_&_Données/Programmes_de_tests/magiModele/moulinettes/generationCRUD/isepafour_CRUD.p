/*------------------------------------------------------------------------
File        : isepafour_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table isepafour
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/isepafour.i}
{application/include/error.i}
define variable ghttisepafour as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudIsepafour private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIsepafour.
    run updateIsepafour.
    run createIsepafour.
end procedure.

procedure setIsepafour:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIsepafour.
    ghttIsepafour = phttIsepafour.
    run crudIsepafour.
    delete object phttIsepafour.
end procedure.

procedure readIsepafour:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table isepafour Mandats de prélèvement SEPA
Fiche 0511/0023
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNomprelsepa as int64      no-undo.
    define input parameter table-handle phttIsepafour.
    define variable vhttBuffer as handle no-undo.
    define buffer isepafour for isepafour.

    vhttBuffer = phttIsepafour:default-buffer-handle.
    for first isepafour no-lock
        where isepafour.noMPrelSEPA = piNomprelsepa:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer isepafour:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIsepafour no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIsepafour:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table isepafour Mandats de prélèvement SEPA
Fiche 0511/0023
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIsepafour.
    define variable vhttBuffer as handle  no-undo.
    define buffer isepafour for isepafour.

    vhttBuffer = phttIsepafour:default-buffer-handle.
    for each isepafour no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer isepafour:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIsepafour no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIsepafour private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomprelsepa    as handle  no-undo.
    define buffer isepafour for isepafour.

    create query vhttquery.
    vhttBuffer = ghttIsepafour:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIsepafour:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomprelsepa).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first isepafour exclusive-lock
                where rowid(isepafour) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer isepafour:handle, 'noMPrelSEPA: ', substitute('&1', vhNomprelsepa:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer isepafour:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIsepafour private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer isepafour for isepafour.

    create query vhttquery.
    vhttBuffer = ghttIsepafour:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIsepafour:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create isepafour.
            if not outils:copyValidField(buffer isepafour:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIsepafour private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomprelsepa    as handle  no-undo.
    define buffer isepafour for isepafour.

    create query vhttquery.
    vhttBuffer = ghttIsepafour:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIsepafour:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomprelsepa).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first isepafour exclusive-lock
                where rowid(Isepafour) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer isepafour:handle, 'noMPrelSEPA: ', substitute('&1', vhNomprelsepa:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete isepafour no-error.
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

