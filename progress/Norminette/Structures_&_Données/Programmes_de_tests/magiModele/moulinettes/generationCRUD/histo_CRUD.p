/*------------------------------------------------------------------------
File        : histo_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table histo
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/histo.i}
{application/include/error.i}
define variable ghtthisto as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNolig as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nolig, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nolig' then phNolig = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudHisto private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteHisto.
    run updateHisto.
    run createHisto.
end procedure.

procedure setHisto:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttHisto.
    ghttHisto = phttHisto.
    run crudHisto.
    delete object phttHisto.
end procedure.

procedure readHisto:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table histo 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNolig as integer    no-undo.
    define input parameter table-handle phttHisto.
    define variable vhttBuffer as handle no-undo.
    define buffer histo for histo.

    vhttBuffer = phttHisto:default-buffer-handle.
    for first histo no-lock
        where histo.nolig = piNolig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer histo:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttHisto no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getHisto:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table histo 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttHisto.
    define variable vhttBuffer as handle  no-undo.
    define buffer histo for histo.

    vhttBuffer = phttHisto:default-buffer-handle.
    for each histo no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer histo:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttHisto no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateHisto private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNolig    as handle  no-undo.
    define buffer histo for histo.

    create query vhttquery.
    vhttBuffer = ghttHisto:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttHisto:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNolig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first histo exclusive-lock
                where rowid(histo) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer histo:handle, 'nolig: ', substitute('&1', vhNolig:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer histo:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createHisto private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer histo for histo.

    create query vhttquery.
    vhttBuffer = ghttHisto:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttHisto:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create histo.
            if not outils:copyValidField(buffer histo:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteHisto private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNolig    as handle  no-undo.
    define buffer histo for histo.

    create query vhttquery.
    vhttBuffer = ghttHisto:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttHisto:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNolig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first histo exclusive-lock
                where rowid(Histo) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer histo:handle, 'nolig: ', substitute('&1', vhNolig:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete histo no-error.
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

