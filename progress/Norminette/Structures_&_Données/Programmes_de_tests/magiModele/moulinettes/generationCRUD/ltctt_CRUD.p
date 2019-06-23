/*------------------------------------------------------------------------
File        : ltctt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ltctt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ltctt.i}
{application/include/error.i}
define variable ghttltctt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoref as handle, output phCduti as handle, output phNoses as handle, output phTpcon as handle, output phNoreq as handle, output phNocon as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noref/cduti/noses/tpcon/noreq/nocon, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noref' then phNoref = phBuffer:buffer-field(vi).
            when 'cduti' then phCduti = phBuffer:buffer-field(vi).
            when 'noses' then phNoses = phBuffer:buffer-field(vi).
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'noreq' then phNoreq = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudLtctt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteLtctt.
    run updateLtctt.
    run createLtctt.
end procedure.

procedure setLtctt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttLtctt.
    ghttLtctt = phttLtctt.
    run crudLtctt.
    delete object phttLtctt.
end procedure.

procedure readLtctt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ltctt 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoref as integer    no-undo.
    define input parameter pcCduti as character  no-undo.
    define input parameter piNoses as integer    no-undo.
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNoreq as integer    no-undo.
    define input parameter piNocon as integer    no-undo.
    define input parameter table-handle phttLtctt.
    define variable vhttBuffer as handle no-undo.
    define buffer ltctt for ltctt.

    vhttBuffer = phttLtctt:default-buffer-handle.
    for first ltctt no-lock
        where ltctt.noref = piNoref
          and ltctt.cduti = pcCduti
          and ltctt.noses = piNoses
          and ltctt.tpcon = pcTpcon
          and ltctt.noreq = piNoreq
          and ltctt.nocon = piNocon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ltctt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLtctt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getLtctt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ltctt 
    Notes  : service externe. Critère piNoreq = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoref as integer    no-undo.
    define input parameter pcCduti as character  no-undo.
    define input parameter piNoses as integer    no-undo.
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNoreq as integer    no-undo.
    define input parameter table-handle phttLtctt.
    define variable vhttBuffer as handle  no-undo.
    define buffer ltctt for ltctt.

    vhttBuffer = phttLtctt:default-buffer-handle.
    if piNoreq = ?
    then for each ltctt no-lock
        where ltctt.noref = piNoref
          and ltctt.cduti = pcCduti
          and ltctt.noses = piNoses
          and ltctt.tpcon = pcTpcon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ltctt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ltctt no-lock
        where ltctt.noref = piNoref
          and ltctt.cduti = pcCduti
          and ltctt.noses = piNoses
          and ltctt.tpcon = pcTpcon
          and ltctt.noreq = piNoreq:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ltctt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLtctt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateLtctt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoref    as handle  no-undo.
    define variable vhCduti    as handle  no-undo.
    define variable vhNoses    as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNoreq    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define buffer ltctt for ltctt.

    create query vhttquery.
    vhttBuffer = ghttLtctt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttLtctt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoref, output vhCduti, output vhNoses, output vhTpcon, output vhNoreq, output vhNocon).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ltctt exclusive-lock
                where rowid(ltctt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ltctt:handle, 'noref/cduti/noses/tpcon/noreq/nocon: ', substitute('&1/&2/&3/&4/&5/&6', vhNoref:buffer-value(), vhCduti:buffer-value(), vhNoses:buffer-value(), vhTpcon:buffer-value(), vhNoreq:buffer-value(), vhNocon:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ltctt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createLtctt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ltctt for ltctt.

    create query vhttquery.
    vhttBuffer = ghttLtctt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttLtctt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ltctt.
            if not outils:copyValidField(buffer ltctt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteLtctt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoref    as handle  no-undo.
    define variable vhCduti    as handle  no-undo.
    define variable vhNoses    as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNoreq    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define buffer ltctt for ltctt.

    create query vhttquery.
    vhttBuffer = ghttLtctt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttLtctt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoref, output vhCduti, output vhNoses, output vhTpcon, output vhNoreq, output vhNocon).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ltctt exclusive-lock
                where rowid(Ltctt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ltctt:handle, 'noref/cduti/noses/tpcon/noreq/nocon: ', substitute('&1/&2/&3/&4/&5/&6', vhNoref:buffer-value(), vhCduti:buffer-value(), vhNoses:buffer-value(), vhTpcon:buffer-value(), vhNoreq:buffer-value(), vhNocon:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ltctt no-error.
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

