/*------------------------------------------------------------------------
File        : ltdiv_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ltdiv
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ltdiv.i}
{application/include/error.i}
define variable ghttltdiv as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoref as handle, output phCduti as handle, output phNoses as handle, output phTpdiv as handle, output phNoreq as handle, output phNodiv as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noref/cduti/noses/tpdiv/noreq/nodiv, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noref' then phNoref = phBuffer:buffer-field(vi).
            when 'cduti' then phCduti = phBuffer:buffer-field(vi).
            when 'noses' then phNoses = phBuffer:buffer-field(vi).
            when 'tpdiv' then phTpdiv = phBuffer:buffer-field(vi).
            when 'noreq' then phNoreq = phBuffer:buffer-field(vi).
            when 'nodiv' then phNodiv = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudLtdiv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteLtdiv.
    run updateLtdiv.
    run createLtdiv.
end procedure.

procedure setLtdiv:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttLtdiv.
    ghttLtdiv = phttLtdiv.
    run crudLtdiv.
    delete object phttLtdiv.
end procedure.

procedure readLtdiv:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ltdiv 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoref as integer    no-undo.
    define input parameter pcCduti as character  no-undo.
    define input parameter piNoses as integer    no-undo.
    define input parameter pcTpdiv as character  no-undo.
    define input parameter piNoreq as integer    no-undo.
    define input parameter pdeNodiv as decimal    no-undo.
    define input parameter table-handle phttLtdiv.
    define variable vhttBuffer as handle no-undo.
    define buffer ltdiv for ltdiv.

    vhttBuffer = phttLtdiv:default-buffer-handle.
    for first ltdiv no-lock
        where ltdiv.noref = piNoref
          and ltdiv.cduti = pcCduti
          and ltdiv.noses = piNoses
          and ltdiv.tpdiv = pcTpdiv
          and ltdiv.noreq = piNoreq
          and ltdiv.nodiv = pdeNodiv:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ltdiv:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLtdiv no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getLtdiv:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ltdiv 
    Notes  : service externe. Critère piNoreq = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoref as integer    no-undo.
    define input parameter pcCduti as character  no-undo.
    define input parameter piNoses as integer    no-undo.
    define input parameter pcTpdiv as character  no-undo.
    define input parameter piNoreq as integer    no-undo.
    define input parameter table-handle phttLtdiv.
    define variable vhttBuffer as handle  no-undo.
    define buffer ltdiv for ltdiv.

    vhttBuffer = phttLtdiv:default-buffer-handle.
    if piNoreq = ?
    then for each ltdiv no-lock
        where ltdiv.noref = piNoref
          and ltdiv.cduti = pcCduti
          and ltdiv.noses = piNoses
          and ltdiv.tpdiv = pcTpdiv:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ltdiv:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ltdiv no-lock
        where ltdiv.noref = piNoref
          and ltdiv.cduti = pcCduti
          and ltdiv.noses = piNoses
          and ltdiv.tpdiv = pcTpdiv
          and ltdiv.noreq = piNoreq:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ltdiv:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLtdiv no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateLtdiv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoref    as handle  no-undo.
    define variable vhCduti    as handle  no-undo.
    define variable vhNoses    as handle  no-undo.
    define variable vhTpdiv    as handle  no-undo.
    define variable vhNoreq    as handle  no-undo.
    define variable vhNodiv    as handle  no-undo.
    define buffer ltdiv for ltdiv.

    create query vhttquery.
    vhttBuffer = ghttLtdiv:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttLtdiv:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoref, output vhCduti, output vhNoses, output vhTpdiv, output vhNoreq, output vhNodiv).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ltdiv exclusive-lock
                where rowid(ltdiv) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ltdiv:handle, 'noref/cduti/noses/tpdiv/noreq/nodiv: ', substitute('&1/&2/&3/&4/&5/&6', vhNoref:buffer-value(), vhCduti:buffer-value(), vhNoses:buffer-value(), vhTpdiv:buffer-value(), vhNoreq:buffer-value(), vhNodiv:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ltdiv:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createLtdiv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ltdiv for ltdiv.

    create query vhttquery.
    vhttBuffer = ghttLtdiv:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttLtdiv:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ltdiv.
            if not outils:copyValidField(buffer ltdiv:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteLtdiv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoref    as handle  no-undo.
    define variable vhCduti    as handle  no-undo.
    define variable vhNoses    as handle  no-undo.
    define variable vhTpdiv    as handle  no-undo.
    define variable vhNoreq    as handle  no-undo.
    define variable vhNodiv    as handle  no-undo.
    define buffer ltdiv for ltdiv.

    create query vhttquery.
    vhttBuffer = ghttLtdiv:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttLtdiv:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoref, output vhCduti, output vhNoses, output vhTpdiv, output vhNoreq, output vhNodiv).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ltdiv exclusive-lock
                where rowid(Ltdiv) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ltdiv:handle, 'noref/cduti/noses/tpdiv/noreq/nodiv: ', substitute('&1/&2/&3/&4/&5/&6', vhNoref:buffer-value(), vhCduti:buffer-value(), vhNoses:buffer-value(), vhTpdiv:buffer-value(), vhNoreq:buffer-value(), vhNodiv:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ltdiv no-error.
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

