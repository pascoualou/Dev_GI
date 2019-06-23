/*------------------------------------------------------------------------
File        : chDNAC_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table chDNAC
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/chDNAC.i}
{application/include/error.i}
define variable ghttchDNAC as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNorol as handle, output phNoatt as handle, output phNodec as handle, output phNorev as handle, output phNoper as handle, output phIdtbl as handle, output phNotbl as handle, output phIdchp as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur norol/noatt/nodec/norev/noper/idtbl/notbl/idchp, 
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
            when 'idchp' then phIdchp = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudChdnac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteChdnac.
    run updateChdnac.
    run createChdnac.
end procedure.

procedure setChdnac:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttChdnac.
    ghttChdnac = phttChdnac.
    run crudChdnac.
    delete object phttChdnac.
end procedure.

procedure readChdnac:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table chDNAC 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNorol as int64      no-undo.
    define input parameter piNoatt as integer    no-undo.
    define input parameter piNodec as integer    no-undo.
    define input parameter piNorev as integer    no-undo.
    define input parameter piNoper as integer    no-undo.
    define input parameter pcIdtbl as character  no-undo.
    define input parameter piNotbl as integer    no-undo.
    define input parameter pcIdchp as character  no-undo.
    define input parameter table-handle phttChdnac.
    define variable vhttBuffer as handle no-undo.
    define buffer chDNAC for chDNAC.

    vhttBuffer = phttChdnac:default-buffer-handle.
    for first chDNAC no-lock
        where chDNAC.norol = piNorol
          and chDNAC.noatt = piNoatt
          and chDNAC.nodec = piNodec
          and chDNAC.norev = piNorev
          and chDNAC.noper = piNoper
          and chDNAC.idtbl = pcIdtbl
          and chDNAC.notbl = piNotbl
          and chDNAC.idchp = pcIdchp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer chDNAC:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttChdnac no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getChdnac:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table chDNAC 
    Notes  : service externe. Critère piNotbl = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNorol as int64      no-undo.
    define input parameter piNoatt as integer    no-undo.
    define input parameter piNodec as integer    no-undo.
    define input parameter piNorev as integer    no-undo.
    define input parameter piNoper as integer    no-undo.
    define input parameter pcIdtbl as character  no-undo.
    define input parameter piNotbl as integer    no-undo.
    define input parameter table-handle phttChdnac.
    define variable vhttBuffer as handle  no-undo.
    define buffer chDNAC for chDNAC.

    vhttBuffer = phttChdnac:default-buffer-handle.
    if piNotbl = ?
    then for each chDNAC no-lock
        where chDNAC.norol = piNorol
          and chDNAC.noatt = piNoatt
          and chDNAC.nodec = piNodec
          and chDNAC.norev = piNorev
          and chDNAC.noper = piNoper
          and chDNAC.idtbl = pcIdtbl:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer chDNAC:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each chDNAC no-lock
        where chDNAC.norol = piNorol
          and chDNAC.noatt = piNoatt
          and chDNAC.nodec = piNodec
          and chDNAC.norev = piNorev
          and chDNAC.noper = piNoper
          and chDNAC.idtbl = pcIdtbl
          and chDNAC.notbl = piNotbl:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer chDNAC:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttChdnac no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateChdnac private:
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
    define variable vhIdchp    as handle  no-undo.
    define buffer chDNAC for chDNAC.

    create query vhttquery.
    vhttBuffer = ghttChdnac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttChdnac:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNorol, output vhNoatt, output vhNodec, output vhNorev, output vhNoper, output vhIdtbl, output vhNotbl, output vhIdchp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first chDNAC exclusive-lock
                where rowid(chDNAC) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer chDNAC:handle, 'norol/noatt/nodec/norev/noper/idtbl/notbl/idchp: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8', vhNorol:buffer-value(), vhNoatt:buffer-value(), vhNodec:buffer-value(), vhNorev:buffer-value(), vhNoper:buffer-value(), vhIdtbl:buffer-value(), vhNotbl:buffer-value(), vhIdchp:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer chDNAC:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createChdnac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer chDNAC for chDNAC.

    create query vhttquery.
    vhttBuffer = ghttChdnac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttChdnac:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create chDNAC.
            if not outils:copyValidField(buffer chDNAC:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteChdnac private:
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
    define variable vhIdchp    as handle  no-undo.
    define buffer chDNAC for chDNAC.

    create query vhttquery.
    vhttBuffer = ghttChdnac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttChdnac:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNorol, output vhNoatt, output vhNodec, output vhNorev, output vhNoper, output vhIdtbl, output vhNotbl, output vhIdchp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first chDNAC exclusive-lock
                where rowid(Chdnac) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer chDNAC:handle, 'norol/noatt/nodec/norev/noper/idtbl/notbl/idchp: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8', vhNorol:buffer-value(), vhNoatt:buffer-value(), vhNodec:buffer-value(), vhNorev:buffer-value(), vhNoper:buffer-value(), vhIdtbl:buffer-value(), vhNotbl:buffer-value(), vhIdchp:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete chDNAC no-error.
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

