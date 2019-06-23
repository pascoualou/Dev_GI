/*------------------------------------------------------------------------
File        : ltrol_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ltrol
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ltrol.i}
{application/include/error.i}
define variable ghttltrol as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoref as handle, output phCduti as handle, output phNoses as handle, output phTprol as handle, output phNoreq as handle, output phNorol as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noref/cduti/noses/tprol/noreq/norol, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noref' then phNoref = phBuffer:buffer-field(vi).
            when 'cduti' then phCduti = phBuffer:buffer-field(vi).
            when 'noses' then phNoses = phBuffer:buffer-field(vi).
            when 'tprol' then phTprol = phBuffer:buffer-field(vi).
            when 'noreq' then phNoreq = phBuffer:buffer-field(vi).
            when 'norol' then phNorol = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudLtrol private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteLtrol.
    run updateLtrol.
    run createLtrol.
end procedure.

procedure setLtrol:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttLtrol.
    ghttLtrol = phttLtrol.
    run crudLtrol.
    delete object phttLtrol.
end procedure.

procedure readLtrol:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ltrol 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoref as integer    no-undo.
    define input parameter pcCduti as character  no-undo.
    define input parameter piNoses as integer    no-undo.
    define input parameter pcTprol as character  no-undo.
    define input parameter piNoreq as integer    no-undo.
    define input parameter piNorol as integer    no-undo.
    define input parameter table-handle phttLtrol.
    define variable vhttBuffer as handle no-undo.
    define buffer ltrol for ltrol.

    vhttBuffer = phttLtrol:default-buffer-handle.
    for first ltrol no-lock
        where ltrol.noref = piNoref
          and ltrol.cduti = pcCduti
          and ltrol.noses = piNoses
          and ltrol.tprol = pcTprol
          and ltrol.noreq = piNoreq
          and ltrol.norol = piNorol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ltrol:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLtrol no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getLtrol:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ltrol 
    Notes  : service externe. Critère piNoreq = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoref as integer    no-undo.
    define input parameter pcCduti as character  no-undo.
    define input parameter piNoses as integer    no-undo.
    define input parameter pcTprol as character  no-undo.
    define input parameter piNoreq as integer    no-undo.
    define input parameter table-handle phttLtrol.
    define variable vhttBuffer as handle  no-undo.
    define buffer ltrol for ltrol.

    vhttBuffer = phttLtrol:default-buffer-handle.
    if piNoreq = ?
    then for each ltrol no-lock
        where ltrol.noref = piNoref
          and ltrol.cduti = pcCduti
          and ltrol.noses = piNoses
          and ltrol.tprol = pcTprol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ltrol:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ltrol no-lock
        where ltrol.noref = piNoref
          and ltrol.cduti = pcCduti
          and ltrol.noses = piNoses
          and ltrol.tprol = pcTprol
          and ltrol.noreq = piNoreq:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ltrol:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLtrol no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateLtrol private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoref    as handle  no-undo.
    define variable vhCduti    as handle  no-undo.
    define variable vhNoses    as handle  no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNoreq    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define buffer ltrol for ltrol.

    create query vhttquery.
    vhttBuffer = ghttLtrol:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttLtrol:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoref, output vhCduti, output vhNoses, output vhTprol, output vhNoreq, output vhNorol).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ltrol exclusive-lock
                where rowid(ltrol) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ltrol:handle, 'noref/cduti/noses/tprol/noreq/norol: ', substitute('&1/&2/&3/&4/&5/&6', vhNoref:buffer-value(), vhCduti:buffer-value(), vhNoses:buffer-value(), vhTprol:buffer-value(), vhNoreq:buffer-value(), vhNorol:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ltrol:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createLtrol private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ltrol for ltrol.

    create query vhttquery.
    vhttBuffer = ghttLtrol:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttLtrol:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ltrol.
            if not outils:copyValidField(buffer ltrol:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteLtrol private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoref    as handle  no-undo.
    define variable vhCduti    as handle  no-undo.
    define variable vhNoses    as handle  no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNoreq    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define buffer ltrol for ltrol.

    create query vhttquery.
    vhttBuffer = ghttLtrol:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttLtrol:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoref, output vhCduti, output vhNoses, output vhTprol, output vhNoreq, output vhNorol).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ltrol exclusive-lock
                where rowid(Ltrol) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ltrol:handle, 'noref/cduti/noses/tprol/noreq/norol: ', substitute('&1/&2/&3/&4/&5/&6', vhNoref:buffer-value(), vhCduti:buffer-value(), vhNoses:buffer-value(), vhTprol:buffer-value(), vhNoreq:buffer-value(), vhNorol:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ltrol no-error.
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

