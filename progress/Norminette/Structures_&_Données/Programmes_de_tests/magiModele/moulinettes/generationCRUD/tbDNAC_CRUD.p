/*------------------------------------------------------------------------
File        : tbDNAC_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table tbDNAC
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/tbDNAC.i}
{application/include/error.i}
define variable ghtttbDNAC as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNorol as handle, output phNoatt as handle, output phNodec as handle, output phNorev as handle, output phNoper as handle, output phIdtbl as handle, output phNotbl as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur norol/noatt/nodec/norev/noper/idtbl/notbl, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'norol' then phNorol = phBuffer:buffer-field(vi).
            when 'noatt' then phNoatt = phBuffer:buffer-field(vi).
            when 'nodec' then phNodec = phBuffer:buffer-field(vi).
            when 'norev' then phNorev = phBuffer:buffer-field(vi).
            when 'noper' then phNoper = phBuffer:buffer-field(vi).
            when 'idtbl' then phIdtbl = phBuffer:buffer-field(vi).
            when 'notbl' then phNotbl = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTbdnac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTbdnac.
    run updateTbdnac.
    run createTbdnac.
end procedure.

procedure setTbdnac:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTbdnac.
    ghttTbdnac = phttTbdnac.
    run crudTbdnac.
    delete object phttTbdnac.
end procedure.

procedure readTbdnac:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table tbDNAC 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNorol as int64      no-undo.
    define input parameter piNoatt as integer    no-undo.
    define input parameter piNodec as integer    no-undo.
    define input parameter piNorev as integer    no-undo.
    define input parameter piNoper as integer    no-undo.
    define input parameter pcIdtbl as character  no-undo.
    define input parameter piNotbl as integer    no-undo.
    define input parameter table-handle phttTbdnac.
    define variable vhttBuffer as handle no-undo.
    define buffer tbDNAC for tbDNAC.

    vhttBuffer = phttTbdnac:default-buffer-handle.
    for first tbDNAC no-lock
        where tbDNAC.norol = piNorol
          and tbDNAC.noatt = piNoatt
          and tbDNAC.nodec = piNodec
          and tbDNAC.norev = piNorev
          and tbDNAC.noper = piNoper
          and tbDNAC.idtbl = pcIdtbl
          and tbDNAC.notbl = piNotbl:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tbDNAC:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTbdnac no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTbdnac:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table tbDNAC 
    Notes  : service externe. Critère pcIdtbl = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNorol as int64      no-undo.
    define input parameter piNoatt as integer    no-undo.
    define input parameter piNodec as integer    no-undo.
    define input parameter piNorev as integer    no-undo.
    define input parameter piNoper as integer    no-undo.
    define input parameter pcIdtbl as character  no-undo.
    define input parameter table-handle phttTbdnac.
    define variable vhttBuffer as handle  no-undo.
    define buffer tbDNAC for tbDNAC.

    vhttBuffer = phttTbdnac:default-buffer-handle.
    if pcIdtbl = ?
    then for each tbDNAC no-lock
        where tbDNAC.norol = piNorol
          and tbDNAC.noatt = piNoatt
          and tbDNAC.nodec = piNodec
          and tbDNAC.norev = piNorev
          and tbDNAC.noper = piNoper:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tbDNAC:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each tbDNAC no-lock
        where tbDNAC.norol = piNorol
          and tbDNAC.noatt = piNoatt
          and tbDNAC.nodec = piNodec
          and tbDNAC.norev = piNorev
          and tbDNAC.noper = piNoper
          and tbDNAC.idtbl = pcIdtbl:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tbDNAC:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTbdnac no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTbdnac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhNoatt    as handle  no-undo.
    define variable vhNodec    as handle  no-undo.
    define variable vhNorev    as handle  no-undo.
    define variable vhNoper    as handle  no-undo.
    define variable vhIdtbl    as handle  no-undo.
    define variable vhNotbl    as handle  no-undo.
    define buffer tbDNAC for tbDNAC.

    create query vhttquery.
    vhttBuffer = ghttTbdnac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTbdnac:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNorol, output vhNoatt, output vhNodec, output vhNorev, output vhNoper, output vhIdtbl, output vhNotbl).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tbDNAC exclusive-lock
                where rowid(tbDNAC) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tbDNAC:handle, 'norol/noatt/nodec/norev/noper/idtbl/notbl: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhNorol:buffer-value(), vhNoatt:buffer-value(), vhNodec:buffer-value(), vhNorev:buffer-value(), vhNoper:buffer-value(), vhIdtbl:buffer-value(), vhNotbl:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer tbDNAC:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTbdnac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer tbDNAC for tbDNAC.

    create query vhttquery.
    vhttBuffer = ghttTbdnac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTbdnac:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create tbDNAC.
            if not outils:copyValidField(buffer tbDNAC:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTbdnac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhNoatt    as handle  no-undo.
    define variable vhNodec    as handle  no-undo.
    define variable vhNorev    as handle  no-undo.
    define variable vhNoper    as handle  no-undo.
    define variable vhIdtbl    as handle  no-undo.
    define variable vhNotbl    as handle  no-undo.
    define buffer tbDNAC for tbDNAC.

    create query vhttquery.
    vhttBuffer = ghttTbdnac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTbdnac:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNorol, output vhNoatt, output vhNodec, output vhNorev, output vhNoper, output vhIdtbl, output vhNotbl).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tbDNAC exclusive-lock
                where rowid(Tbdnac) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tbDNAC:handle, 'norol/noatt/nodec/norev/noper/idtbl/notbl: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhNorol:buffer-value(), vhNoatt:buffer-value(), vhNodec:buffer-value(), vhNorev:buffer-value(), vhNoper:buffer-value(), vhIdtbl:buffer-value(), vhNotbl:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete tbDNAC no-error.
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

